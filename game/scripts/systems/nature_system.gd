extends Node3D
class_name NatureSystem

var material_library: Node
var birds := []
var time := 0.0

func setup(library: Node) -> void:
	material_library = library
	_build_birds()
	_build_memory_fireflies()

func _process(delta: float) -> void:
	time += delta
	_update_birds()
	for tree in get_tree().get_nodes_in_group("wind_sway"):
		tree.rotation.z = sin(time * 1.2 + tree.global_position.x) * 0.025

func _build_birds() -> void:
	for i in range(18):
		var bird := Node3D.new()
		bird.name = "PathBird%s" % i
		add_child(bird)
		var wing_mesh: Mesh = material_library.make_box(Vector3(0.18, 0.025, 0.055))
		material_library.add_toon_mesh(bird, wing_mesh, "toon_bird_parrot", "WingA", Transform3D(Basis.from_euler(Vector3(0, 0, 0.25)), Vector3(-0.08, 0, 0)), 300 + i, true)
		material_library.add_toon_mesh(bird, wing_mesh, "toon_bird_parrot", "WingB", Transform3D(Basis.from_euler(Vector3(0, 0, -0.25)), Vector3(0.08, 0, 0)), 330 + i, true)
		birds.append({"node": bird, "phase": float(i) / 18.0 * TAU, "height": 4.5 + fposmod(i * 0.31, 1.7), "radius": 7.8 + fposmod(i * 0.53, 1.6)})

func _update_birds() -> void:
	for item in birds:
		var bird: Node3D = item["node"]
		var phase := float(item["phase"]) + time * 0.28
		var radius := float(item["radius"])
		bird.position = Vector3(cos(phase) * radius, float(item["height"]) + sin(phase * 2.1) * 0.35, sin(phase) * radius)
		bird.rotation.y = -phase + PI * 0.5
		bird.rotation.z = sin(time * 8.0 + phase) * 0.18

func _build_memory_fireflies() -> void:
	for i in range(16):
		var firefly := MeshInstance3D.new()
		firefly.name = "HealingFirefly%s" % i
		firefly.mesh = material_library.make_sphere(0.045, 6, 8)
		firefly.set_surface_override_material(0, material_library.get_material("toon_memory", 400 + i))
		firefly.position = Vector3(cos(i) * 3.0, 0.8 + fposmod(i * 0.37, 1.4), sin(i * 1.7) * 3.0)
		add_child(firefly)
