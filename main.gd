extends Node2D

@onready var standby_canvas = $StandBy_Canvas
@onready var ui_canvas = $UI_Canvas 
@onready var game_over_canvas = $GameOver_Canvas
@onready var player = $Player
@onready var enemy_spawner = $EnemySpawner

var python_pid: int = -1 
var server := PacketPeerUDP.new()
var port := 4242

var game_dimulai: bool = false
var status_game_over: bool = false

@export_group("Death Physics")
@export var death_move_speed: float = 50.0

func _ready():
	game_dimulai = false
	status_game_over = false
	player.is_active = false 
	
	standby_canvas.visible = true
	ui_canvas.visible = true
	game_over_canvas.visible = false
	
	if standby_canvas.has_node("Visual"):
		standby_canvas.get_node("Visual").modulate.a = 1.0
	if ui_canvas.has_node("Visual"):
		ui_canvas.get_node("Visual").modulate.a = 0.0
	if game_over_canvas.has_node("Visual"):
		game_over_canvas.get_node("Visual").modulate.a = 0.0

	jalankan_python_hand_tracking()
	
	if server.bind(port) == OK:
		print("Godot sukses mendengarkan Python di port: ", port)
	else:
		print("Gagal membuka port UDP!")

func _input(event):
	if not game_dimulai and not status_game_over and event.is_action_pressed("ui_accept"):
		game_dimulai = true
		mulai_gameplay_dengan_tween()
		
	elif status_game_over and event.is_action_pressed("ui_accept"):
		print("Merestart Game...")
		get_tree().reload_current_scene()

func mulai_gameplay_dengan_tween():
	print("Memulai transisi game...")
	if ui_canvas.has_method("inisialisasi_game"):
		ui_canvas.inisialisasi_game()
	
	var standby_visual = standby_canvas.get_node_or_null("Visual")
	var ui_visual = ui_canvas.get_node_or_null("Visual")
	
	var tween_fade = create_tween().set_parallel(true)
	
	if standby_visual:
		tween_fade.tween_property(standby_visual, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if ui_visual:
		ui_visual.modulate.a = 0.0
		tween_fade.tween_property(ui_visual, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await tween_fade.finished
	standby_canvas.visible = false
	
	player.is_active = true 
	enemy_spawner.mulai_spawn() 
	print("Game Berjalan Sempurna!")

func pemicu_game_over():
	if status_game_over:
		return
	status_game_over = true
	game_dimulai = false
	
	print("Menjalankan Protokol Game Over...")
	
	player.is_active = false
	if enemy_spawner.has_node("SpawnTimer"):
		enemy_spawner.get_node("SpawnTimer").stop()
		
	var skor_akhir = ui_canvas.current_score
	var label_skor_gameover = game_over_canvas.get_node_or_null("Visual/ScoreAkhirLabel")
	if label_skor_gameover:
		label_skor_gameover.text = ("%03d" % skor_akhir)
	
	game_over_canvas.visible = true
	var ui_visual = ui_canvas.get_node_or_null("Visual")
	var go_visual = game_over_canvas.get_node_or_null("Visual")
	
	var tween_go = create_tween().set_parallel(true)
	if ui_visual:
		tween_go.tween_property(ui_visual, "modulate:a", 0.0, 0.4)
	if go_visual:
		go_visual.modulate.a = 0.0
		tween_go.tween_property(go_visual, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _process(_delta):
	if game_dimulai and not status_game_over:
		if server.get_available_packet_count() > 0:
			var packet := server.get_packet()
			var data_string := packet.get_string_from_utf8()
			var data_array := data_string.split(",")
			if data_array.size() >= 2:
				player.target_y_position = float(data_array[0])
				player.is_shooting = int(data_array[1]) == 1
	if status_game_over:
		if player and player.global_position.x > -150:
			player.global_position.x -= death_move_speed * _delta

func jalankan_python_hand_tracking():
	print("Mencoba menyalakan Python Hand Tracking dari dalam proyek...")
	
	var script_path = ProjectSettings.globalize_path("res://Assets/gesture_tracking.py")
	var arguments = [script_path]
	
	python_pid = OS.create_process("python", arguments)
	
	if python_pid != -1:
		print("Python Hand Tracking sukses berjalan dari folder proyek! PID: ", python_pid)
	else:
		print("Gagal menjalankan Python. Coba cek lagi nama filenya.")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if python_pid != -1:
			print("Mematikan proses Python Hand Tracking (PID: ", python_pid, ")...")
			OS.kill(python_pid)
		
		get_tree().quit()
