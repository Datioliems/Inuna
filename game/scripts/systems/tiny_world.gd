extends Node3D
class_name TinyWorld

var material_library: Node
var healed := false
var audio_zones := []
var world_environment: WorldEnvironment
var healing_glow_root: Node3D

func build() -> void:
	name = "TinyWorld"
	_build_light()
	_build_ground()
	_build_water()
	_build_village()
	_build_forest()
	_build_healed_state_visuals()
	_build_zone_markers()

func get_audio_zones() -> Array:
	return audio_zones

func set_healed(value: bool) -> void:
	healed = value
	if healing_glow_root != null:
		healing_glow_root.visible = healed
	if world_environment != null and world_environment.environment != null:
		world_environment.environment.background_color = Color("#9bded2") if healed else Color("#8ed6cf")
		world_environment.environment.ambient_light_color = Color("#fff0ca") if healed else Color("#d6eadf")
	for child in get_children():
		if child.is_in_group("healable_world"):
			child.set_meta("healed_tint", Color(1.1, 1.08, 0.95, 1.0))

func _build_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "WarmLowSun"
	sun.light_energy = 1.7
	sun.rotation_degrees = Vector3(-48, -32, 0)
	add_child(sun)
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#8ed6cf")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d6eadf")
	env.ambient_light_energy = 0.55
	world_env.environment = env
	add_child(world_env)
	world_environment = world_env

func _build_ground() -> void:
	var ground_mesh := CylinderMesh.new()
	ground_mesh.top_radius = 11.0
	ground_mesh.bottom_radius = 10.7
	ground_mesh.height = 0.55
	ground_mesh.radial_segments = 48
	var ground: MeshInstance3D = material_library.add_toon_mesh(self, ground_mesh, "toon_leaf", "FloatingIsland", Transform3D(Basis(), Vector3(0, -0.28, 0)), 101, true)
	ground.add_to_group("healable_world")
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 11.0
	shape.height = 0.55
	collision.shape = shape
	body.add_child(collision)
	body.position.y = -0.28
	add_child(body)

func _build_water() -> void:
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(2.6, 15.0)
	mesh.subdivide_width = 8
	mesh.subdivide_depth = 32
	var river := MeshInstance3D.new()
	river.name = "GentleRiver"
	river.mesh = mesh
	river.position = Vector3(0, 0.02, 0)
	river.rotation_degrees.y = 0
	river.set_surface_override_material(0, material_library.get_water_material())
	add_child(river)
	var bridge: MeshInstance3D = material_library.add_toon_mesh(self, material_library.make_box(Vector3(3.8, 0.15, 1.0)), "toon_village", "SmallBridge", Transform3D(Basis(), Vector3(0, 0.20, -1.9)), 120, true)
	bridge.add_to_group("healable_world")
	audio_zones.append({"zone_name": "river", "center": Vector3(0, 0, 0), "radius": 3.0, "fade_margin": 2.2, "target_volume": 0.75, "priority": 3})

func _build_village() -> void:
	for i in range(4):
		var angle := -0.65 + float(i) * 0.42
		var pos := Vector3(cos(angle) * 6.8, 0.25, sin(angle) * 6.8)
		var house := Node3D.new()
		house.name = "VillageHouse%s" % i
		house.position = pos
		add_child(house)
		house.look_at(Vector3.ZERO, Vector3.UP)
		material_library.add_toon_mesh(house, material_library.make_box(Vector3(1.35, 1.2, 1.0)), "toon_village", "HouseBody", Transform3D(Basis(), Vector3.ZERO), 130 + i, true)
		material_library.add_toon_mesh(house, material_library.make_cone(0.95, 0.55, 4), "toon_dog_vietnamese", "SoftRoof", Transform3D(Basis.from_euler(Vector3(0, PI * 0.25, 0)), Vector3(0, 0.86, 0)), 150 + i, true)
	audio_zones.append({"zone_name": "village", "center": Vector3(5.5, 0, -3.0), "radius": 5.2, "fade_margin": 2.5, "target_volume": 0.58, "priority": 2})

func _build_forest() -> void:
	for i in range(18):
		var angle := 1.4 + float(i) * 0.22
		var radius := 5.8 + fposmod(float(i) * 1.37, 2.4)
		var pos := Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)
		var tree := Node3D.new()
		tree.name = "SoftTree%s" % i
		tree.position = pos
		tree.add_to_group("wind_sway")
		add_child(tree)
		material_library.add_toon_mesh(tree, material_library.make_cylinder(0.12, 0.85, 10), "toon_village", "Trunk", Transform3D(Basis(), Vector3(0, 0.35, 0)), 200 + i, true)
		material_library.add_toon_mesh(tree, material_library.make_sphere(), "toon_leaf", "Leaves", Transform3D(Basis().scaled(Vector3(0.55, 0.48, 0.55)), Vector3(0, 1.0, 0)), 230 + i, true)
	audio_zones.append({"zone_name": "forest", "center": Vector3(-5.6, 0, 5.7), "radius": 5.0, "fade_margin": 2.5, "target_volume": 0.66, "priority": 2})

func _build_healed_state_visuals() -> void:
	healing_glow_root = Node3D.new()
	healing_glow_root.name = "HealingWorldStateGlow"
	healing_glow_root.visible = false
	add_child(healing_glow_root)
	for i in range(14):
		var angle := float(i) / 14.0 * TAU
		var radius := 2.4 + fposmod(float(i) * 0.41, 1.8)
		var pos := Vector3(cos(angle) * radius, 0.32 + fposmod(float(i) * 0.17, 0.35), sin(angle) * radius)
		material_library.add_toon_mesh(healing_glow_root, material_library.make_sphere(0.08, 6, 8), "toon_memory", "WarmSpeck%s" % i, Transform3D(Basis(), pos), 620 + i, false)
	var healed_label := Label3D.new()
	healed_label.name = "HealedStateLabel"
	healed_label.text = "am lai"
	healed_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	healed_label.font_size = 32
	healed_label.modulate = Color("#654f2a")
	healed_label.outline_modulate = Color("#fff0ca")
	healed_label.outline_size = 8
	healed_label.position = Vector3(0, 1.0, -1.9)
	healing_glow_root.add_child(healed_label)

func _build_zone_markers() -> void:
	for zone in audio_zones:
		var label := Label3D.new()
		label.text = str(zone["zone_name"])
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 42
		label.modulate = Color("#223333")
		label.outline_modulate = Color("#f5edd2")
		label.outline_size = 6
		label.position = zone["center"] + Vector3(0, 0.08, 0)
		add_child(label)
