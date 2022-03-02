extends Node


const REMOTE_FILES:Dictionary = {
	URL_LOCATIONS = "https://raw.githubusercontent.com/DerErizzle/JBPPP2/data/locations.json"
}

const URL_FLAG = "https://flagcdn.com/w160/%s.jpg"

enum ERROR { STEAM_NOT_FOUND, LIBRARY_PATH_NOT_FOUND, CONNECTION_ERROR }

func show_error_message(error_id:int, extra_msg:String="") -> void:
	var msg:String = ": %s" % extra_msg
	match error_id:
		ERROR.STEAM_NOT_FOUND: printerr("STEAM NOT FOUND" + msg)
		ERROR.LIBRARY_PATH_NOT_FOUND: printerr("LIBRARY VDF NOT FOUND" + msg)
		ERROR.CONNECTION_ERROR: printerr("CONNECTION ERROR" + msg)
	pass

var game_data:Dictionary = {}
var mod_data:Dictionary = {}

func set_game_data(data:Dictionary) -> void:
	game_data = data

func _ready() -> void:
	
	_download_necessary_files()
	
	screen_main = get_tree().root.get_node("Main/Screen")
	screen_config = get_tree().root.get_node("Main/Config")
	last_screen = screen_main
	add_child(tween)

var tween : Tween = Tween.new()

var screen_main:Control
var screen_config:Control
var last_screen:Control = null

enum SCREEN {MAIN, CONFIG}

func change_screen(idx:int) -> void:

	var target_screen:Control = null
	
	match idx:
		0:
			target_screen = screen_main
		1:
			target_screen = screen_config
	print(target_screen.name)
	print(last_screen.name)
	
	if target_screen.has_method("screen_just_entered"):
		target_screen.screen_just_entered()
	
	tween.interpolate_property(last_screen,"rect_position",Vector2.ZERO,Vector2(-1290,0),.5,Tween.TRANS_EXPO,Tween.EASE_IN)
	tween.interpolate_property(target_screen,"rect_position",Vector2(1290,0),Vector2.ZERO,.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
	tween.start()
	
	last_screen = target_screen
	pass

var http:HTTPRequest = HTTPRequest.new()

func _download_necessary_files() -> void:
	add_child(http)
	http.connect("request_completed",self,"_on_download_finished")
	for link in REMOTE_FILES:
		var url:String = REMOTE_FILES[link]
		print(url)
		http.request(url)
	pass

func _on_download_finished(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	if response_code != 200:
		show_error_message(ERROR.CONNECTION_ERROR,str({res = result, response = response_code, b = body.get_string_from_utf8()}))
		return
	
	mod_data = parse_json(body.get_string_from_utf8())
	print(mod_data)
#	var file = File.new()
#	var err = file.open("user://mod_data.json",File.WRITE)
#
#	file.store_var(mod_data)
#
#	file.close()
	pass
