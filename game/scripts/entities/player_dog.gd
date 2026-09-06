extends CharacterBody3D
class_name PlayerDog

var material_library: Node
var current_surface := "dry"
var animation_state := "idle"
var emote_state := "calm"
var walk_weight := 0.0
var run_weight := 0.0

@export var movement_speed := 3.0
@export var run_speed := 5.0
@export var turn_speed := 9.0
@export var gravity := 18.0

var visual_root: Node3D
var body_parts := []
var bob_time := 0.0

func _ready() -> void:
	name = "PlayerDog"
	add_to_group("player_dog")
	_build_collision()
	_build_visual()

func _physics_process(delta: float) -> void:
	var input_vec := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	var camera := get_viewport().get_camera_3d()
	var direction := Vector3.ZERO
	if input_vec.length() > 0.05 and camera != null:
		var cam_forward := -camera.global_transform.basis.z
		var cam_right := camera.global_transform.basis.x
		cam_forward.y = 0.0
		cam_right.y = 0.0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()
		direction = (cam_right * input_vec.x + cam_forward * input_vec.y).normalized()

	var running := Input.is_action_pressed("run")
	var target_speed := run_speed if running else movement_speed
	velocity.x = direction.x * target_speed
	velocity.z = direction.z * target_speed
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.05
	move_and_slide()

	if direction.length() > 0.01:
		var target_yaw := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-turn_speed * delta))

	var moving := Vector2(velocity.x, velocity.z).length() > 0.1
	animation_state = "run" if moving and running else ("walk" if moving else "idle")
	walk_weight = move_toward(walk_weight, 1.0 if animation_state == "walk" else 0.0, delta * 5.0)
	run_weight = move_toward(run_weight, 1.0 if animation_state == "run" else 0.0, delta * 5.0)
	_update_surface()
	_animate_visual(delta)

func _build_collision() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.2
	shape.shape = capsule
	shape.position.y = 0.65
	add_child(shape)

func _build_visual() -> void:
	if material_library == null:
		return
	visual_root = Node3D.new()
	visual_root.name = "VietnameseDogVisual"
	visual_root.position.y = 0.55
	add_child(visual_root)

	_add_part("Body", material_library.make_sphere(), "toon_dog_vietnamese", Vector3(0, 0.28, 0), Vector3(0.78, 0.36, 0.42), Vector3(0, 0, PI * 0.5), 1)
	_add_part("ChestMarking", material_library.make_sphere(), "toon_memory", Vector3(0, 0.30, -0.34), Vector3(0.32, 0.22, 0.08), Vector3.ZERO, 2, false)
	_add_part("Head", material_library.make_sphere(), "toon_dog_vietnamese", Vector3(0, 0.72, -0.56), Vector3(0.34, 0.30, 0.32), Vector3.ZERO, 3)
	_add_part("Muzzle", material_library.make_sphere(), "toon_village", Vector3(0, 0.66, -0.86), Vector3(0.20, 0.13, 0.18), Vector3.ZERO, 4)
	_add_part("Nose", material_library.make_sphere(), "toon_cat_soft", Vector3(0, 0.69, -1.00), Vector3(0.07, 0.045, 0.035), Vector3.ZERO, 5, false)
	_add_part("LeftEar", material_library.make_cone(0.12, 0.34), "toon_dog_vietnamese", Vector3(-0.23, 0.98, -0.55), Vector3(0.9, 1.0, 0.75), Vector3(0.35, 0.0, 0.35), 6)
	_add_part("RightEar", material_library.make_cone(0.12, 0.34), "toon_dog_vietnamese", Vector3(0.23, 0.98, -0.55), Vector3(0.9, 1.0, 0.75), Vector3(0.35, 0.0, -0.35), 7)
	_add_part("Tail", material_library.make_cylinder(0.055, 0.55), "toon_dog_vietnamese", Vector3(0, 0.55, 0.55), Vector3(1, 1, 1), Vector3(1.1, 0.0, 0.0), 8)
	for i in range(4):
		var x := -0.32 if i % 2 == 0 else 0.32
		var z := -0.25 if i < 2 else 0.30
		_add_part("Leg%s" % i, material_library.make_cylinder(0.07, 0.48), "toon_dog_vietnamese", Vector3(x, -0.05, z), Vector3(1, 1, 1), Vector3.ZERO, 10 + i)

func _add_part(part_name: String, mesh: Mesh, profile: String, pos: Vector3, scale: Vector3, rot: Vector3, seed: int, add_outline := true) -> void:
	var basis := Basis.from_euler(rot).scaled(scale)
	var item: MeshInstance3D = material_library.add_toon_mesh(visual_root, mesh, profile, part_name, Transform3D(basis, pos), seed, add_outline)
	body_parts.append(item)

func _animate_visual(delta: float) -> void:
	if visual_root == null:
		return
	bob_time += delta * (5.0 if animation_state == "run" else (3.2 if animation_state == "walk" else 1.2))
	var amp := 0.045 if animation_state != "idle" else 0.014
	visual_root.position.y = 0.55 + sin(bob_time) * amp
	visual_root.rotation.z = sin(bob_time * 0.7) * (0.03 if animation_state != "idle" else 0.012)

func _update_surface() -> void:
	var p := global_position
	current_surface = "water" if abs(p.x) < 1.35 and p.z > -7.0 and p.z < 7.0 else "dry"
