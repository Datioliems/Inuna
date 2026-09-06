extends CharacterBody3D
class_name AnimalNPC

var material_library: Node
var npc_id := "animal_npc"
var species := "cat"
var display_name := "Ban nho"
var dialogue := "Minh dang tim lai mot ky uc diu dang..."
var profile_id := "toon_cat_soft"
var path_points := []
var path_index := 0
var mood := "waiting"
var visual_root: Node3D
var label: Label3D
var idle_time := 0.0

func setup(config: Dictionary, library: Node) -> void:
	npc_id = str(config.get("npc_id", npc_id))
	species = str(config.get("species", species))
	display_name = str(config.get("display_name", display_name))
	dialogue = str(config.get("dialogue", dialogue))
	profile_id = str(config.get("profile_id", profile_id))
	path_points = config.get("path_points", [])
	material_library = library

func _ready() -> void:
	name = npc_id
	add_to_group("animal_npc")
	_build_collision()
	_build_visual()
	_build_label()

func _physics_process(delta: float) -> void:
	idle_time += delta
	if path_points.size() > 0:
		var target: Vector3 = path_points[path_index]
		var delta_pos := target - global_position
		delta_pos.y = 0.0
		if delta_pos.length() < 0.25:
			path_index = (path_index + 1) % path_points.size()
		else:
			var dir := delta_pos.normalized()
			velocity.x = dir.x * 0.75
			velocity.z = dir.z * 0.75
			rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 1.0 - exp(-5.0 * delta))
			move_and_slide()
	_update_visual()

func set_healed() -> void:
	mood = "healed"
	dialogue = "Cam on cau. Noi nay nghe am hon roi."
	if label != null:
		label.text = "%s\n%s" % [display_name, dialogue]

func _build_collision() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 0.8
	shape.shape = capsule
	shape.position.y = 0.45
	add_child(shape)

func _build_visual() -> void:
	if material_library == null:
		return
	visual_root = Node3D.new()
	visual_root.name = "Visual"
	visual_root.position.y = 0.35
	add_child(visual_root)
	match species:
		"parrot":
			_build_parrot()
		"duck":
			_build_duck()
		"chicken":
			_build_chicken()
		"horse":
			_build_horse()
		_:
			_build_cat()

func _build_cat() -> void:
	_add_part("Body", material_library.make_sphere(), Vector3(0, 0.18, 0), Vector3(0.42, 0.24, 0.30), Vector3.ZERO, 31)
	_add_part("Head", material_library.make_sphere(), Vector3(0, 0.44, -0.28), Vector3(0.24, 0.22, 0.22), Vector3.ZERO, 32)
	_add_part("EarL", material_library.make_cone(0.08, 0.20), Vector3(-0.14, 0.64, -0.28), Vector3.ONE, Vector3(0.25, 0, 0.18), 33)
	_add_part("EarR", material_library.make_cone(0.08, 0.20), Vector3(0.14, 0.64, -0.28), Vector3.ONE, Vector3(0.25, 0, -0.18), 34)
	_add_part("Tail", material_library.make_cylinder(0.035, 0.48), Vector3(0, 0.34, 0.34), Vector3.ONE, Vector3(1.0, 0, 0), 35)

func _build_parrot() -> void:
	_add_part("Body", material_library.make_sphere(), Vector3(0, 0.20, 0), Vector3(0.24, 0.34, 0.22), Vector3.ZERO, 41)
	_add_part("Head", material_library.make_sphere(), Vector3(0, 0.55, -0.02), Vector3(0.18, 0.18, 0.18), Vector3.ZERO, 42)
	_add_part("WingL", material_library.make_box(Vector3(0.06, 0.26, 0.22)), Vector3(-0.24, 0.22, 0), Vector3.ONE, Vector3(0, 0, -0.25), 43)
	_add_part("WingR", material_library.make_box(Vector3(0.06, 0.26, 0.22)), Vector3(0.24, 0.22, 0), Vector3.ONE, Vector3(0, 0, 0.25), 44)

func _build_duck() -> void:
	_add_part("Body", material_library.make_sphere(), Vector3(0, 0.18, 0), Vector3(0.34, 0.22, 0.28), Vector3.ZERO, 51)
	_add_part("Head", material_library.make_sphere(), Vector3(0, 0.42, -0.25), Vector3(0.18, 0.18, 0.18), Vector3.ZERO, 52)

func _build_chicken() -> void:
	_add_part("Body", material_library.make_sphere(), Vector3(0, 0.20, 0), Vector3(0.28, 0.34, 0.24), Vector3.ZERO, 61)
	_add_part("Head", material_library.make_sphere(), Vector3(0, 0.55, -0.14), Vector3(0.16, 0.16, 0.16), Vector3.ZERO, 62)
	_add_part("Comb", material_library.make_cone(0.06, 0.16), Vector3(0, 0.72, -0.14), Vector3.ONE, Vector3.ZERO, 63)

func _build_horse() -> void:
	_add_part("Body", material_library.make_sphere(), Vector3(0, 0.36, 0), Vector3(0.62, 0.30, 0.36), Vector3(0, 0, PI * 0.5), 71)
	_add_part("Head", material_library.make_sphere(), Vector3(0, 0.63, -0.52), Vector3(0.22, 0.26, 0.24), Vector3.ZERO, 72)
	_add_part("Mane", material_library.make_box(Vector3(0.08, 0.25, 0.45)), Vector3(0, 0.72, -0.14), Vector3.ONE, Vector3.ZERO, 73)

func _add_part(part_name: String, mesh: Mesh, pos: Vector3, scale: Vector3, rot: Vector3, seed: int) -> void:
	var basis := Basis.from_euler(rot).scaled(scale)
	material_library.add_toon_mesh(visual_root, mesh, profile_id, part_name, Transform3D(basis, pos), seed, true)

func _build_label() -> void:
	label = Label3D.new()
	label.name = "DialogueBubble"
	label.text = "%s\n%s" % [display_name, dialogue]
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = Color("#1f2a2b")
	label.outline_modulate = Color("#f5edd2")
	label.outline_size = 8
	label.font_size = 34
	label.position = Vector3(0, 1.35, 0)
	label.visible = species == "cat"
	add_child(label)

func _update_visual() -> void:
	if visual_root == null:
		return
	var intensity := 0.08 if mood == "healed" else 0.04
	visual_root.position.y = 0.35 + sin(idle_time * 2.0) * intensity
	visual_root.rotation.z = sin(idle_time * 1.4) * 0.03
