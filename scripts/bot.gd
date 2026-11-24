extends CharacterBody3D

signal defeated
var hp := 100

func _ready() -> void:
    var mesh := MeshInstance3D.new()
    var capsule_mesh := CapsuleMesh.new()
    capsule_mesh.radius = 0.42
    capsule_mesh.height = 1.8
    mesh.mesh = capsule_mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.72, 0.18, 0.12)
    mesh.material_override = material
    mesh.position.y = 0.9
    add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.42
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

func take_hit(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        defeated.emit()
        queue_free()
