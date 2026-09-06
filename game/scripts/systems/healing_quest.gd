extends Node
class_name HealingQuest

signal quest_updated(status_text: String)

var player: Node3D
var world: Node3D
var material_library: Node
var giver_npc: Node3D
var memory_items := []
var collected := {}
var completed := false

func setup(target_player: Node3D, target_world: Node3D, library: Node, npc: Node3D) -> void:
	player = target_player
	world = target_world
	material_library = library
	giver_npc = npc
	_create_memory_items()
	_emit_status()

func _process(_delta: float) -> void:
	if completed or player == null:
		return
	for item in memory_items:
		if item == null:
			continue
		var id := str(item.get_meta("memory_id"))
		if collected.has(id):
			continue
		if player.global_position.distance_to(item.global_position) < 0.75:
			collected[id] = true
			item.visible = false
			_emit_status()
	if collected.size() >= memory_items.size() and player.global_position.distance_to(giver_npc.global_position) < 1.5:
		completed = true
		world.set_healed(true)
		giver_npc.set_healed()
		_emit_status()

func get_status_text() -> String:
	if completed:
		return "Quest: Da giup ban nho binh tam. Khu vuc am hon."
	return "Quest: Tim ky uc diu em %s/%s, roi quay lai meo con." % [collected.size(), memory_items.size()]

func _create_memory_items() -> void:
	var data := [
		{"id": "village_memory", "pos": Vector3(4.8, 0.45, -4.3)},
		{"id": "river_memory", "pos": Vector3(-0.9, 0.38, 2.6)},
		{"id": "forest_memory", "pos": Vector3(-6.5, 0.45, 5.2)}
	]
	for entry in data:
		var node := Node3D.new()
		node.name = entry["id"]
		node.position = entry["pos"]
		node.set_meta("memory_id", entry["id"])
		world.add_child(node)
		var mesh: Mesh = material_library.make_sphere(0.18, 8, 12)
		material_library.add_toon_mesh(node, mesh, "toon_memory", "MemoryGlow", Transform3D(Basis(), Vector3.ZERO), memory_items.size() + 500, true)
		var label := Label3D.new()
		label.text = "ky uc"
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 26
		label.position = Vector3(0, 0.45, 0)
		node.add_child(label)
		memory_items.append(node)

func _emit_status() -> void:
	quest_updated.emit(get_status_text())
