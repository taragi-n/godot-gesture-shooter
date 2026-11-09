extends Area2D

@export var texture_broken1: Texture2D
@export var texture_broken2: Texture2D
@export var explosion_scene: PackedScene
@export var speed: float = 100.0
@export var powerup_scene: PackedScene

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

var health: int = 3
var is_dead: bool = false

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	if not is_dead:
		position.x -= speed * delta
		
		if position.x < -150:
			queue_free()

func _on_area_entered(area: Area2D):
	if is_dead:
		return
		
	if area.name == "Player" or area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage()
		return
		
	if area.is_in_group("super_missile"):
		spawn_explosion(area.global_position)
		
		area.queue_free()
		
		die()
		return
		
	if area.is_in_group("missile"):
		spawn_explosion(area.global_position)
		
		area.queue_free() 
		
		take_damage()

func spawn_explosion(pos: Vector2):
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = pos
		get_tree().current_scene.add_child(explosion)
		
		if explosion.has_method("set_emitting"):
			explosion.emitting = true
		elif explosion is Node2D:
			for child in explosion.get_children():
				if "emitting" in child:
					child.emitting = true

func take_damage():
	health -= 1
	
	match health:
		2:
			if texture_broken1:
				sprite.texture = texture_broken1
			print("Enemy HP: 2 - Tekstur Broken 1")
		1:
			if texture_broken2:
				sprite.texture = texture_broken2
			print("Enemy HP: 1 - Tekstur Broken 2")
		0:
			die()

func die():
	is_dead = true
	print("Enemy HP: 0 - Memainkan Animasi Broken")
	
	get_tree().call_group("UI", "add_score", 1)
	
	if randf() <= 0.40: 
		spawn_loot_drop()
	
	if anim_player and anim_player.has_animation("Broken"):
		$CollisionShape2D.set_deferred("disabled", true)
		anim_player.play("Broken")
		await anim_player.animation_finished
		queue_free()
	else:
		queue_free()

func spawn_loot_drop():
	if not powerup_scene:
		return
		
	var loot = powerup_scene.instantiate()
	loot.global_position = global_position
	
	var roll = randi_range(1, 100)
	
	if roll <= 15:
		loot.type = loot.PowerUpType.TRIPLE
		print("Loot Drop: TRIPLE SHOT!")
	elif roll <= 30:
		loot.type = loot.PowerUpType.SPEED 
		print("Loot Drop: FAST SHOOT!")
	elif roll <= 45:
		loot.type = loot.PowerUpType.SUPER 
		print("Loot Drop: SUPER MISSILE!")
		
	elif roll <= 72:
		loot.type = loot.PowerUpType.SHIELD 
		print("Loot Drop: SHIELD!")
	else:
		loot.type = loot.PowerUpType.HEALTH
		print("Loot Drop: HEALTH!")

	get_tree().current_scene.add_child(loot)
