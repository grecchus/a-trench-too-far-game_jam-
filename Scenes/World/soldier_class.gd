extends CharacterBody2D
#every "walking" entity should be of this class
class_name Soldier

@export var SPEED := 10.0
signal soldier_down

var HP := 3 : 
	set(new_hp):
		HP = new_hp
		if(HP <= 0):
			emit_signal("soldier_down")
			queue_free()

func _on_hit(collider):
	if(not collider): return
	HP -= 1
	collider.queue_free()
