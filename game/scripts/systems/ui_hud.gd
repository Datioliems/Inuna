extends CanvasLayer
class_name GameHUD

var player: Node
var quest: Node
var audio_director: Node
var quest_label: Label
var state_label: Label

func setup(target_player: Node, target_quest: Node, target_audio: Node) -> void:
	player = target_player
	quest = target_quest
	audio_director = target_audio
	_build_ui()
	quest.quest_updated.connect(_on_quest_updated)
	_on_quest_updated(quest.get_status_text())

func _process(_delta: float) -> void:
	if state_label == null or player == null or audio_director == null:
		return
	state_label.text = "Dog: %s | Surface: %s | Ambience: %s\nMove: WASD/Arrows  Run: Shift  Goal: collect 3 memories" % [player.animation_state, player.current_surface, audio_director.current_zone]

func _build_ui() -> void:
	var root := Control.new()
	root.name = "HUDRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	quest_label = Label.new()
	quest_label.position = Vector2(24, 22)
	quest_label.add_theme_font_size_override("font_size", 22)
	quest_label.add_theme_color_override("font_color", Color("#1d292b"))
	quest_label.add_theme_color_override("font_shadow_color", Color("#f2ead0"))
	quest_label.add_theme_constant_override("shadow_offset_x", 2)
	quest_label.add_theme_constant_override("shadow_offset_y", 2)
	root.add_child(quest_label)
	state_label = Label.new()
	state_label.position = Vector2(24, 58)
	state_label.add_theme_font_size_override("font_size", 16)
	state_label.add_theme_color_override("font_color", Color("#203436"))
	state_label.add_theme_color_override("font_shadow_color", Color("#f2ead0"))
	state_label.add_theme_constant_override("shadow_offset_x", 2)
	state_label.add_theme_constant_override("shadow_offset_y", 2)
	root.add_child(state_label)

func _on_quest_updated(status_text: String) -> void:
	if quest_label != null:
		quest_label.text = status_text
