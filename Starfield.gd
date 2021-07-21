extends Particles2D

onready var screen_size = get_viewport().size

var min_speed_scale = 1
var max_speed_scale = 60

func _ready():
	position = Vector2(screen_size.x / 2, -2)

func increase_speed(percentage: float):
	speed_scale = clamp(
		speed_scale + (speed_scale * percentage),
		min_speed_scale,
		max_speed_scale
	)

func decrease_speed(percentage: float):
	speed_scale = clamp(
		speed_scale - (speed_scale * percentage),
		min_speed_scale,
		max_speed_scale
	)

func reset_speed():
	speed_scale = 1

