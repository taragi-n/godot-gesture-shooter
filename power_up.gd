extends Node2D

enum PowerUpType { HEALTH, SPEED, TRIPLE, SUPER, SHIELD }
@export var type: PowerUpType = PowerUpType.HEALTH

@export_group("Power Up Textures")
@export var texture_health: Texture2D
@export var texture_shield: Texture2D
@export var texture_speed: Texture2D
@export var texture_triple: Texture2D
@export var texture_super: Texture2D

@export_group("Power Up Durations (Seconds)")
@export var duration_shield: float = 7.0  
@export var duration_speed: float = 15.0 
@export var duration_triple: float = 10.0
@export var duration_super: float = 8.0

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var picker_area = $PickerArea

@export_group("Movement")
@export var move_speed: float = 150.0

var is_taken: bool = false
var active_texture: Texture2D 
var active_duration: float = 0.0

func _ready():
	match type:
		PowerUpType.HEALTH: 
			active_texture = texture_health
		PowerUpType.SHIELD: 
			active_texture = texture_shield
			active_duration = duration_shield
		PowerUpType.SPEED:  
			active_texture = texture_speed
			active_duration = duration_speed
		PowerUpType.TRIPLE: 
			active_texture = texture_triple
			active_duration = duration_triple
		PowerUpType.SUPER:  
			active_texture = texture_super
			active_duration = duration_super
		
	if active_texture:
		sprite.texture = active_texture
		
	picker_area.area_entered.connect(_on_picker_area_entered)
	
func _process(delta):
	global_position.x -= move_speed * delta
	
	if global_position.x < -50:
		queue_free()

func _on_picker_area_entered(area: Area2D):
	if is_taken:
		return
	var player = area.owner
	if player and player.name == "Player":
		execute_power_up(player)

func execute_power_up(player: CharacterBody2D):
	match type:
		PowerUpType.HEALTH:
			if player.current_hp < 3:
				is_taken = true
				player.current_hp += 1
				get_tree().call_group("UI", "update_health_ui", player.current_hp)
				play_take_animation()

		PowerUpType.SHIELD:
			is_taken = true
			if player.has_method("activate_shield"):
				player.activate_shield(active_duration)
			
			get_tree().call_group("UI", "add_timer_display", active_texture, active_duration, "SHIELD")
			play_take_animation()

		PowerUpType.SPEED:
			is_taken = true
			if player.has_method("activate_fast_shoot"):
				player.activate_fast_shoot(active_duration)
			
			get_tree().call_group("UI", "add_timer_display", active_texture, active_duration, "SPEED")
			play_take_animation()

		PowerUpType.TRIPLE:
			is_taken = true
			if player.has_method("activate_triple_shot"):
				player.activate_triple_shot(active_duration)
			
			get_tree().call_group("UI", "add_timer_display", active_texture, active_duration, "TRIPLE")
			
			print("Power Up: Triple Shot aktif selama ", active_duration, " detik!")
			play_take_animation()

		PowerUpType.SUPER:
			is_taken = true
			if player.has_method("activate_super_missile"):
				player.activate_super_missile(active_duration)
			
			get_tree().call_group("UI", "add_timer_display", active_texture, active_duration, "SUPER")
			
			print("Power Up: Super Missile aktif selama ", active_duration, " detik!")
			play_take_animation()

func play_take_animation():
	if has_node("PickerArea/CollisionShape2D"):
		$PickerArea/CollisionShape2D.set_deferred("disabled", true)
	if anim_player and anim_player.has_animation("take"):
		anim_player.play("take")
		await anim_player.animation_finished
		queue_free()
	else:
		queue_free()
