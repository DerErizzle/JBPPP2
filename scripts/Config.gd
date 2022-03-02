extends Control
class_name Config

onready var rtl_title:RichTextLabel = find_node("rtl_title")
onready var rtl_version:RichTextLabel = find_node("rtl_version")

const mod_scene = preload("res://stuff/Mod.tscn")

func _on_bt_back_pressed() -> void:
	for child in $GridContainer.get_children():
		child.queue_free()
	Manager.change_screen(Manager.SCREEN.MAIN)
	pass # Replace with function body.


#emited when changing screens is done
func screen_just_entered() -> void:
	rtl_title.bbcode_text = "[center]%s[/center]" % Manager.game_data.title
	rtl_version.bbcode_text = Manager.game_data.version
	
	var game:String = Manager.game_data.shortname
	
	
	for location in Manager.mod_data:
		print("Location: " + location)
		var patch:String = Manager.mod_data[location]["patch"][game]
		var version:String = Manager.mod_data[location]["version"][game]
		var country_code:String = Manager.mod_data[location]["country-code"]
		var bt_mod = mod_scene.instance()
		$GridContainer.add_child(bt_mod)
		bt_mod.configure(location, country_code)
		
		print("url to > %s <: %s" % [game,patch])
		pass
	
	pass
