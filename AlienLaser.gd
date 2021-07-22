extends Area2D

onready var size = $AnimatedSprite.frames.get_frame('default', 0).get_size()
onready var screen_size = get_viewport_rect().size

var x_speed = AlienVariables.laser_x_speed

func _ready():
  add_to_group('alien_weapons')

func _process(delta):
	# make the laser go back and forth on the x-axis
	# giving a slight blurry effect that improves visuals
	x_speed = -x_speed
	var velocity = Vector2(x_speed, AlienVariables.laser_speed)
	position += velocity * delta

	if (position.y - size.y / 2) > screen_size.y:
		queue_free()

