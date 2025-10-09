extends Soldier

@onready var bullet_scene = preload("res://Scenes/World/bullet.tscn")

var rng := RandomNumberGenerator.new()
const accel := 5.0
const sprint_mult := 2.0
@export var gun_barrel_offset = 24.0

var able_to_shoot := true

@export var accuracy := 0.95
@onready var angle_spread := 90.0*(1 - accuracy)

var fire_rate_delay_on := false
var fire_rate := 0.2

var reloading := false
var reload_time := 2.0
var magazine_capacity := 7
var magazine := 7


func _physics_process(delta: float) -> void:
	var movement : Vector2
	var speed = SPEED
	able_to_shoot = not fire_rate_delay_on and not reloading
	
	movement.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	movement.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	movement = movement.normalized()
	if(Input.is_action_pressed("sprint")): speed *= sprint_mult
	if(Input.is_action_just_pressed("left_click") and able_to_shoot): _shoot()
	if(Input.is_action_just_pressed("reload") and able_to_shoot): _reload()
	
	look_at(get_global_mouse_position())
	
	movement = lerp(movement, movement * speed, accel*delta)

	move_and_collide(movement)

func _shoot():
	rng.randomize()
	if($Gunshot.playing): return
	var direction = (get_global_mouse_position() - global_position).normalized()
	var bullet : CharacterBody2D = bullet_scene.instantiate()
	add_child(bullet)
	var barrel_offset : Vector2 =  direction * gun_barrel_offset
	var angle = asin(direction.y) + deg_to_rad(rng.randf_range(-angle_spread,angle_spread))
	var dir = Vector2(sign(direction.x)*cos(angle), sin(angle))
	bullet.setup_bullet(self.global_position, dir, bullet.SIDE.ENEMY, barrel_offset, 2.0)
	
	fire_rate_delay_on = true
	$FireRate.wait_time = fire_rate
	$FireRate.start()
	
	magazine -= 1
	if(magazine == 0):
		_reload()
	$Gunshot.play()

func _reload():
	reloading = true
	$Reload.wait_time = reload_time
	$Reload.start()
	await $Reload.timeout
	magazine = magazine_capacity


func _on_reload_timeout() -> void:
	reloading = false


func _on_fire_rate_timeout() -> void:
	fire_rate_delay_on = false
