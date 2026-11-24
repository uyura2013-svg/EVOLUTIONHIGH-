extends CharacterBody3D

var game
var hp := 100
var ammo := 30
var reserve := 90
var fire_delay := 0.0
var touch_move := Vector2.ZERO
var camera: Camera3D
var pitch := 0.0
const SPEED := 6.0
const GRAVITY := 22.0

func _ready() -> void:
    var capsule := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 1.8
    capsule.shape = shape
    add_child(capsule)
    camera = Camera3D.new()
    camera.position = Vector3(0, 0.55, 0)
    camera.current = true
    add_child(camera)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * 0.0025)
        pitch = clamp(pitch - event.relative.y * 0.0025, -1.3, 1.3)
        camera.rotation.x = pitch
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    fire_delay = maxf(0.0, fire_delay - delta)
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if touch_move != Vector2.ZERO:
        input_dir = touch_move
        touch_move = Vector2.ZERO
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    velocity.x = direction.x * SPEED
    velocity.z = direction.z * SPEED
    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    else:
        velocity.y = -0.1
    move_and_slide()
    if Input.is_action_just_pressed("fire"):
        shoot()
    if Input.is_action_just_pressed("reload"):
        reload()

func set_touch_move(v: Vector2) -> void:
    touch_move = v

func shoot() -> void:
    if fire_delay > 0.0 or ammo <= 0:
        return
    fire_delay = 0.12
    ammo -= 1
    var query := PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_transform.basis.z * 100.0)
    query.exclude = [get_rid()]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit and hit.collider.has_method("take_hit"):
        hit.collider.take_hit(34)
    game.update_hud(hp, ammo, reserve)

func reload() -> void:
    if ammo >= 30 or reserve <= 0:
        return
    var needed := 30 - ammo
    var amount := mini(needed, reserve)
    ammo += amount
    reserve -= amount
    game.update_hud(hp, ammo, reserve)
