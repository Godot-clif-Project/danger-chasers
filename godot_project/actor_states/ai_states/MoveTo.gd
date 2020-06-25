extends State
class_name MoveToState

export var animation := "walk"
export var next_state := ""
export var go_to_target := true
export var y_offset := 0.0
export var max_roam_radius := 600.0
export var min_roam_radius := 0.0
export var disable_obstacle_collider := false
export var stagger := false

onready var motion := $Motion
onready var timer := $Timer

var target_position : Vector2 = Vector2()
var start_position : Vector2 = Vector2()


func enter(args := {}) -> void:
	.enter(args)
	motion.enter(args)
	if owner.animation_player.has_animation(animation):
		owner.animation_player.play(animation)
	start_position = owner.global_position
	if disable_obstacle_collider \
			or (args.has("disable_collider_in_state") and args["disable_collider_in_state"] == true):
		owner.set_collision_mask_bit(GameManager.Layers.OBSTACLES, false)
	else:
		timer.start()
	if args.has("target_position"):
		target_position = args["target_position"]
	else:
		target_position = calculate_new_target_position()


func exit() -> void:
	.exit()
	motion.exit()
	timer.stop()
	owner.set_collision_mask_bit(GameManager.Layers.OBSTACLES, true)


func _physics_process(delta : float) -> void:
	var buffer = 6.0
	motion.move_to(target_position)
	if owner.global_position.distance_to(target_position) < motion.steering.arrive_distance:
		finished(next_state)


func calculate_new_target_position() -> Vector2:
	var random_angle = randf() * 2 * PI
	var percent = randf()
	var random_radius = percent * (max_roam_radius - min_roam_radius) + min_roam_radius
	
	var base_position = start_position
	if go_to_target: 
		var target = owner.target.get_target()
		if target:
			base_position = owner.target.get_target().global_position
	base_position.y += y_offset
	base_position += Vector2(cos(random_angle), sin(random_angle)) * random_radius
	return base_position


func take_damage(args := {}):
	if stagger:
		finished("Stagger", args)


func _on_Timer_timeout():
	finished(next_state, motion.get_exit_args())
