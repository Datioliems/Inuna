extends Node
class_name AudioDirector

var player: Node3D
var world: Node3D
var zone_volumes := {}
var generator_players := {}
var generator_playbacks := {}
var phases := {}
var base_volume := 0.28
var current_zone := "base"
var footstep_timer := 0.0

func setup(target_player: Node3D, target_world: Node3D) -> void:
	player = target_player
	world = target_world
	_create_generator("base", 0.13)
	for zone in world.get_audio_zones():
		_create_generator(str(zone["zone_name"]), 0.0)
		zone_volumes[str(zone["zone_name"])] = 0.0
	_create_generator("footstep_dry", 0.0)
	_create_generator("footstep_water", 0.0)

func _process(delta: float) -> void:
	if player == null or world == null:
		return
	_update_zone_volumes(delta)
	_update_footsteps(delta)
	_push_audio(delta)

func _create_generator(key: String, volume: float) -> void:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.35
	var audio_player := AudioStreamPlayer.new()
	audio_player.name = "Audio_%s" % key
	audio_player.stream = stream
	audio_player.volume_db = linear_to_db(max(volume, 0.001))
	add_child(audio_player)
	audio_player.play()
	generator_players[key] = audio_player
	generator_playbacks[key] = audio_player.get_stream_playback()
	phases[key] = 0.0

func _update_zone_volumes(delta: float) -> void:
	var best_zone := "base"
	var best_volume := 0.0
	for zone in world.get_audio_zones():
		var zone_name := str(zone["zone_name"])
		var distance := player.global_position.distance_to(zone["center"])
		var radius := float(zone["radius"])
		var margin := float(zone["fade_margin"])
		var raw: float = 1.0 - clamp((distance - max(0.01, radius - margin)) / max(0.01, margin), 0.0, 1.0)
		var target: float = raw * float(zone["target_volume"])
		zone_volumes[zone_name] = lerp(float(zone_volumes.get(zone_name, 0.0)), target, 1.0 - exp(-3.0 * delta))
		if zone_volumes[zone_name] > best_volume:
			best_volume = zone_volumes[zone_name]
			best_zone = zone_name
		var audio_player: AudioStreamPlayer = generator_players.get(zone_name)
		if audio_player != null:
			audio_player.volume_db = linear_to_db(max(zone_volumes[zone_name], 0.001))
	current_zone = best_zone
	var base_player: AudioStreamPlayer = generator_players.get("base")
	if base_player != null:
		base_player.volume_db = linear_to_db(base_volume)

func _update_footsteps(delta: float) -> void:
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	var moving := speed > 0.2
	var target_dry := 0.0
	var target_water := 0.0
	if moving:
		if player.current_surface == "water":
			target_water = 0.32
		else:
			target_dry = 0.22
	footstep_timer += delta * clamp(speed, 0.0, 5.0)
	_set_volume("footstep_dry", target_dry)
	_set_volume("footstep_water", target_water)

func _set_volume(key: String, volume: float) -> void:
	var audio_player: AudioStreamPlayer = generator_players.get(key)
	if audio_player != null:
		var current := db_to_linear(audio_player.volume_db)
		audio_player.volume_db = linear_to_db(max(lerp(current, volume, 0.12), 0.001))

func _push_audio(_delta: float) -> void:
	for key in generator_playbacks.keys():
		var playback: AudioStreamGeneratorPlayback = generator_playbacks[key]
		if playback == null:
			continue
		var frames := playback.get_frames_available()
		for i in range(frames):
			var sample := _sample_for(key)
			playback.push_frame(Vector2(sample, sample))

func _sample_for(key: String) -> float:
	var freq := 90.0
	match key:
		"forest":
			freq = 230.0
		"river":
			freq = 170.0
		"village":
			freq = 130.0
		"footstep_dry":
			freq = 72.0
		"footstep_water":
			freq = 54.0
		_:
			freq = 105.0
	var phase := float(phases.get(key, 0.0))
	phase += TAU * freq / 22050.0
	phases[key] = fposmod(phase, TAU)
	var tone := sin(phase) * 0.035
	if key.begins_with("footstep"):
		var pulse: float = max(0.0, sin(footstep_timer * TAU * 1.7))
		tone *= pow(pulse, 12.0) * 5.0
	else:
		tone += sin(phase * 0.37) * 0.012
	return tone
