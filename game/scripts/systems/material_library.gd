extends Node
class_name MaterialLibrary

const ANIMAL_SHADER := preload("res://shaders/toon_animal.gdshader")
const WORLD_SHADER := preload("res://shaders/toon_world.gdshader")
const OUTLINE_SHADER := preload("res://shaders/outline.gdshader")
const WATER_SHADER := preload("res://shaders/water_toon.gdshader")

var profiles := {}
var cached_materials := {}
var outline_materials := {}
var water_material: ShaderMaterial

func _ready() -> void:
	load_profiles()

func load_profiles() -> void:
	var file := FileAccess.open("res://data/material_profiles.json", FileAccess.READ)
	if file == null:
		push_warning("Material profiles not found.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		profiles = parsed

func get_material(profile_id: String, variation_seed: int = 0) -> ShaderMaterial:
	var cache_key := "%s:%s" % [profile_id, variation_seed]
	if cached_materials.has(cache_key):
		return cached_materials[cache_key]
	var profile = profiles.get(profile_id, profiles.get("toon_village", {}))
	var material := ShaderMaterial.new()
	var shader_kind := str(profile.get("shader", "world"))
	material.shader = ANIMAL_SHADER if shader_kind == "animal" else WORLD_SHADER
	var palette: Dictionary = profile.get("palette", {})
	material.set_shader_parameter("shadow_color", Color(palette.get("shadow", "#33423a")))
	material.set_shader_parameter("mid_color", Color(palette.get("mid", "#68826c")))
	material.set_shader_parameter("light_color", Color(palette.get("light", "#a7b889")))
	material.set_shader_parameter("highlight_color", Color(palette.get("highlight", "#f3df9c")))
	material.set_shader_parameter("saturation", _variation_saturation(profile, variation_seed))
	cached_materials[cache_key] = material
	return material

func get_outline_material(profile_id: String) -> ShaderMaterial:
	if outline_materials.has(profile_id):
		return outline_materials[profile_id]
	var profile = profiles.get(profile_id, {})
	var material := ShaderMaterial.new()
	material.shader = OUTLINE_SHADER
	material.set_shader_parameter("outline_color", Color("#1e2224"))
	material.set_shader_parameter("outline_width", float(profile.get("outline_width", 0.02)))
	outline_materials[profile_id] = material
	return material

func get_water_material() -> ShaderMaterial:
	if water_material != null:
		return water_material
	water_material = ShaderMaterial.new()
	water_material.shader = WATER_SHADER
	return water_material

func add_toon_mesh(parent: Node, mesh: Mesh, profile_id: String, node_name: String, local_transform: Transform3D, variation_seed: int = 0, add_outline := true) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = mesh
	mesh_instance.transform = local_transform
	mesh_instance.set_surface_override_material(0, get_material(profile_id, variation_seed))
	parent.add_child(mesh_instance)
	if add_outline:
		var outline := MeshInstance3D.new()
		outline.name = "%sOutline" % node_name
		outline.mesh = mesh
		outline.transform = local_transform
		outline.set_surface_override_material(0, get_outline_material(profile_id))
		parent.add_child(outline)
	return mesh_instance

func make_sphere(radius: float = 1.0, rings: int = 12, segments: int = 24) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.rings = rings
	mesh.radial_segments = segments
	return mesh

func make_box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

func make_cylinder(radius: float, height: float, sides: int = 16) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = sides
	return mesh

func make_cone(radius: float, height: float, sides: int = 16) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = sides
	return mesh

func _variation_saturation(profile: Dictionary, seed: int) -> float:
	var range: Array = profile.get("variation_saturation", [1.0, 1.0])
	var min_sat := float(range[0])
	var max_sat := float(range[1])
	var t := fposmod(sin(float(seed + 17) * 12.9898) * 43758.5453, 1.0)
	return lerp(min_sat, max_sat, t)

