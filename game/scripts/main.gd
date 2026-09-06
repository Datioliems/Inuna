extends Node3D

const MaterialLibraryScript := preload("res://scripts/systems/material_library.gd")
const PlayerDogScript := preload("res://scripts/entities/player_dog.gd")
const AnimalNPCScript := preload("res://scripts/entities/animal_npc.gd")
const TinyWorldScript := preload("res://scripts/systems/tiny_world.gd")
const ThirdPersonCameraScript := preload("res://scripts/systems/third_person_camera.gd")
const AudioDirectorScript := preload("res://scripts/systems/audio_director.gd")
const NatureSystemScript := preload("res://scripts/systems/nature_system.gd")
const HealingQuestScript := preload("res://scripts/systems/healing_quest.gd")
const HudScript := preload("res://scripts/systems/ui_hud.gd")

var material_library: Node
var player: Node3D
var world: Node3D
var audio_director: Node
var quest: Node

func _ready() -> void:
	_ensure_input_actions()
	material_library = MaterialLibraryScript.new()
	add_child(material_library)
	material_library.load_profiles()

	world = TinyWorldScript.new()
	world.material_library = material_library
	add_child(world)
	world.build()

	player = PlayerDogScript.new()
	player.material_library = material_library
	add_child(player)
	player.global_position = Vector3(2.8, 0.6, 2.6)

	var cat := AnimalNPCScript.new()
	cat.setup({
		"npc_id": "cat_npc",
		"species": "cat",
		"display_name": "Meo con",
		"dialogue": "Minh nghe tieng song nhung khong nho duong ve nha.",
		"profile_id": "toon_cat_soft",
		"path_points": [Vector3(3.0, 0.55, -2.2), Vector3(4.2, 0.55, -1.0), Vector3(3.1, 0.55, 0.1)]
	}, material_library)
	add_child(cat)
	cat.global_position = Vector3(3.0, 0.55, -2.2)

	_spawn_background_animals()

	var camera_rig := ThirdPersonCameraScript.new()
	camera_rig.target = player
	add_child(camera_rig)
	camera_rig.global_position = player.global_position + Vector3(0, 2.5, 5.2)

	audio_director = AudioDirectorScript.new()
	add_child(audio_director)
	audio_director.setup(player, world)

	var nature := NatureSystemScript.new()
	add_child(nature)
	nature.setup(material_library)

	quest = HealingQuestScript.new()
	add_child(quest)
	quest.setup(player, world, material_library, cat)

	var hud := HudScript.new()
	add_child(hud)
	hud.setup(player, quest, audio_director)

func _spawn_background_animals() -> void:
	var configs := [
		{"npc_id": "parrot_npc", "species": "parrot", "display_name": "Vet", "profile_id": "toon_bird_parrot", "dialogue": "chip chip", "pos": Vector3(-3.6, 0.7, 4.0)},
		{"npc_id": "duck_npc", "species": "duck", "display_name": "Vit", "profile_id": "toon_memory", "dialogue": "quack", "pos": Vector3(-0.8, 0.45, 4.6)},
		{"npc_id": "chicken_npc", "species": "chicken", "display_name": "Ga", "profile_id": "toon_dog_vietnamese", "dialogue": "cuc tac", "pos": Vector3(5.8, 0.5, -4.8)},
		{"npc_id": "horse_npc", "species": "horse", "display_name": "Ngua", "profile_id": "toon_village", "dialogue": "hmmm", "pos": Vector3(-6.5, 0.55, -1.2)}
	]
	for config in configs:
		var npc := AnimalNPCScript.new()
		npc.setup(config, material_library)
		add_child(npc)
		npc.global_position = config["pos"]

func _ensure_input_actions() -> void:
	var actions := {
		"move_forward": [KEY_W, KEY_UP],
		"move_back": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"run": [KEY_SHIFT],
		"interact": [KEY_E]
	}
	for action in actions.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in actions[action]:
			var exists := false
			for event in InputMap.action_get_events(action):
				if event is InputEventKey and event.physical_keycode == keycode:
					exists = true
			if not exists:
				var event_key := InputEventKey.new()
				event_key.physical_keycode = keycode
				InputMap.action_add_event(action, event_key)
