extends Area2D

onready var size = $AnimatedSprite.frames.get_frame('default', 0).get_size()
onready var screen_size = get_viewport_rect().size

func _ready():
  add_to_group('alien_weapons')

func _process(delta):
	var velocity = Vector2(0, AlienVariables.laser_speed)
	position += velocity * delta

	if (position.y - size.y / 2) > screen_size.y:
		queue_free()

