extends Control
class_name Main

onready var bt_detect_all = find_node("bt_detect_all")

var dir := Directory.new()
var file := File.new()


var drive_letter:String = ""
var steam_games_dir:String = ""
var found_games_data:Array = [] # this is a multidimentional array = [ [0,1], [0,1] ] -> 0 is appid and 1 is game update version


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
			steam_games_dir = "%s\\Program Files (x86)\\Steam\\steamapps\\common\\" % letter
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
	
	var _match := regex.search_all(contents)
	
	for m in _match:
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
	
	if not detected:
		bt_patch.disabled = true
		lb_version.text = "---"
		lb_status.text = ""
		pass
	else:
		lb_version.text = _get_game_version(data)
		lb_status.text = "TODO"
		pass
#	button.connect("pressed",self,"_on_game_button_pressed", [data])
	game_container.add_child(mod)
	
	
	pass

#func _on_game_button_pressed(data:Dictionary) -> void:
#	data.version = _get_game_version(data)
#	Manager.set_game_data(data)
#	Manager.change_screen(Manager.SCREEN.CONFIG)
#	print("Changin")
#	pass

func _get_game_version(data:Dictionary) -> String:
	
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
