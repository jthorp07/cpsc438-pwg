class_name MapCamera
extends Camera2D

var zoom_speed: float = 10.0
var move_speed: float = 1000.0

@onready var zoom_target: Vector2 = zoom


func _process(delta: float) -> void:
	process_zoom(delta)
	process_move(delta)


func process_zoom(delta: float) -> void:
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom_target = zoom_target * 1.1
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom_target = zoom_target * 0.9
	zoom = zoom.slerp(zoom_target, zoom_speed * delta)


func process_move(delta: float) -> void:
	var move_dir:= Vector2.ZERO
	if Input.is_action_pressed("camera_up"):
		move_dir.y -= 1
	if Input.is_action_pressed("camera_down"):
		move_dir.y += 1
	if Input.is_action_pressed("camera_left"):
		move_dir.x -= 1
	if Input.is_action_pressed("camera_right"):
		move_dir.x += 1
	move_dir = move_dir.normalized()
	position = position + move_dir * delta * move_speed * (1.0 / zoom.x)
