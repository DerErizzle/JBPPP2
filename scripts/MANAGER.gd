extends Node

enum ERROR { STEAM_NOT_FOUND, LIBRARY_PATH_NOT_FOUND }

func show_error_message(error_id:int, extra_msg:String="") -> void:
	var msg:String = ": %s" % extra_msg
	match error_id:
		ERROR.STEAM_NOT_FOUND: printerr("STEAM NOT FOUND" + msg)
		ERROR.LIBRARY_PATH_NOT_FOUND: printerr("LIBRARY VDF NOT FOUND" + msg)
	pass
