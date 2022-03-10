extends Control
class_name Main

onready var bt_detect_all = find_node("bt_detect_all")
onready var console:TextEdit = $Screen/Console

var dir := Directory.new()
var file := File.new()


var drive_letter:String = ""
var steam_games_dir:String = ""

func _ready() -> void:
	Manager.main = self

var _line:int = 0
func console_add_text(message:String) -> void:
	
	console.text += message + "\n"
	_line += 1
	console.cursor_set_line(_line)

func _on_bt_detect_all_pressed() -> void:
	
	var err = _detect_drive_letter()
	
	if err != OK:
		Manager.show_message(err)
		return
	
	_detect_steam_games()
	
	pass # Replace with function body.

func _detect_drive_letter() -> int:
	
#	print("TESTING DRIVE COUNT: ", dir.get_drive_count())
#	print("TESTING GET DRIVE 0: ", dir.get_drive(0))
	
	# This 2 lines below doesnt work on export, I did a workaround to avoid it
#	for i in dir.get_drive_count():
#		var letter : String = dir.get_drive(i)
	for letter in ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","X","W","Y","Z"]:
		print("checking letter ->  ", letter)
		var err = file.open("%s:\\Program Files (x86)\\Steam\\steamapps\\libraryfolders.vdf" % letter, File.READ)
		if err == OK:
			drive_letter = letter + ":" #REMOVE THIS ":" after fixing
			steam_games_dir = "%s\\Program Files (x86)\\Steam\\steamapps\\common\\" % drive_letter
			Manager.show_message(-1, "found steam dir: %s" % steam_games_dir)
			break
		else: continue
	
	print("DriveLetter: ", drive_letter)
	
	if drive_letter == "":
		return Manager.ERROR.STEAM_NOT_FOUND
	else:
		return OK
	pass

func _detect_steam_games() -> void:
	_signal_game_list = []
	for child in game_container.get_children():
		child.queue_free()
		pass
	# Find libraryfolders.vdf
	var library_folders_path:String = "%s\\Program Files (x86)\\Steam\\steamapps\\libraryfolders.vdf" % drive_letter
	var error = file.open(library_folders_path,File.READ)
	if error != OK:
		file.close()
		Manager.show_message(Manager.ERROR.LIBRARY_PATH_NOT_FOUND, library_folders_path)
		return
	
	var contents:String = file.get_as_text()
	print(contents)
	
	file.close()
	
	# Find the Games and APPID in the contents
	var comp_groups:String ="\\\"\\w\\\"\\n\\t{\\n(?<content>(.*\\n(?!\\t}).)+)"
	var comp_ids:String = "(?:\\t\\t\\t\"(?<appid>\\w+)\"\\t\\t\"(?<update>\\w+)\"\\n)"
	var comp_path:String = "\\t\\t\"path\"\\t\\t\"(?<path>.*)\""
	var regex := RegEx.new()
	var data_arr := []
	
	
	# Get the groups of VDF
	regex.compile(comp_groups)
	var groups:Array = regex.search_all(contents)
	var groups_match := []
	for m in groups:
		groups_match.append(m.get_string("content"))
		print("GROUP: \n", m.get_string("content"))
#		groups_match.append(group)
	
	
	# get the necessary data
	
	for i in range(groups_match.size()):
		regex.compile(comp_ids)
		var ids:Array = regex.search_all(groups_match[i])
		var ids_match := []
		for m in ids:
			ids_match.append(m.get_string("appid"))
		data_arr.append(ids_match)
		
		regex.compile(comp_path)
		var paths:Array = regex.search_all(groups_match[i])
		var paths_match := []
		for m in paths:
			paths_match.append(m.get_string("path"))
		data_arr.append(paths_match)
		pass
	
	# data_arr structure
	# [ [appid,appid], [path], [appid,appid], [path]....  ]

#	#	# Actually detect games

	for index in Manager.game_data.games.size():
		var game = Manager.game_data.games[index]
		print("\nTrying to detect: " + game.title)
#		var game_detected:bool = false
		for i in range(0, data_arr.size(), 2): # run the array only in appids array
			for appid in data_arr[i]:
				if str(game.appid) == str(appid):
					Manager.game_data.games[index]["found"] = true
					Manager.game_data.games[index]["path"] = str(data_arr[i+1][0])
				pass
			pass
		
	print("done")
	
	print(Manager.game_data.games)
	
	for game in Manager.game_data.games:
		_insert_game(game)
		pass
	
#		for arr in found_games_data:
#			if str(game.appid) == str(arr[0]):
#				Manager.show_message(-1, "[color=lime]Detected: %s[/color]" % game.title)
#				game_detected = true
#		_insert_game(game,game_detected)

	pass

const game_button = preload("res://stuff/tb_game.tscn")
onready var game_container: GridContainer = find_node("GameContainer")

func _insert_game(data:Dictionary) -> void:
	
	var mod:TextureRect = game_button.instance()
	
	var texture = ImageTexture.new()
	var image = Image.new()
	
	image.load("user://icons/%s.png" % data.shortname)
	texture.create_from_image(image)
	mod.texture = texture
	mod.hint_tooltip = data.title
	
	var lb_status:Label = mod.get_node("VBoxContainer/lb_status")
	var lb_version:Label = mod.get_node("VBoxContainer/lb_version")
	var bt_patch:Button = mod.get_node("VBoxContainer/bt_patch")
	var bt_run:Button = mod.get_node("bt_run")
	bt_run.appid = data.appid
	bt_patch.connect("pressed",self,"_on_update_pressed",[bt_patch, data])
	
	
	if not data.has("found"):
		bt_patch.disabled = true
		lb_version.text = "---"
		lb_status.text = ""
		pass
	else:
		var game_version:String = _get_game_version(data)	
		lb_version.text = game_version
		_check_game_status(data, lb_status, game_version, bt_patch)
		pass
#	button.connect("pressed",self,"_on_game_button_pressed", [data])
	$Screen/ScrollContainer/GameContainer.add_child(mod)
	
	
	pass

signal _version_request_done
var _failed:bool = false
var _games_version_data:Dictionary
var _signal_game_list:PoolStringArray = []

func _check_game_status(data:Dictionary, label:Label, version:String, button:Button) -> void:
	
	while Manager.mod_data.empty():
		print("mod_data is empty")
		yield(Manager,"locations_downloaded")

	var url :String = Manager.mod_data[Manager.data_local.lang]["version"][data.shortname]
	
	Manager.create_request(self, "_on_version_requested",url,[data.shortname])

	while not _games_version_data.has(data.shortname):
		yield(self,"_version_request_done")
		
	if _failed:
		Manager.show_message(-1, "[color=red]Failed requesting game version[/color]")
		return

	var _version :String = _games_version_data[data.shortname].buildVersion
	var _version_number:float = Manager.get_float_from_string(_version)
	var local_version_number:float = Manager.get_float_from_string(version)
	
	if local_version_number < _version_number:
		label.text = "Update Available\n %s" % _version
		label.add_color_override("font_color", Color.yellow)
	elif local_version_number == _version_number:
		label.text = "Updated"
		label.add_color_override("font_color",Color.limegreen)
		button.disabled = true
	
	pass

func _on_version_requested(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, extra_data) -> void:
	print(extra_data)
	_signal_game_list.append(extra_data)
	if response_code != 200:
		_failed = true
		emit_signal("_version_request_done")
		return
	_failed = false
	_games_version_data[extra_data] = parse_json(body.get_string_from_utf8()) # extra_data is shortname = pp2,qp1
	emit_signal("_version_request_done")
	pass

func _get_full_path(data_path:String, data_folder:String, data_file:String="") -> String:
	var path:String = ""	
	
	var win_path:String = data_path.replace("\\","/")
	var optional:String = "/%s" % data_file if data_file != "" else ""
	path = win_path.replace("//","/") + ("/%s/%s" % ["steamapps/common", data_folder]) + optional
	path = path.replace("/","\\")
	
	return path


func _get_game_version(data:Dictionary) -> String:
	print("Getting game version")
	
	var game_path = _get_full_path(data.path, data.folder, data.config)
	
	var err = file.open(game_path, File.READ)
	
	if err != OK:
		if data.has("custom_config"):
			if data.custom_config == true:
				return "NOT PATCHED"
		Manager.show_message(-1, "[color=red]Couldnt find config file for: %s[/color]" % data.title)
		return "NULL"
	
	var file_data :Dictionary = parse_json(file.get_as_text())
	var build_version:String = file_data.buildVersion

	return build_version
	

#emited when you change screens is done
func screen_just_entered() -> void:
	Manager.show_message(-1, "Detecting games...")
	
	var err = _detect_drive_letter()
	
	if err != OK:
		Manager.show_message(-1, "Error detecting drive letter: " + str(err) )
		return
	
	_detect_steam_games()
	pass

signal _zip_downloaded
var _is_download_done:bool = false
var _zip_failed:bool = false
var _zip_game:Dictionary = {}
func _on_update_pressed(button:Button, game:Dictionary) -> void:
	_is_download_done = false
	console.visible = true
	_zip_failed = false
	_zip_game = game
	var url_mod:String = Manager.mod_data[Manager.data_local.lang]["patch"][game.shortname]
	var http:HTTPRequest = Manager.create_request(self,"_on_downloaded_zip",url_mod)
	console_add_text("Downloading patch...")
	var last_percent:int = -1
	while not _is_download_done:
		var request_size:int = http.get_body_size()
		var downloaded_bytes:int = http.get_downloaded_bytes()
		var percent := int(downloaded_bytes*100/request_size)
		if percent > last_percent:
			console_add_text("%d%%" % [percent])
		last_percent = percent
		yield(get_tree().create_timer(.1,false),"timeout")
		pass
	button.disabled = true
	http.queue_free()
	if _zip_failed:
		Manager.show_message(-1,"[color=red] DOWNLOAD ERROR[/color]")
		button.disabled = false
		return
	Manager.show_message(-1, "[color=lime]Download finished successfully![/color]")
	
	# EXTRACT FILES
	var game_dir:String = _get_full_path(game.path,game.folder)
	
	extract("user://%s.zip" % game.shortname, game_dir )
	yield(self, "threads_done")
#	Manager.show_message(-1,"[color=lime]%s[/color]" % str(time_string) )
	# DONE
	console.visible = false
	console.text = ""
	_detect_steam_games() # update the datas
	pass

func _on_downloaded_zip(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if response_code != 200:
		_zip_failed = true
		emit_signal("_zip_downloaded")
		return
	var err = file.open("user://%s.zip" % _zip_game.shortname,File.WRITE)
	file.store_buffer(body)
	file.close()
	_is_download_done = true
	emit_signal("_zip_downloaded")
	pass


func _on_bt_reset_pressed() -> void:
	_detect_steam_games()
	pass # Replace with function body.

# MULTI-THREADED  EXTRACTING =================================

var mutex := Mutex.new()
var _messages := PoolStringArray()
var jobs_done:int = 0
signal threads_done

func extract(path:String="", out_path:String="") -> void:
	var zip := ZIPReader.new()
	var _threads:Array = []
	_messages = PoolStringArray()
	var start_time:float = 0
	var end_time:float = 0
	jobs_done = 0
	
	var _proc_count:int = OS.get_processor_count()
	if _proc_count >= 2: _proc_count -= 1
	
	for i in range(_proc_count):
		_threads.append(Thread.new())

	Manager.main.console_add_text("Thread count: " + str(_threads.size()))
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
		_threads[i].start(self, "_unzip_thread",{files=split_files[i], id=i, zip_path=path, out=out_path})
		yield(get_tree(),"idle_frame")
		pass


	while true:
		if _messages.size() > 0:
			mutex.lock()
			console_add_text(_messages[0])
			_messages.remove(0)
			mutex.unlock()
		
		for thread in _threads:
			if thread.is_alive(): continue
			
			elif thread.is_active(): 
				thread.wait_to_finish()
		
		mutex.lock()
		print("jobs done: ", jobs_done)
		if jobs_done >= _threads.size():
			break
		
		mutex.unlock()
		
		yield(get_tree(),"idle_frame")
	
	

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
	Manager.show_message(-1,"Done in: %d%s" % [mins if secs > 59 else secs, "minutes" if secs > 59 else "seconds"] )
	emit_signal("threads_done")

func _unzip_thread(data):
	var _unzip := ZIPReader.new()
	var file := File.new()
	var error = _unzip.open(data.zip_path)
	if error != OK:
#		mutex.lock()
#		Manager.show_message(-1, "[color=red]Error opening: %s[/color]" % data.zip_path)
#		mutex.unlock()
		
		return
		
	for file_name in data.files:
#		mutex.lock()
#		print("extracting: %s in thread > %d < " % [file_name, data.id])	
		var buffer:PoolByteArray = _unzip.read_file(file_name)
		var err = file.open(data.out+file_name,File.WRITE)
		if err != OK:
#			print("error extracting")
#			mutex.lock()
#			Manager.show_message(-1, "[color=red]Error extracting: %s[/color]" % (data.out+file_name))
#			mutex.unlock()
			return
		file.store_buffer(buffer)
		file.close()
#		print("DONE: %s in thread > %d < " % [file_name, data.id])
		mutex.lock()
		_messages.append("Extracted: %s/%s in thread > %d < " % [data.out, file_name, data.id])
#		Manager.main.console_add_text("Extracted: %s in thread > %d < " % [file_name, data.id])
		mutex.unlock()
	_unzip.close()
	mutex.lock()
	jobs_done += 1
	mutex.unlock()
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

func _on_bt_lang_pressed() -> void:
	Manager.data_local.erase("lang")
	Manager.change_screen(Manager.SCREEN.SETTINGS)
	Manager.emit_signal("data_file", false) # emit the data file with not found to create another
	pass # Replace with function body.
