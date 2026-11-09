extends Sprite2D

@export var texture_full: Texture2D 
@export var texture_empty: Texture2D 

func set_heart_state(is_full: bool):
	if is_full:
		texture = texture_full
	else:
		texture = texture_empty
