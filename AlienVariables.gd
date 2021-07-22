extends Node

var direction = 1
var should_change_direction = false

var min_fire_delay = Settings.fps / 4
var initial_fire_delay = Settings.fps * 4
var fire_delay = initial_fire_delay
var fire_timer = 0

var initial_speed = Settings.fps * 0.5
var speed = initial_speed

var initial_laser_speed = Settings.fps * 2
var laser_speed = initial_laser_speed
var laser_x_speed = Settings.fps * 2

var point_value = 40