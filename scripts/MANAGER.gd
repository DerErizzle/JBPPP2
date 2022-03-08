extends Node

signal done_download
signal data_file

const REMOTE_FILES:Dictionary = {
	URL_LOCATIONS = "https://raw.githubusercontent.com/DerErizzle/JBPPP2/data/locations.json",
	URL_GAME_DATA = "https://raw.githubusercontent.com/DerErizzle/JBPPP2/data/game_data.json",
	URL_FLAG = "https://flagcdn.com/w160/%s.jpg",
}

enum ERROR { STEAM_NOT_FOUND, LIBRARY_PATH_NOT_FOUND, CONNECTION_ERROR, IMAGE_CORRUPTED }
enum SCREEN {MAIN, SETTINGS}

var screen_main:Control
var last_screen:Control = null
var screen_settings:Control

var game_data:Dictionary = {}
var mod_data:Dictionary = {}
var data_local:Dictionary = {}

var tween : Tween = Tween.new()
var dir: Directory = Directory.new()
var file: File = File.new()

var main:Main = null

onready var _msgContainer = get_tree().get_nodes_in_group("MC")[0]
const msg_box_scene = preload("res://stuff/msg_box.tscn")
func _ready() -> void:
	
	if not dir.dir_exists("user://icons"):
		dir.make_dir_recursive("user://icons")
	
	connect("done_download",self,"_on_downloaded")
	_download_necessary_files()
	
	screen_main = get_tree().root.get_node("Main/Screen")
	screen_settings = get_tree().root.get_node("Main/Settings")
	last_screen = screen_settings
	
	add_child(tween)

func show_message(error_id:int=-1, extra_msg:String="") -> void:
	var msg_box:MsgBox = msg_box_scene.instance()
	
	
	var msg:String = ": %s" % extra_msg
	match error_id:
		ERROR.STEAM_NOT_FOUND: msg_box.set_message("STEAM NOT FOUND" + msg)
		ERROR.LIBRARY_PATH_NOT_FOUND: msg_box.set_message("LIBRARY VDF NOT FOUND" + msg)
		ERROR.CONNECTION_ERROR: msg_box.set_message("CONNECTION ERROR" + msg)
		ERROR.IMAGE_CORRUPTED: msg_box.set_message("IMAGE CORRUPTED" + msg)
		_: msg_box.set_message(extra_msg)
	
	_msgContainer.get_child(0).add_child(msg_box)
	pass

func set_game_data(data:Dictionary) -> void:
	game_data = data

func change_screen(idx:int) -> void:

	var target_screen:Control = null
	
	match idx:
		0:
			target_screen = screen_main
		1:
			target_screen = screen_settings
	print(target_screen.name)
	print(last_screen.name)
	
	if target_screen.has_method("screen_just_entered"):
		target_screen.screen_just_entered()
	
	tween.interpolate_property(last_screen,"rect_position",Vector2.ZERO,Vector2(-1290,0),.5,Tween.TRANS_EXPO,Tween.EASE_IN)
	tween.interpolate_property(target_screen,"rect_position",Vector2(1290,0),Vector2.ZERO,.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
	tween.start()
	
	last_screen = target_screen
	pass

func _download_necessary_files() -> void:
	
	# Download `locations.json`
	
	var http_loc := HTTPRequest.new()
	add_child(http_loc)
	http_loc.connect("request_completed",self,"_on_requested_locations")
	http_loc.request(REMOTE_FILES.URL_LOCATIONS)
	
	# Download `game_data.json`
	 
	var http_game := HTTPRequest.new()
	add_child(http_game)
	http_game.connect("request_completed",self,"_on_requested_games")
	http_game.request(REMOTE_FILES.URL_GAME_DATA)
	
	pass

signal locations_downloaded
var downloaded_locations := false
func _on_requested_locations(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	if response_code != 200:
		show_message(ERROR.CONNECTION_ERROR,str({method="_on_requested_locations",res = result, response = response_code, b = body.get_string_from_utf8()}))
		return
		
	mod_data = parse_json(body.get_string_from_utf8())

	show_message(-1, "[color=yellow]Downloaded locations.json[/color]")
	emit_signal("locations_downloaded")
	var downloaded_locations = true
	
	pass

func _on_requested_games(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if response_code != 200:
		show_message(ERROR.CONNECTION_ERROR,str({method="_on_requested_games",res = result, response = response_code, b = body.get_string_from_utf8()}))
		return
	
	game_data = parse_json(body.get_string_from_utf8())
#	print("DOWNLOADED GAME DATA: ", game_data)
	
	# Download `icons`
	
	for game in game_data.games:
		
		if file.file_exists("user://icons/%s.png" % game.shortname):
			print("Found %s.png..." % game.shortname)
			continue
		
		var http_icon := HTTPRequest.new()
		add_child(http_icon)
		http_icon.connect("request_completed",self,"_on_requested_icon",[http_icon, game.title, game.shortname])
		http_icon.request(game.icon)
	
	show_message(-1, "[color=yellow]Downloaded game_data.json[/color]")
	emit_signal("done_download")
	pass

func _on_requested_icon(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, http:HTTPRequest, title:String, shortname:String) -> void:
	if response_code != 200:
		show_message(ERROR.CONNECTION_ERROR,str({method="_on_requested_icon",icon=title,res = result, response = response_code, b = body.get_string_from_utf8()}))
		return
	call_deferred("remove_child",http)
	
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		show_message(ERROR.IMAGE_CORRUPTED, "Error creating image: "+ title)
		return
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	var err = ResourceSaver.save("user://icons/%s.png" % shortname, texture)
	if err != OK:
		show_message(ERROR.IMAGE_CORRUPTED, "Error Saving image: "+title)
		return


func _on_downloaded() -> void:
	while mod_data.empty():
		yield(get_tree(),"idle_frame")
	_check_existing_data()
	pass

func _check_existing_data() -> void:
	
	var file := File.new()
	var found:bool = false
	show_message(-1, "Checking for existing data file")
	var err = file.open("user://data.dict",File.READ_WRITE)
	if err != OK:
		show_message(-1, "No data found, creating one..")
		file.open("user://data.dict",File.WRITE)
		data_local = {last_opened=OS.get_datetime()}
		file.store_var(data_local)
		found = false
	else:
		data_local = file.get_var()
		show_message(-1,"Existing data loaded " )
		found = true
		pass
	emit_signal("data_file",found)
	file.close()
	pass

var _saving:bool = false
func save_data() -> void:
	if _saving:
		while(_saving):
			yield(get_tree().create_timer(.5,false),"timeout")
	_saving = true
	
	var file := File.new()
	file.open("user://data.dict",File.WRITE)
	file.store_var(data_local)
	print("saved: ", data_local)
	file.close()
	_saving = false
	
	pass

func create_request(target:Node,completed_function:String, url:String,extra_data:Array=[]) -> HTTPRequest:
	
	var http:HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed",target,completed_function,extra_data)
	http.request(url)
	return http
	pass

func get_float_from_string(string:String) -> float:
	var result:float = -1
	
	var regex:RegEx = RegEx.new()
	regex.compile("[+-]?([0-9]*[.])?[0-9]+")
	var _match:RegExMatch = regex.search(string)
	result = float(_match.get_string())
	
	return result
