extends Reference
class_name ZipExtractor

var zip := ZIPReader.new()
var mutex := Mutex.new()
var _threads:Array = []
var the_owner:Node = null
var start_time:float = 0
var end_time:float = 0
var jobs_done:int = 0

func _init(the_owner:Node) -> void:
	self.the_owner = the_owner
	for i in range(OS.get_processor_count()):
		_threads.append(Thread.new())
	print("Thread count: ", _threads.size())
	Manager.main.console_add_text("Thread count: " + str(_threads.size()))
	pass

func extract(path:String="", out_path:String="") -> String:
	jobs_done = 0
	start_time = OS.get_ticks_msec()
	#prepare paths:
	
	if "\\" in out_path:
		out_path = out_path.replace("\\","/")
	if not out_path.ends_with("/"):
		out_path += "/"
	
	
	# DEBUG VARS DELETEME
#	path = "C:/Users/nonunknown/AppData/Roaming/Godot/app_userdata/JPPP/pp2.zip"
#	out_path = "C:/Users/nonunknown/AppData/Roaming/Godot/app_userdata/JPPP/test/"
	# END DEBUG
	
	var err = zip.open(path)
	
	if err != OK:
		print("ERROR opening: ", err)
		Manager.show_message(-1, "[color=red]Error opening zip: %d[/color]" % err)
		return "ERROR"
	
	var files_name :PoolStringArray = zip.get_files()
	var data:Dictionary = _filter_files(files_name)
	
	#create dirs
	var dir := Directory.new()
	for dir_path in data.dirs:
		dir.make_dir_recursive(out_path + dir_path)
	
	#split the files into parts to use in the threads
	var num_files:int = data.files.size()
	Manager.main.console_add_text("Number of files: " + str(num_files))
	print("Number of files: ", num_files)
	var max_files:int = int(num_files/_threads.size())
	print("Division: ", max_files)
	var the_files:PoolStringArray = data.files
	var split_files:Array = []
	var target:int = 0
	
	# mount array
	for i in range(_threads.size()):
		split_files.append([])
	
	#split the filenames
	for i in range(num_files):
		var arr_idx:int = i % _threads.size()
		split_files[arr_idx].append(the_files[i])
		pass
	
	
	for i in range(_threads.size()):
		var thread:Thread = _threads[i]
		thread.start(self, "_unzip_thread",{files=split_files[i], id=i, zip_path=path, out=out_path})
		yield(the_owner.get_tree(),"idle_frame")
		pass
#
	for thread in _threads:
		thread.wait_to_finish()
		print("wait finish: ", thread)
		yield(the_owner.get_tree(),"idle_frame")

#	while jobs_done < _threads.size():
#		print("jobs done: ", jobs_done)
#		yield(the_owner.get_tree(),"idle_frame")
	
	end_time = OS.get_ticks_msec()
	var secs:float = ( end_time - start_time ) / 1000
	var mins:float = ( end_time - start_time ) / 60000
	
#	print("DONE IN: %d secs" % secs )
#	print("JOB FINISHED")
#	Manager.show_message(-1, "[color=lime]JOB FINISHED[/color]")
	zip.close()
	
	return "Done in: %d%s" % [mins if secs > 59 else secs, "minutes" if secs > 59 else "seconds"]

func _unzip_thread(data):
	var _unzip := ZIPReader.new()
	var file := File.new()
	var error = _unzip.open(data.zip_path)
	if error != OK:
		mutex.lock()
		Manager.show_message(-1, "[color=red]Error opening: %s[/color]" % data.zip_path)
		mutex.unlock()
		
		return
		
	for file_name in data.files:
#		mutex.lock()
#		print("extracting: %s in thread > %d < " % [file_name, data.id])	
		var buffer:PoolByteArray = _unzip.read_file(file_name)
		var err = file.open(data.out+file_name,File.WRITE)
		if err != OK:
#			print("error extracting")
			mutex.lock()
			Manager.show_message(-1, "[color=red]Error extracting: %s[/color]" % (data.out+file_name))
			mutex.unlock()
			return
		file.store_buffer(buffer)
		file.close()
#		print("DONE: %s in thread > %d < " % [file_name, data.id])
		mutex.lock()
		Manager.main.console_add_text("Extracted: %s in thread > %d < " % [file_name, data.id])
		mutex.unlock()
	_unzip.close()
	jobs_done += 1
	pass

func _filter_files(from:PoolStringArray) -> Dictionary:
	
	var result := {"files":[],"dirs":[]}

	for name in from:
		var target_name:String = name
		if target_name.ends_with("/"): 
			result.dirs.append(target_name)
		else:
			result.files.append(target_name)

	return result
