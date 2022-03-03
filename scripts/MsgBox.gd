extends Panel
class_name MsgBox

onready var tween :Tween = $Tween
var _done:bool = false
var _time:float = 5
func set_message(msg:String) -> void:
	$RichTextLabel.bbcode_text = msg
#	_time = 100 / msg.length() # calculate the message box time visible based on message length

func _ready() -> void:
	tween.connect("tween_completed",self,"_on_completed")
	tween.interpolate_property(self, "modulate",Color(1,1,1,0),Color(1,1,1,1), .3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()

func _on_Button_pressed() -> void:
	queue_free()
	pass # Replace with function body.

func _on_completed(object, key) -> void:
	if _done:
		queue_free()
		return
	_done = true
	yield(get_tree().create_timer(_time,false),"timeout")
	if not is_instance_valid(self): return
	tween.interpolate_property(self, "modulate",Color(1,1,1,1),Color(1,1,1,0), .3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	pass
