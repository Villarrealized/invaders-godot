extends Area2D

export (PackedScene) var AlienLaser
export (PackedScene) var AlienExplosion

var step_height = 16 * Settings.fps

onready var size = $AnimatedSprite.frames.get_frame('fly', 0).get_size()
onready var scene_root = get_tree().get_root()

func _ready():
  add_to_group('aliens')

  var frame_count = $AnimatedSprite.frames.get_frame_count('fly')
  # Pick a random frame
  $AnimatedSprite.frame = randi() % frame_count

func move(direction, delta):
  var velocity = Vector2()

  velocity.x += AlienVariables.speed * direction

  position += velocity * delta

func move_down(delta):
  var velocity = Vector2()
  velocity.y += step_height
  position += velocity * delta

func fire():
  var laser = AlienLaser.instance()
  var offset = Vector2(0, self.size.y / 2)
  laser.position = self.position + offset
  scene_root.add_child(laser)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Alien_area_entered(area):
  if (area.is_in_group('hero_weapons')
    || area.is_in_group('hero')):

    var explosion = AlienExplosion.instance()
    explosion.one_shot = true
    explosion.position = self.position
    scene_root.add_child(explosion)

    if scene_root.get_tree().get_nodes_in_group('hero').size() > 0:
      HeroVariables.score += AlienVariables.point_value

    queue_free()
    area.queue_free()
