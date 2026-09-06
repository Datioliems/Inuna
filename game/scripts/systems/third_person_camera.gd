extends Node3D
class_name ThirdPersonCamera

var target: Node3D
@export var distance := 5.2
@export var height := 2.4
@export var focus_height := 0.85
@export var follow_smoothing := 7.0
@export var look_smoothing := 10.0

var camera: Camera3D

func _ready() -> void:
	camera = Camera3D.new()
	camera.name = "SoftFollowCamera"
	camera.fov = 48.0
	camera.near = 0.05
	camera.far = 150.0
	add_child(camera)
	camera.current = true

func _process(delta: float) -> void:
	if target == null or camera == null:
		return
	var forward := -target.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized() if forward.length() > 0.01 else Vector3.FORWARD
	var desired := target.global_position - forward * distance + Vector3.UP * height
	global_position = global_position.lerp(desired, 1.0 - exp(-follow_smoothing * delta))
	var focus := target.global_position + Vector3.UP * focus_height
	var desired_transform := global_transform.looking_at(focus, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(desired_transform.basis, 1.0 - exp(-look_smoothing * delta))
	camera.global_transform = global_transform

