extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var smoke: PackedScene
@onready var muzzle = $Sprite2D/WeaponMuzzle
@onready var muzzle2 = $Sprite2D/WeaponMuzzle2
@onready var anim_player = $AnimationPlayer 
@onready var sprite = $Sprite2D 
@onready var shield_sprite = $Shield
@onready var hitbox_node = $HitBox
@onready var hitbox_collision = $HitBox/CollisionShape2D
@onready var dmgsnd = $Damage2
@onready var jet_particles = $GPUParticles2D1

@export_range(0, 90) var max_rotation_degrees: float = 30.0
@export var rotation_speed: float = 10.0


var target_y_position: float = 360.0
var is_shooting: bool = false

@export_group("Player Stats")
var current_hp: int = 3
@export var iframe_duration: float = 1.5 

var is_invincible: bool = false
var is_shielded: bool = false   
var shield_tween: Tween
var is_active: bool = false

@export_group("Skill Testing")
@export var skill_fast_shoot: bool = false
@export var skill_triple_shot: bool = false
@export var skill_super_missile: bool = false 

func _ready():
	global_position.x = 150
	if hitbox_node:
		hitbox_node.area_entered.connect(_on_hitbox_area_entered)
		
	get_tree().call_group("UI", "update_health_ui", current_hp)

func _process(delta):
	if not is_active:
		if anim_player.is_playing():
			anim_player.stop()
		return
	var previous_y = global_position.y

	global_position.y = lerp(global_position.y, target_y_position, 0.2)
	global_position.y = clamp(global_position.y, 50, 670)

	if not is_shooting:
		var y_velocity = global_position.y - previous_y
		var target_rotation = 0.0
		if abs(y_velocity) > 0.1:
			var max_rotation_rad = deg_to_rad(max_rotation_degrees)
			target_rotation = clamp(y_velocity * 0.05, -max_rotation_rad, max_rotation_rad)
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	else:
		rotation = lerp_angle(rotation, 0.0, rotation_speed * delta)

	if is_shooting:
		var kecepatan_total = 1.0
		kecepatan_total += 1.0 
		if skill_fast_shoot:
			kecepatan_total += 3.0
		if skill_super_missile:
			kecepatan_total -= 1.0
			
		anim_player.speed_scale = kecepatan_total
		
		if not anim_player.is_playing():
			anim_player.play("Shoot")
	else:
		if anim_player.current_animation == "Shoot" and anim_player.is_playing():
			anim_player.stop()

func _on_hitbox_area_entered(area: Area2D):
	if is_invincible or is_shielded:
		return
		
	if area.is_in_group("enemy") or "is_dead" in area:
		take_damage()

func take_damage():
	current_hp -= 1
	dmgsnd.play()
	get_tree().call_group("UI", "update_health_ui", current_hp)
	
	if current_hp <= 0:
		player_die()
		return
		
	start_iframes()

func start_iframes():
	is_invincible = true
	hitbox_node.collision_mask = 0
	sprite.self_modulate = Color(1.0, 0.4, 0.4, 1.0)
	
	var tween = create_tween().set_loops(int(iframe_duration * 8))
	tween.tween_property(sprite, "self_modulate:a", 0.2, 0.06)
	tween.tween_property(sprite, "self_modulate:a", 1.0, 0.06)
	
	await get_tree().create_timer(iframe_duration).timeout
	
	tween.kill()
	sprite.self_modulate = Color(1, 1, 1, 1)
	
	if not is_shielded:
		hitbox_node.collision_mask = 2
		
	is_invincible = false

func player_die():
	print("Player Hancur! Efek kedap-kedip merah dimulai.")
	
	if jet_particles:
		jet_particles.emitting = false
		
	if sprite:
		var death_tween = create_tween().set_loops()
		death_tween.tween_property(sprite, "self_modulate", Color(1, 0, 0, 1), 0.15)
		death_tween.tween_property(sprite, "self_modulate", Color(1, 1, 1, 0.3), 0.15)
		
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("pemicu_game_over"):
		main_node.pemicu_game_over()

func activate_shield(duration: float):
	is_shielded = true
	hitbox_node.collision_mask = 0
	
	if shield_tween and shield_tween.is_valid():
		shield_tween.kill()
		
	shield_tween = create_tween()
	shield_tween.tween_property(shield_sprite, "self_modulate:a", 0.5, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	shield_tween.tween_interval(duration)
	shield_tween.tween_callback(deactivate_shield)
	
	print("Shield diperbarui! Aktif untuk ", duration, " detik ke depan.")

func deactivate_shield():
	is_shielded = false
	
	if shield_tween and shield_tween.is_valid():
		shield_tween.kill()
		
	shield_tween = create_tween()
	shield_tween.tween_property(shield_sprite, "self_modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	if not is_invincible:
		hitbox_node.collision_mask = 2
	print("Shield habis total, visual memudar!")
	
var fast_shoot_tween: Tween

func activate_fast_shoot(duration: float):
	skill_fast_shoot = true
	
	if fast_shoot_tween and fast_shoot_tween.is_valid():
		fast_shoot_tween.kill()
		
	fast_shoot_tween = create_tween()
	fast_shoot_tween.tween_interval(duration)
	fast_shoot_tween.tween_callback(deactivate_fast_shoot)
	
	print("Skill Fast Shoot diperbarui untuk ", duration, " detik!")

func deactivate_fast_shoot():
	skill_fast_shoot = false
	
	if fast_shoot_tween and fast_shoot_tween.is_valid():
		fast_shoot_tween.kill()
		
	print("Durasi Fast Shoot habis! Kecepatan tembak kembali normal.")
	

var triple_shot_tween: Tween
var super_missile_tween: Tween


func activate_triple_shot(duration: float):
	skill_triple_shot = true
	
	if triple_shot_tween and triple_shot_tween.is_valid():
		triple_shot_tween.kill()
		
	triple_shot_tween = create_tween()
	triple_shot_tween.tween_interval(duration)
	triple_shot_tween.tween_callback(deactivate_triple_shot)
	
	print("Skill Triple Shot diperbarui!")

func deactivate_triple_shot():
	skill_triple_shot = false
	if triple_shot_tween and triple_shot_tween.is_valid():
		triple_shot_tween.kill()
	print("Durasi Triple Shot habis!")

func activate_super_missile(duration: float):
	skill_super_missile = true
	
	if super_missile_tween and super_missile_tween.is_valid():
		super_missile_tween.kill()
		
	super_missile_tween = create_tween()
	super_missile_tween.tween_interval(duration)
	super_missile_tween.tween_callback(deactivate_super_missile)
	
	print("Skill Super Missile diperbarui!")

func deactivate_super_missile():
	skill_super_missile = false
	if super_missile_tween and super_missile_tween.is_valid():
		super_missile_tween.kill()
	print("Durasi Super Missile habis!")

func spawn_bullet():
	if not bullet_scene:
		return
	var angles = [0.0, -35.0, 35.0] if skill_triple_shot else [0.0]
	for angle in angles:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.rotation = deg_to_rad(angle)
		if skill_super_missile:
			bullet.is_super = true
		get_tree().current_scene.add_child(bullet)

func spawn_smoke():
	if smoke:
		var smokes = smoke.instantiate()
		smokes.global_position = muzzle2.global_position
		get_tree().current_scene.add_child(smokes)
		if smokes.has_method("set_emitting"):
			smokes.emitting = true
		elif smokes is Node2D:
			for child in smokes.get_children():
				if "emitting" in child:
					child.emitting = true
