extends SceneTree

const PREVIEW_PATH := "C:/Users/ADMIN/Documents/ChatGPT/Gamification/reference/previews/inuna-first-preview.png"

func _initialize() -> void:
	root.size = Vector2i(1280, 720)
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	image.save_png(PREVIEW_PATH)
	quit()
