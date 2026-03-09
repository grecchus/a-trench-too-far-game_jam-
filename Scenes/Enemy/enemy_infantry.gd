extends Soldier

const direction = Vector2(1.0, 0.0)
signal game_over

func _ready() -> void:
	$AnimationPlayer.play("walk")
	
func _on_hit(collider):
	if(not collider): return
	HP -= 1
	collider.queue_free()
	$Blood.emitting = true

func _physics_process(delta: float) -> void:
	
	var collision = move_and_collide(direction*SPEED)
	if(not collision): return
	
	var collider = collision.get_collider()
	if collider is TileMapLayer:
		emit_signal("game_over")
