extends MotionState
class_name WaitState

export(String) var animation : String = "prepare"
export(String) var next_state := ""
export var skip_to_next_state := false
export(bool) var wait_forever := false
export(float) var duration_variation : float = 0.0
export(bool) var stagger := false
export var launch_stagger := false
export(NodePath) var target_node
export var look_direction := Vector2()
export var face_target := true

onready var timer : Timer = $Timer
onready var duration : float = $Timer.wait_time


func enter(args := {}) -> void:
	.enter(args)
	
	if skip_to_next_state:
		go_to_next_state()
		return
	
	if args.has("initial_animation"):
		owner.animation_player.play(args["initial_animation"])
	else:
		owner.animation_player.play(animation)
	
	if look_direction:
		update_look_direction(look_direction)
	elif args.has("look_direction"):
		update_look_direction(args["look_direction"])
	
	if wait_forever:
		return
	timer.start(duration + randf() * duration_variation)


func exit() -> void:
	.exit()
	timer.stop()


func _physics_process(delta):
	move(Vector2())
	if face_target and owner.target.get_target() and not look_towards_move_direction:
		owner.update_look_direction(owner.global_position.direction_to(owner.target.global_position))


func take_damage(args := {}):
	if launch_stagger:
		finished("LaunchStagger", args)
		return
	if stagger:
		finished("Stagger", args)


func go_to_next_state() -> void:
	var args = {
		"velocity": steering.velocity, 
		"gravity_speed":gravity.speed,
		"external": {
			"velocity" : external.velocity,
			"target_direction" : external.target_direction,
			"target_speed" : external.target_speed,
			"mass" : external.mass
		}
	}
	
	var target
	if target_node:
		target = get_node(target_node)
	if not target:
		owner.target.lock_on()
		target = owner.target.get_target()
	if target:
		var target_position = target.global_position
		var target_direction = (target_position - owner.global_position).normalized()
		args["target_direction"] = target_direction
		args["target_position"] = target_position
	finished(next_state, args)


func _on_Timer_timeout():
	go_to_next_state()


func anim_finished(anim_name : String) -> void:
	owner.animation_player.play(animation)


func pause() -> void:
	.pause()
	if timer:
		timer.paused = true


func unpause() -> void:
	.unpause()
	if timer:
		timer.paused = false
