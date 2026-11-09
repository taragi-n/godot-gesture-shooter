extends CanvasLayer

@export var health_display_scene: PackedScene 
@onready var marker_2d = $Visual/Marker2D           
@onready var score_label = $Visual/ScoreLabel

@export var health_spacing: float = 40.0 

@export var timer_up_scene: PackedScene 
@onready var marker_timer = $Visual/MarkerTimer
@export var timer_spacing: float = 50.0   

var hearts_array: Array = [] 
var current_score: int = 0   
var active_timers: Array = [] 

func _ready():
	add_to_group("UI")
	update_score_ui()
	
func inisialisasi_game():
	setup_hearts(3)

func setup_hearts(max_health: int):
	for heart in hearts_array:
		heart.queue_free()
	hearts_array.clear()
	
	var visual_node = get_node_or_null("Visual")
	
	for i in range(max_health):
		var heart_instance = health_display_scene.instantiate()
		var new_pos = marker_2d.global_position
		new_pos.x += i * health_spacing
		heart_instance.global_position = new_pos
		
		if visual_node:
			visual_node.add_child(heart_instance)
		else:
			add_child(heart_instance)
			
		hearts_array.append(heart_instance)
		heart_instance.set_heart_state(true)

func update_health_ui(current_health: int):
	for i in range(hearts_array.size()):
		if i < current_health:
			hearts_array[i].set_heart_state(true)
		else:
			hearts_array[i].set_heart_state(false)

func add_score(amount: int):
	current_score += amount
	update_score_ui()

func update_score_ui():
	score_label.text = "%03d" % current_score

func add_timer_display(texture_icon: Texture2D, duration: float, type_name: String):
	for t in active_timers:
		if t.powerup_type == type_name:
			active_timers.erase(t)
			t.queue_free()
			break

	var timer_instance = timer_up_scene.instantiate()
	timer_instance.setup_timer(texture_icon, duration, type_name)
	add_child(timer_instance)
	active_timers.append(timer_instance)
	
	reposition_timers()

func remove_timer_display(timer_node):
	if timer_node in active_timers:
		active_timers.erase(timer_node)
		timer_node.queue_free()
		reposition_timers()

func reposition_timers():
	var total_icons = active_timers.size()
	if total_icons == 0:
		return
		
	var total_width = (total_icons - 1) * timer_spacing
	var start_x = marker_timer.global_position.x - (total_width / 2.0)
	
	for i in range(total_icons):
		var new_pos = Vector2(
			start_x + (i * timer_spacing),
			marker_timer.global_position.y
		)
		active_timers[i].global_position = new_pos
