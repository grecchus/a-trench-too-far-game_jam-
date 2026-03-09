extends Node
#here will be code for spawning enemies and controlling them
@onready var enemy_infantry_scene = preload("res://Scenes/Enemy/enemy_infantry.tscn")
@onready var main = get_parent()
@onready var wave_timer = get_node("/root/Main/WaveTimer")
@onready var terrain : TileMapLayer = get_node("/root/Main/Tiles/Terrain")
var rng = RandomNumberGenerator.new()

enum OUT_OF_BOUNDS{
	FALSE,
	TOP,
	BOTTOM
}

var offset_multiplier = [-1, 1]

var map_height
var wave_time := 20.0
var potential_spawnpoints : Array[int]
var between_wave_wait := true
@onready var tile_size = terrain.tile_set.tile_size
var y_bounds : float

func _setup() -> void:
	rng.randomize()
	map_height = main.map_height
	y_bounds = float(map_height)*tile_size.y
	for i in map_height:
		potential_spawnpoints.append(i)


##
## Spawning enemies
##

func _choose_spawnpoints():
	var ps_copy := potential_spawnpoints.duplicate()
	var spawnpoints : Array = []
	var spawnpoint_count = clamp((main.wave/3), 3, map_height)
	var new_enemy_position : Vector2
	var enemy_count : int = spawnpoint_count*3 + rng.randi_range(-2,4)
	
	for i in spawnpoint_count:
		spawnpoints.append(ps_copy.pick_random())
		ps_copy.erase(spawnpoints.back())
		
		var enemy_group_count = enemy_count / (spawnpoint_count-i)
		enemy_count -= enemy_group_count
		var y_offset = main.TILE_SIZE.y / enemy_count
		
		for j in enemy_group_count:
			new_enemy_position = terrain.map_to_local(Vector2i(-1, spawnpoints[i])) + Vector2(rng.randf_range(-16.0, 16.0),
				offset_multiplier[j%2]*y_offset*j)
			var out_of_bounds = _is_out_of_bounds(new_enemy_position)
			if(out_of_bounds == OUT_OF_BOUNDS.TOP):
				new_enemy_position = terrain.map_to_local(Vector2i(-1, spawnpoints[i])) + Vector2(rng.randf_range(-16.0, 16.0),
				y_offset*j)
			if(out_of_bounds == OUT_OF_BOUNDS.BOTTOM):
				new_enemy_position = terrain.map_to_local(Vector2i(-1, spawnpoints[i])) + Vector2(rng.randf_range(-16.0, 16.0),
				-y_offset*j)
			_spawn_enemy(enemy_infantry_scene, new_enemy_position)

func _spawn_enemy(enemy_scene : Resource, position : Vector2):
	var new_enemy = enemy_scene.instantiate()
	add_child(new_enemy)
	new_enemy.game_over.connect(main._game_over)
	new_enemy.soldier_down.connect(_on_enemy_down)
	new_enemy.position = position

##
## Wave handling
##

func new_wave():
	_choose_spawnpoints()

func wave_ended():
	wave_timer.stop()
	between_wave_wait = true
	wave_timer.wait_time = 5.0
	wave_timer.start()

func _on_enemy_down():
	if(get_child_count() == 1):
		wave_ended()


func _on_wave_timer_timeout() -> void:
	if(not between_wave_wait):
		main.supplies += 30*clamp(main.wave/6, 1, 10)
	else: between_wave_wait = false
	new_wave()
	main.wave += 1
	wave_time = clamp(wave_time - 2*(main.wave/6), 2.0, 20.0)
	wave_timer.wait_time = wave_time
	wave_timer.start()

func _is_out_of_bounds(pos : Vector2) -> int:
	if pos.y > y_bounds:
		return OUT_OF_BOUNDS.BOTTOM
	if pos.y < 0:
		return OUT_OF_BOUNDS.TOP
	return OUT_OF_BOUNDS.FALSE 
