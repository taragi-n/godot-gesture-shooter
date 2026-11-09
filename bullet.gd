extends Area2D

@export var speed: float = 800.0
@export var straighten_speed: float = 5.0

var target_rotation: float = 0.0
var can_straighten: bool = false
var is_super: bool = false

func _ready():
	if is_super:
		scale = Vector2(1.5, 1.5)
		add_to_group("super_missile")
	else:
		add_to_group("missile")
	
	target_rotation = rotation
	
	await get_tree().create_timer(0.2).timeout
	
	target_rotation = 0.0
	can_straighten = true

func _process(delta):
	if can_straighten:
		rotation = lerp_angle(rotation, target_rotation, straighten_speed * delta)
	
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

	if position.x > 1400:
		queue_free()
