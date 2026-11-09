extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_x_position: float = 1450.0
@export var min_y: float = 50.0
@export var max_y: float = 670.0

@export var min_spawn_delay: float = 1.0
@export var max_spawn_delay: float = 3.0

@export var min_enemy_speed: float = 50.0
@export var max_enemy_speed: float = 150.0

@onready var spawn_timer = $SpawnTimer

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
func mulai_spawn():
	print("Spawner diaktifkan")
	acak_jeda_timer()

func _on_spawn_timer_timeout():
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		
		var random_y = randf_range(min_y, max_y)
		enemy.global_position = Vector2(spawn_x_position, random_y)
		var random_speed = randf_range(min_enemy_speed, max_enemy_speed)
		enemy.speed = random_speed
		
		get_tree().current_scene.add_child(enemy)
		print("Enemy lahir | Kecepatan: ", int(random_speed), " | Posisi Y: ", int(random_y))

	acak_jeda_timer()

func acak_jeda_timer():
	var random_delay = randf_range(min_spawn_delay, max_spawn_delay)
	spawn_timer.wait_time = random_delay
	spawn_timer.start()
