extends Area2D

var speed = 4 * Settings.fps

onready var size = $AnimatedSprite.frames.get_frame('default', 0).get_size()
onready var screen_size = get_viewport_rect().size

func _ready():
  add_to_group('hero_weapons')

func _process(delta):
	var velocity = Vector2(0, -speed)
	position += velocity * delta

	if (position.y + size.y / 2) < 0:
		queue_free()
