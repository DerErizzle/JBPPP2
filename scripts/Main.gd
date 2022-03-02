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
		Manager.show_error_message(err)
		return
	
	_detect_steam_games()
	
	pass # Replace with function body.

func _detect_drive_letter() -> int:
	
	for i in dir.get_drive_count():
		var letter : String = dir.get_drive(i)
		print(letter)
		var err = file.open("%s\\Program Files (x86)\\Steam\\steamapps\\libraryfolders.vdf" % letter, File.READ)
		if err == OK:
			drive_letter = letter
			steam_games_dir = "%s\\Program Files (x86)\\Steam\\steamapps\\common"
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
		Manager.show_error_message(Manager.ERROR.LIBRARY_PATH_NOT_FOUND, library_folders_path)
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
	
	print(found_games_data)
	
	# Actually detect games
	
	var err  = file.open("res://resources/game_data.json", File.READ)
	if err != OK:
		printerr("game_data.json not found: ", err)
		return
	
	var data = parse_json(file.get_as_text())
	var game_data:Array = data["games"]
	
	for game in game_data:
		print("\nTrying to detect: " + game.title)
		for arr in found_games_data:
			if str(game.appid) == str(arr[0]):
				print("Detected this game :D\n\n")
	
	pass
