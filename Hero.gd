extends Area2D

export (PackedScene) var HeroExplosion
export (PackedScene) var HeroLaser

export var initial_fire_delay = 0.75 * Settings.fps
export var initial_speed = 4 * Settings.fps

var fire_timer = 0
var fire_delay = initial_fire_delay
var speed = initial_speed

onready var screen_size = get_viewport_rect().size
onready var scene_root = get_tree().get_root()

onready var size = $AnimatedSprite.frames.get_frame('up', 0).get_size()

func _ready():
	z_index = 100
	add_to_group('hero')

func _process(delta):
	var velocity = Vector2()
	fire_timer -= 1

	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		$AnimatedSprite.animation = "right"
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
		$AnimatedSprite.animation = "left"
	if !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left"):
		$AnimatedSprite.animation = "up"
	if Input.is_action_pressed("fire"):
		# Prevent player from firing when no aliens are on screen
		# For purposes of wave transition
		var alien_count = scene_root.get_tree().get_nodes_in_group('aliens').size()
		if alien_count > 0:
			fire()

	# Move the hero
	position += velocity * delta

	# Prevent hero from going out of bounds
	var half_size = size.x / 2
	position.x = clamp(position.x, 0 + half_size, screen_size.x - half_size)

func _on_Hero_area_entered(area):
	if (area.is_in_group('alien_weapons')
    || area.is_in_group('alien')):
		var explosion = HeroExplosion.instance()
		explosion.one_shot = true
		explosion.position = self.position
		scene_root.add_child(explosion)

		queue_free()
		area.queue_free()


func fire():
	if fire_timer <= 0:
		fire_timer = fire_delay
		var laser = HeroLaser.instance()
		var offset = Vector2(0, -self.size.y / 2)
		laser.position = self.position + offset
		scene_root.add_child(laser)
