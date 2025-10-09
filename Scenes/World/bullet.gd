extends CharacterBody2D
class_name Bullet

enum SIDE{
	PLAYER = 1,
	ENEMY
}

var bullet_dir := Vector2.ZERO
var speed := 20.0

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(bullet_dir * speed)

	if(not collision): return
	var collider = collision.get_collider()
	if(collider is Soldier):
		collider._on_hit(self)
	
	if(collider is TileMapLayer):
		queue_free()

func setup_bullet(pos : Vector2, dir : Vector2, side : int, barrel_offset : Vector2, exp_time := 1):
	set_collision_mask_value(side, true)
	set_collision_layer_value(side, true)
	
	look_at(dir)
	global_position = pos + barrel_offset
	bullet_dir = dir
	$ExpirationTime.wait_time = exp_time
	$ExpirationTime.start()


func _on_expiration_time_timeout() -> void:
	queue_free()
