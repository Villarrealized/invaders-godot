extends Area2D

export (PackedScene) var HeroExplosion
export (PackedScene) var HeroLaser

export var initial_fire_delay = 0.75 * Settings.fps
export var initial_speed = 4 * Settings.fps

var fire_timer = 0
var fire_delay = initial_fire_delay
var speed = initial_speed
var acceleration = 0
var decelerate_hero = false


onready var screen_size = get_viewport_rect().size
onready var scene_root = get_tree().get_root()

onready var initial_position = position

onready var size = $AnimatedSprite.frames.get_frame('up', 0).get_size()

onready var initial_thrust_speed = $HeroThrust.speed_scale
onready var initial_thrust_velocity = $HeroThrust.process_material.initial_velocity

func _ready():
	z_index = 100
	add_to_group('hero')

func _process(delta):
	var velocity = Vector2()
	fire_timer -= 1

	velocity.y += acceleration

	if decelerate_hero:
		if position.y < initial_position.y:
			acceleration += acceleration * 0.01
		else:
			decelerate_hero = false
			acceleration = 0

	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		$HeroThrust.process_material.tangential_accel = 45
		$AnimatedSprite.animation = "right"
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
		$HeroThrust.process_material.tangential_accel = -45
		$AnimatedSprite.animation = "left"
	if !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left"):
		$AnimatedSprite.animation = "up"
		$HeroThrust.process_material.tangential_accel = 0
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


func accelerate():
	$HeroThrust.speed_scale += $HeroThrust.speed_scale * .005
	$HeroThrust.process_material.initial_velocity += $HeroThrust.process_material.initial_velocity * .005
	var acceleration_amount = -15 if acceleration == 0 else (acceleration * .004)
	acceleration += acceleration_amount

func decelerate():
	$HeroThrust.speed_scale -= $HeroThrust.speed_scale * .01
	$HeroThrust.process_material.initial_velocity -= $HeroThrust.process_material.initial_velocity * .01
	var acceleration_amount = 15 if acceleration < 0 else (acceleration * .02)
	acceleration += acceleration_amount

func reset_acceleration():
	$HeroThrust.speed_scale = initial_thrust_speed
	$HeroThrust.process_material.initial_velocity = initial_thrust_velocity
	decelerate_hero = true

