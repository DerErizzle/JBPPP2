extends Control
class_name Settings


const mod_scene = preload("res://stuff/Mod.tscn")

func _ready() -> void:
	Manager.connect("data_file",self,"_on_data_file")
	
	pass

func _on_data_file(existing_data:bool) -> void:
	
	print("DONE LOCATIONS")
	
	Manager.show_message(-1, "Checking languages")
	if  Manager.data_local.has("lang"):
		Manager.change_screen(Manager.SCREEN.MAIN)
	else:
		for child in $GridContainer.get_children():
			child.queue_free()
		for location in Manager.mod_data:
	#		var patch:String = Manager.mod_data[location]["patch"][game]
	#		var version:String = Manager.mod_data[location]["version"][game]
			var country_file:String = Manager.mod_data[location]["country-file"]
#			if $GridContainer.get_node_or_null(country_file) == null: continue
			var bt_mod = mod_scene.instance()
			bt_mod.get_node("VBoxContainer/Button").connect("pressed",self,"_on_selected",[bt_mod, location])
			bt_mod.name = country_file
			$GridContainer.add_child(bt_mod)
			bt_mod.configure(location, country_file, "Select")
			
	#		print("url to > %s <: %s" % [game,patch])
			pass
	
	pass
	
func _on_selected(bt_mod:Mod, location:String) -> void:
	Manager.data_local["lang"] = location
	Manager.save_data()
	Manager.show_message(-1, "Set the patches language to: %s" % location)
	Manager.change_screen(Manager.SCREEN.MAIN)
	pass
