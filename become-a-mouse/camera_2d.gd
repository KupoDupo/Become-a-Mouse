extends Camera2D

@export var max_offset: float = 16.0
@export var max_rotation: float = 0.05

@export var calm_music: AudioStreamPlayer2D
@export var panic_music: AudioStreamPlayer2D
@export var crossfade_time: float = 0.8  # seconds for fade between tracks

var _rng := RandomNumberGenerator.new()

var _shake_time_left: float = 0.0
var _shake_duration: float = 0.0
var _shake_intensity: float = 0.0

var _base_offset: Vector2
var _base_rotation: float

var _calm_base_db: float = 0.0
var _panic_base_db: float = 0.0
var _music_tween: Tween

func _ready() -> void:
	_rng.randomize()
	_base_offset = offset
	_base_rotation = rotation

	if calm_music:
		_calm_base_db = calm_music.volume_db
	if panic_music:
		_panic_base_db = panic_music.volume_db
		# Start calm music by default (optional)
		calm_music.play()
		panic_music.volume_db = -80.0  # essentially muted


func _process(delta: float) -> void:
	if _shake_time_left > 0.0:
		_shake_time_left -= delta
		var t := 1.0 - (_shake_time_left / _shake_duration)
		var fade := 1.0 - t

		var current_offset := max_offset * _shake_intensity * fade
		var current_rot := max_rotation * _shake_intensity * fade

		offset = _base_offset + Vector2(
			_rng.randf_range(-current_offset, current_offset),
			_rng.randf_range(-current_offset, current_offset)
		)

		rotation = _base_rotation + _rng.randf_range(-current_rot, current_rot)

		if _shake_time_left <= 0.0:
			_reset_camera()
	else:
		_reset_camera()


func _reset_camera() -> void:
	offset = _base_offset
	rotation = _base_rotation


func start_shake(intensity: float = 1.0, duration: float = 0.4) -> void:
	_shake_intensity = clamp(intensity, 0.0, 1.0)
	_shake_duration = max(duration, 0.01)
	_shake_time_left = _shake_duration
	
	_crossfade_to_panic()


func stop_shake() -> void:
	_shake_time_left = 0.0
	_reset_camera()
	_crossfade_to_calm()


func _kill_music_tween() -> void:
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = null


func _crossfade_to_panic() -> void:
	# Restart panic track from beginning and fade from calm -> panic
	_kill_music_tween()

	if panic_music:
		panic_music.stop()       # ensures start from beginning
		panic_music.play()
		panic_music.volume_db = -80.0   # start muted

	if calm_music:
		calm_music.volume_db = _calm_base_db

	_music_tween = create_tween()
	if panic_music:
		_music_tween.tween_property(
			panic_music, "volume_db",
			_panic_base_db,
			crossfade_time
		)
	if calm_music:
		_music_tween.parallel().tween_property(
			calm_music, "volume_db",
			-80.0,
			crossfade_time
		)


func _crossfade_to_calm() -> void:
	# Restart calm track from beginning and fade from panic -> calm
	_kill_music_tween()

	if calm_music and not calm_music.playing:
		calm_music.stop()       # ensures start from beginning
		calm_music.play()
		calm_music.volume_db = -80.0   # start muted

	if panic_music and not panic_music.playing:
		panic_music.volume_db = _panic_base_db

	_music_tween = create_tween()
	if calm_music:
		_music_tween.tween_property(
			calm_music, "volume_db",
			_calm_base_db,
			crossfade_time
		)
	if panic_music:
		_music_tween.parallel().tween_property(
			panic_music, "volume_db",
			-80.0,
			crossfade_time
		)
