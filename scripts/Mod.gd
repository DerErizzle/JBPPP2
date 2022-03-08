extends Panel
class_name Mod

var http_request = HTTPRequest.new()

func _ready():
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Display the image in a TextureRect node.
	$VBoxContainer/tr_flag.texture = texture

func configure(lang:String, country_code:String, button_name:String = "") -> void:
	
	$VBoxContainer/Label.text = lang
	$VBoxContainer/Button.connect("pressed",self,"_on_pressed")
	
	if button_name != "":
		$VBoxContainer/Button.text = button_name
	
		# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(Manager.REMOTE_FILES.URL_FLAG % country_code)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_pressed() -> void:
	
	pass


func _on_VBoxContainer_resized() -> void:
	rect_size.y = $VBoxContainer.rect_size.y
	pass # Replace with function body.
