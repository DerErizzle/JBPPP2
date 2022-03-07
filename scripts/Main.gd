extends Control
class_name Main

onready var bt_detect_all = find_node("bt_detect_all")
onready var console:TextEdit = $Screen/Console

var dir := Directory.new()
var file := File.new()


var drive_letter:String = ""
var steam_games_dir:String = ""
var found_games_data:Array = [] # this is a multidimentional array = [ [0,1], [0,1] ] -> 0 is appid and 1 is game update version

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
	
	var regex := RegEx.new()
	regex.compile("(?:\\t\\t\\t\"(?<appid>\\w+)\"\\t\\t\"(?<update>\\w+)\"\\n)")
	
	var results:Array = regex.search_all(contents)
	
	for m in results:
		var result = m.strings
		found_games_data.append( [result[1], result[2]] )
	
	# Actually detect games
	
	var game_data:Array = Manager.game_data.games
	
	for game in game_data:
		print("\nTrying to detect: " + game.title)
		var game_detected:bool = false
		for arr in found_games_data:
			if str(game.appid) == str(arr[0]):
				Manager.show_message(-1, "[color=lime]Detected: %s[/color]" % game.title)
				game_detected = true
		_insert_game(game,game_detected)
		


		
		
	
	pass

const game_button = preload("res://stuff/tb_game.tscn")
onready var game_container: GridContainer = find_node("GameContainer")

func _insert_game(data:Dictionary,detected:bool) -> void:
	print(data)
	
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
	
	bt_patch.connect("pressed",self,"_on_update_pressed",[bt_patch, data])
	
	if not detected:
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

#func _on_game_button_pressed(data:Dictionary) -> void:
#	data.version = _get_game_version(data)
#	Manager.set_game_data(data)
#	Manager.change_screen(Manager.SCREEN.CONFIG)
#	print("Changin")
#	pass

func _get_game_version(data:Dictionary) -> String:
	print("Getting game version")
	var game_path :String = steam_games_dir + data.folder + "\\%s" % data.config
	
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
		Manager.show_message(err)
		return
	
	_detect_steam_games()
	pass

signal _zip_downloaded
var unzip := ZIPReader.new()
var _zip_failed:bool = false
var _zip_game:Dictionary = {}
func _on_update_pressed(button:Button, game:Dictionary) -> void:
	console.visible = true
	_zip_failed = false
	_zip_game = game
	var url_mod:String = Manager.mod_data[Manager.data_local.lang]["patch"][game.shortname]
	Manager.create_request(self,"_on_downloaded_zip",url_mod)
	console_add_text("Downloading patch...")
	button.disabled = true
	yield(self,"_zip_downloaded")
	if _zip_failed:
		Manager.show_message(-1,"[color=red] DOWNLOAD ERROR[/color]")
		button.disabled = false
		return
	Manager.show_message(-1, "[color=lime]Download finished successfully![/color]")
	var err = unzip.open("user://%s.zip"% game.shortname)
	var game_dir:String = steam_games_dir + game.folder
	if err == OK:
		var file_list:PoolStringArray= unzip.get_files()
		var items:int = file_list.size()
		var item_idx:int = 0
		for file_name in file_list:
			item_idx += 1
			var new_file_name:String = ""
			if file_name.ends_with("/"): continue #ignore this file since its a folder
			
			if "/" in file_name:
				new_file_name = file_name.replace("/","\\") # make the directory
			
			if new_file_name == "":
				new_file_name = file_name
			var full_dir:String = game_dir+"\\%s" % new_file_name
			var _file := File.new()
			var error = _file.open(full_dir,File.WRITE)
			if error != OK:
				console_add_text("Error opening %s, Error: %d" % [new_file_name, error])
				continue
				pass
			var buffer:PoolByteArray = unzip.read_file(file_name)
			
			if buffer.size() == 0:
				Manager.show_message(-1, "Failed uncompress: %s" % file_name )
				continue
			console_add_text("[%d/%d] - Extracting: %s" % [item_idx,items, new_file_name])
			_file.store_buffer(buffer)
			_file.close()
			yield(get_tree(),"idle_frame")
			pass
		pass
	else:
		Manager.show_message(-1, "[color=red]Failed loading zip file: %d[/color]" % err)
		unzip.close()
	unzip.close()
	console.visible = false
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
	emit_signal("_zip_downloaded")
	pass


func _on_bt_reset_pressed() -> void:
	_detect_steam_games()
	pass # Replace with function body.
