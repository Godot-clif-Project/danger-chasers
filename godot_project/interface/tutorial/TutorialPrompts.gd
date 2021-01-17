extends CanvasLayer

onready var animation_player : AnimationPlayer = $AnimationPlayer


func show(key : String) -> void:
	get_node("Prompts/" + key).show()

func hide(key : String) -> void:
	get_node("Prompts/" + key).hide()
