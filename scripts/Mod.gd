extends Panel
class_name Mod
#
#var http_request = HTTPRequest.new()
#
#func _ready():
#	add_child(http_request)
#	http_request.connect("request_completed", self, "_http_request_completed")
#

# Called when the HTTP request is completed.
func _create_image(flag_name:String):
	
	var err = Manager.file.open("user://flags/%s.png" % flag_name,File.READ)
	
	if err != OK:
		Manager.show_message(-1, "Error opening: %s.png" % [flag_name])
		return
	
	var image = Image.new()
	var error = image.load_png_from_buffer(Manager.file.get_buffer(Manager.file.get_len()))
	if error != OK:
		Manager.show_message(-1, "Error Loading jpg from buffer: %s.png" % [flag_name])
		return

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Display the image in a TextureRect node.
	$VBoxContainer/tr_flag.texture = texture
	
	print("done")

func configure(lang:String, country_file:String, button_name:String = "") -> void:
	
	$VBoxContainer/Label.text = lang
	$VBoxContainer/Button.connect("pressed",self,"_on_pressed")
	
	if button_name != "":
		$VBoxContainer/Button.text = button_name
	
	
	_create_image(country_file)
	
		# Perform the HTTP request. The URL below returns a PNG image as of writing.
#	var error = http_request.request(Manager.REMOTE_FILES.URL_FLAG % country_code)
#	if error != OK:
#		push_error("An error occurred in the HTTP request.")

func _on_pressed() -> void:
	
	pass


func _on_VBoxContainer_resized() -> void:
	rect_size.y = $VBoxContainer.rect_size.y
	pass # Replace with function body.
