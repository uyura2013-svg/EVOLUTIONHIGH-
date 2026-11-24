extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const BOT_SCRIPT = preload("res://scripts/bot.gd")

var player
var hud: CanvasLayer
var ammo_label: Label
var hp_label: Label
var info_label: Label
var kills := 0

func _ready() -> void:
    _build_world()
    _spawn_player()
    _build_hud()
    _spawn_bot(Vector3(0, 0, -12))

func _build_world() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.035, 0.05, 0.075)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.55, 0.62, 0.75)
    env.ambient_light_energy = 0.8
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.4
    add_child(sun)

    _box("Ground", Vector3(0, -0.35, 0), Vector3(42, 0.5, 42), Color(0.18, 0.21, 0.24))
    _box("WallNorth", Vector3(0, 1.5, -21), Vector3(42, 3, 0.6), Color(0.25, 0.29, 0.34))
    _box("WallSouth", Vector3(0, 1.5, 21), Vector3(42, 3, 0.6), Color(0.25, 0.29, 0.34))
    _box("WallEast", Vector3(21, 1.5, 0), Vector3(0.6, 3, 42), Color(0.25, 0.29, 0.34))
    _box("WallWest", Vector3(-21, 1.5, 0), Vector3(0.6, 3, 42), Color(0.25, 0.29, 0.34))
    _box("CoverA", Vector3(-5, 0.8, -5), Vector3(3.5, 1.6, 2.0), Color(0.34, 0.37, 0.39))
    _box("CoverB", Vector3(5, 0.65, -9), Vector3(2.2, 1.3, 3.5), Color(0.34, 0.37, 0.39))
    _box("CoverC", Vector3(4, 0.9, 4), Vector3(4.0, 1.8, 2.0), Color(0.34, 0.37, 0.39))
    _box("CoverD", Vector3(-7, 0.7, 8), Vector3(2.0, 1.4, 4.0), Color(0.34, 0.37, 0.39))

func _box(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = label
    body.position = pos
    var mesh := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = size
    mesh.mesh = shape
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    body.add_child(mesh)
    var collision := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    collision.shape = box
    body.add_child(collision)
    add_child(body)

func _spawn_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PLAYER_SCRIPT)
    player.position = Vector3(0, 1, 8)
    add_child(player)
    player.game = self

func _spawn_bot(pos: Vector3) -> void:
    var bot := CharacterBody3D.new()
    bot.name = "TrainingBot"
    bot.set_script(BOT_SCRIPT)
    bot.position = pos
    add_child(bot)
    bot.defeated.connect(_on_bot_defeated)

func _on_bot_defeated() -> void:
    kills += 1
    info_label.text = "ELIMINATIONS  %d" % kills
    _spawn_bot(Vector3(randf_range(-10, 10), 0, randf_range(-15, -7)))

func _build_hud() -> void:
    hud = CanvasLayer.new()
    add_child(hud)
    var panel := ColorRect.new()
    panel.color = Color(0.02, 0.025, 0.035, 0.72)
    panel.position = Vector2(18, 18)
    panel.size = Vector2(290, 92)
    hud.add_child(panel)
    hp_label = _label("HP  100", Vector2(32, 25), 24)
    ammo_label = _label("AMMO  30 / 90", Vector2(32, 57), 20)
    info_label = _label("ELIMINATIONS  0", Vector2(0.68, 25), 22)
    info_label.position = Vector2(0.68 * 1280, 28)
    _button("FIRE", Vector2(1080, 555), Vector2(150, 110), func(): player.shoot())
    _button("RELOAD", Vector2(1080, 480), Vector2(150, 60), func(): player.reload())
    _button("↑", Vector2(115, 520), Vector2(78, 72), func(): player.set_touch_move(Vector2(0, -1)))
    _button("↓", Vector2(115, 650), Vector2(78, 55), func(): player.set_touch_move(Vector2(0, 1)))
    _button("←", Vector2(30, 590), Vector2(78, 72), func(): player.set_touch_move(Vector2(-1, 0)))
    _button("→", Vector2(200, 590), Vector2(78, 72), func(): player.set_touch_move(Vector2(1, 0)))

func _label(text_value: String, pos: Vector2, font_size: int) -> Label:
    var l := Label.new()
    l.text = text_value
    l.position = pos
    l.add_theme_font_size_override("font_size", font_size)
    hud.add_child(l)
    return l

func _button(caption: String, pos: Vector2, size: Vector2, action: Callable) -> void:
    var b := Button.new()
    b.text = caption
    b.position = pos
    b.size = size
    b.add_theme_font_size_override("font_size", 22)
    b.modulate = Color(1, 1, 1, 0.88)
    b.pressed.connect(action)
    hud.add_child(b)

func update_hud(hp: int, ammo: int, reserve: int) -> void:
    hp_label.text = "HP  %d" % hp
    ammo_label.text = "AMMO  %d / %d" % [ammo, reserve]
