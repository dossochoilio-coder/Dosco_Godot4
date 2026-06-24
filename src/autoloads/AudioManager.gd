# src/autoloads/AudioManager.gd — Gestion audio DOSCO
extends Node

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _muted: bool = false
var _vol_level: float = 0.7

const SFX_PATHS := {
	"click":       "res://assets/audio/sfx/click.wav",
	"select":      "res://assets/audio/sfx/select.wav",
	"move":        "res://assets/audio/sfx/move.wav",
	"capture":     "res://assets/audio/sfx/capture.wav",
	"error":       "res://assets/audio/sfx/error.wav",
	"victory":     "res://assets/audio/sfx/victory.wav",
	"draw":        "res://assets/audio/sfx/draw.wav",
	"alert":       "res://assets/audio/sfx/alert.wav",
	"battlestart": "res://assets/audio/sfx/battlestart.wav",
	"connect":     "res://assets/audio/sfx/connect.wav",
	"defeat":      "res://assets/audio/sfx/victory.wav",
}

const MUSIC_PATHS := {
	"ambient": "res://assets/audio/music/ambient.wav",
	"victory": "res://assets/audio/music/victory.wav",
}

func _ready() -> void:
	for i in 6:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	_load_prefs()

func play_sfx(name: String, vol: float = 1.0) -> void:
	if _muted: return
	if not SFX_PATHS.has(name): return
	if not ResourceLoader.exists(SFX_PATHS[name]): return
	var stream: AudioStream = load(SFX_PATHS[name])
	if stream == null: return
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = linear_to_db(_vol_level * vol)
			p.play()
			return
	_sfx_players[0].stream = stream
	_sfx_players[0].volume_db = linear_to_db(_vol_level * vol)
	_sfx_players[0].play()

func play_music(name: String, loop: bool = true) -> void:
	if not MUSIC_PATHS.has(name): return
	if not ResourceLoader.exists(MUSIC_PATHS[name]): return
	var stream: AudioStream = load(MUSIC_PATHS[name])
	if stream == null: return
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	_music_player.stream = stream
	_music_player.volume_db = linear_to_db(_vol_level * 0.60)
	if not _muted: _music_player.play()

func stop_music() -> void:
	if _music_player: _music_player.stop()

func set_muted(m: bool) -> void:
	_muted = m
	if m: stop_music()
	else: _music_player.play()
	_save_prefs()

func set_volume(v: float) -> void:
	_vol_level = clampf(v, 0.0, 1.0)
	for p in _sfx_players:
		p.volume_db = linear_to_db(_vol_level)
	if _music_player:
		_music_player.volume_db = linear_to_db(_vol_level * 0.60)
	_save_prefs()

func is_muted() -> bool: return _muted
func get_volume() -> float: return _vol_level

# Raccourcis
func sfx_click() -> void:       play_sfx("click")
func sfx_select() -> void:      play_sfx("select")
func sfx_move() -> void:        play_sfx("move")
func sfx_capture() -> void:     play_sfx("capture", 0.9)
func sfx_victory() -> void:     play_sfx("victory")
func sfx_defeat() -> void:      play_sfx("defeat", 0.85)
func sfx_connect() -> void:     play_sfx("connect")
func sfx_alert() -> void:       play_sfx("alert")
func sfx_error() -> void:       play_sfx("error")
func sfx_battlestart() -> void: play_sfx("battlestart")

func _load_prefs() -> void:
	var c := ConfigFile.new()
	if c.load("user://audio.cfg") == OK:
		_muted = c.get_value("audio", "muted", false)
		_vol_level = c.get_value("audio", "volume", 0.7)

func _save_prefs() -> void:
	var c := ConfigFile.new()
	c.set_value("audio", "muted", _muted)
	c.set_value("audio", "volume", _vol_level)
	c.save("user://audio.cfg")
