extends Node

export (PackedScene) var Hero
export (PackedScene) var Alien
export (PackedScene) var Starfield1
export (PackedScene) var Starfield2
export (PackedScene) var Starfield3
export (PackedScene) var Starfield4

export var wave = 0

onready var screen_size = get_viewport().size

var hero
var aliens
var alien_weapons
var hero_weapons

var starfield_1
var starfield_2
var starfield_3
var starfield_4

var min_aliens = 5
var max_aliens = 70
var num_aliens = 5
var num_columns = 5

var game_over = false

var wave_title_fade_in = true
var play_again_fade_in = true
var should_create_aliens = false

func _ready():
	Engine.set_target_fps(Settings.fps)
	randomize()

	spawn_hero()

	# Add all the stars
	starfield_1 = Starfield1.instance()
	add_child(starfield_1)
	starfield_2 = Starfield2.instance()
	add_child(starfield_2)
	starfield_3 = Starfield3.instance()
	add_child(starfield_3)
	starfield_4 = Starfield4.instance()
	add_child(starfield_4)


func _process(delta):
	if Input.is_action_pressed("quit"):
		get_tree().quit()

	if Input.is_action_just_released("toggle_fullscreen"):
			OS.window_fullscreen = !OS.window_fullscreen

	aliens = get_tree().get_nodes_in_group('aliens')
	alien_weapons = get_tree().get_nodes_in_group('alien_weapons')
	hero_weapons = get_tree().get_nodes_in_group('hero_weapons')

	AlienVariables.fire_timer -= 1

	# Fire alien lasers by picking a random alien to fire
	if aliens.size() > 0 and AlienVariables.fire_timer <= 0 and is_instance_valid(hero):
		AlienVariables.fire_timer = AlienVariables.fire_delay
		# Get a random alien
		var index = randi() % aliens.size()
		aliens[index].fire()

	# move aliens and check edge conditions
	for alien in aliens:
		alien.move(AlienVariables.direction, delta)
		var half_width = alien.get_node('AnimatedSprite').frames.get_frame('fly', 0).get_size().x / 2
		if (alien.position.x + half_width > screen_size.x) or (alien.position.x - half_width < 0):
			AlienVariables.should_change_direction = true

	if AlienVariables.should_change_direction:
		AlienVariables.should_change_direction = false
		AlienVariables.direction = -AlienVariables.direction
		# only move aliens down screen when game is not over
		if !game_over:
			get_tree().call_group('aliens', 'move_down', delta)

	# Start the countdown for the next wave and speed up stars
	if (aliens.size() == 0
		&& alien_weapons.size() == 0
		&& hero_weapons.size() == 0
		&& should_create_aliens == false
		&& is_instance_valid(hero)):

		# Start wave countdown timer
		if $WaveIntroTimer.time_left == 0:
			begin_wave_transition()

		# Give the illusion that the ship is accelerating to the next wave
    # by speeding up the stars and then slowing them down as we approach next wave
		var time_left = $WaveIntroTimer.time_left
		var duration = $WaveIntroTimer.wait_time
		var speed_increase = 0.02
		var speed_decrease = 0.05

		if time_left >= duration * 0.3:
			hero.accelerate()
			starfield_1.increase_speed(speed_increase)
			starfield_2.increase_speed(speed_increase)
			starfield_3.increase_speed(speed_increase)
			starfield_4.increase_speed(speed_increase)
		elif time_left > 0:
			hero.decelerate()
			starfield_1.decrease_speed(speed_decrease)
			starfield_2.decrease_speed(speed_decrease)
			starfield_3.decrease_speed(speed_decrease)
			starfield_4.decrease_speed(speed_decrease)

	if (should_create_aliens
		&& hero.position.y >= $StartPosition.position.y - 3
		&& hero.position.y <= $StartPosition.position.y + 3):
			create_aliens()
			should_create_aliens = false

	# Game Over
	if !is_instance_valid(hero):
		game_over = true
		if HeroVariables.score > HeroVariables.high_score:
			HeroVariables.high_score = HeroVariables.score

		# Slow the aliens down, now that the hero is dead
		AlienVariables.speed = AlienVariables.initial_speed

		if Input.is_action_pressed("ui_accept"):
			game_over = false
			wave = 0
			HeroVariables.score = 0

			get_tree().call_group('aliens', 'queue_free')
			get_tree().call_group('alien_weapons', 'queue_free')
			get_tree().call_group('hero_weapons', 'queue_free')

			spawn_hero()
			begin_wave_transition()

	# Pulse the wave title during transition
	var alpha = $CanvasLayer/WaveTransitionLabel.modulate.a

	if $WaveIntroTimer.time_left > 0 || alpha > 0:
		var amount = delta * 1.2

		if alpha >= 1:
			wave_title_fade_in = false
		elif alpha <= 0:
			wave_title_fade_in = true

		if wave_title_fade_in:
			$CanvasLayer/WaveTransitionLabel.modulate.a += amount
		else:
			$CanvasLayer/WaveTransitionLabel.modulate.a -= amount


	# Update labels
	$CanvasLayer/ScoreValueLabel.text = str(HeroVariables.score)
	$CanvasLayer/HiscoreValueLabel.text = str(HeroVariables.high_score)

	# Get the right wave number. If the timer has stopped, then we are still working
	# on fading out the wave title. In this case the wave will have advanced, but we still
	# want to show the old wave number
	var wave_number = wave if $WaveIntroTimer.is_stopped() else wave + 1
	$CanvasLayer/WaveTransitionLabel.text = str("Wave ", wave_number)

	if game_over:
		$CanvasLayer/GameOverLabel.visible = true
		$CanvasLayer/PlayAgainLabel.visible = true
		# Pulse the wave title during transition
		var play_again_alpha = $CanvasLayer/PlayAgainLabel.modulate.a

		var amount = delta * 0.7

		if play_again_alpha >= 1:
			play_again_fade_in = false
		elif play_again_alpha <= 0:
			play_again_fade_in = true

		if play_again_fade_in:
			$CanvasLayer/PlayAgainLabel.modulate.a += amount
		else:
			$CanvasLayer/PlayAgainLabel.modulate.a -= amount
	else:
		$CanvasLayer/GameOverLabel.visible = false
		$CanvasLayer/PlayAgainLabel.visible = false

func start_next_wave():
	wave += 1
	$CanvasLayer/WaveValueLabel.text = str(wave)

	var wave_multiplier = wave - 1

	# Calculate weapon fire rate and velocity
	hero.fire_delay = hero.initial_fire_delay
	hero.speed = hero.initial_speed
	AlienVariables.fire_delay = AlienVariables.initial_fire_delay
	AlienVariables.laser_speed = AlienVariables.initial_laser_speed

	for _index in range(1, wave):
		hero.fire_delay = hero.fire_delay - (hero.fire_delay * 0.05)
		AlienVariables.fire_delay = clamp(
			AlienVariables.fire_delay - (AlienVariables.fire_delay * 0.1),
			AlienVariables.min_fire_delay,
			AlienVariables.initial_fire_delay
		)

		hero.speed = hero.speed + (hero.speed * 0.01)
		AlienVariables.laser_speed = AlienVariables.laser_speed + (AlienVariables.laser_speed * 0.01)

	AlienVariables.speed = AlienVariables.initial_speed + (wave_multiplier * 0.1 * Settings.fps)
	AlienVariables.point_value = AlienVariables.point_value + (wave_multiplier * 10)

	should_create_aliens = true

func create_aliens():
	var column = 0
	var row = 0
	var padding = 55
	var start_x = 0 + padding
	var start_y = 25

	var wave_multiplier = wave - 1

	if wave == 1:
		num_columns = 5

	num_aliens = clamp(min_aliens + (wave_multiplier * 3), min_aliens, max_aliens)


	if float(num_aliens) / float(num_columns) > 7:
		num_columns = 10

	for index in range(0, num_aliens):
		if index % num_columns == 0:
			column = 0
			row += 1
		else:
			column += 1

		var alien = Alien.instance()
		alien.position = Vector2(
			start_x + column * padding,
			start_y + row * padding
		)
		add_child(alien)

func spawn_hero():
	hero = Hero.instance()
	hero.position = $StartPosition.position
	add_child(hero)

func begin_wave_transition():
	$WaveIntroTimer.start()
	$CanvasLayer/WaveTransitionLabel.visible = true
	$CanvasLayer/WaveTransitionLabel.modulate.a = 0

# start the next wave when aliens and weapons are gone
func _on_WaveIntroTimer_timeout():
	hero.reset_acceleration()
	starfield_1.reset_speed()
	starfield_2.reset_speed()
	starfield_3.reset_speed()
	starfield_4.reset_speed()
	start_next_wave()

