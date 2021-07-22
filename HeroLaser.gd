extends Area2D

var speed = 4 * Settings.fps
var x_speed = 2 * Settings.fps

onready var size = $AnimatedSprite.frames.get_frame('default', 0).get_size()
onready var screen_size = get_viewport_rect().size

func _ready():
  add_to_group('hero_weapons')

func _process(delta):
	# make the laser go back and forth on the x-axis
	# giving a slight blurry effect that improves visuals
	x_speed = -x_speed
	var velocity = Vector2(x_speed, -speed)
	position += velocity * delta

	if (position.y + size.y / 2) < 0:
		queue_free()
