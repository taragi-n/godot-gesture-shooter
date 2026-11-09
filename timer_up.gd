extends Node2D

@onready var sprite = $Sprite2D
@onready var label_timer = $Timer

var powerup_type: String = ""
var duration_left: float = 0.0

var _temp_texture: Texture2D 

func setup_timer(texture_icon: Texture2D, duration: float, type_name: String):
	_temp_texture = texture_icon
	duration_left = duration
	powerup_type = type_name

func _ready():
	if _temp_texture and sprite:
		sprite.texture = _temp_texture
		
	if label_timer:
		label_timer.text = str(ceil(duration_left))

func _process(delta):
	if duration_left > 0:
		duration_left -= delta
		
		if label_timer:
			label_timer.text = str(ceil(duration_left))
		
		if duration_left <= 0:
			get_tree().call_group("UI", "remove_timer_display", self)
