extends Node

const SOUND_DIR := "res://audio/sfx/"
const POOL_SIZE := 12

var _streams: Dictionary = {}
var _last_played: Dictionary = {}
var _loops: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# läuft auch im Pause-Menü weiter (Button-Klicks)
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_pool.append(player)

# cooldown_ms verhindert Sound-Spam, z.B. wenn ein Beam jeden Frame Schaden macht
func play(sound_name: String, volume_db := 0.0, pitch_variation := 0.05, cooldown_ms := 50) -> void:
	var stream := _get_stream(sound_name)
	if stream == null:
		return
	var now := Time.get_ticks_msec()
	var last: int = _last_played.get(sound_name, -100000)
	if now - last < cooldown_ms:
		return
	_last_played[sound_name] = now
	for player in _pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
			player.play()
			return

func start_loop(sound_name: String, volume_db := 0.0) -> void:
	if _loops.has(sound_name):
		return
	var stream := _get_stream(sound_name)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.finished.connect(player.play)
	add_child(player)
	player.play()
	_loops[sound_name] = player

func stop_loop(sound_name: String) -> void:
	if _loops.has(sound_name):
		_loops[sound_name].queue_free()
		_loops.erase(sound_name)

func _get_stream(sound_name: String) -> AudioStream:
	if not _streams.has(sound_name):
		var path := "%s%s.wav" % [SOUND_DIR, sound_name]
		_streams[sound_name] = load(path) if ResourceLoader.exists(path) else null
	return _streams[sound_name]