extends Button
class_name ButtonKey

export(String) var key : String = ""


func _ready() -> void:
	if key:
		set_key(key)
	else:
		set_key(text)


func set_key(new_key : String) -> void:
	if new_key:
		text = tr(new_key)