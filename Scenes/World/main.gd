extends Node2D
class_name MAIN

@onready var infantry_scene = preload("res://Scenes/Player/infantry.tscn")

enum TILE_SOURCES{
	TERRAIN
}

enum TILE_TYPE{
	NORMAL,
	LINE
}

@export var line : int = 10
var wave : int = 0
var supplies : int = 100
var unit_occupied_cells : Array[Vector2i]
@onready var map_height = $Tiles/Terrain.get_used_rect().end.y
@onready var wave_timer = $WaveTimer
@onready var Player = $Player
const TILE_SIZE := Vector2(64.0, 64.0)

func _ready():
	GV.LINE = line
	for tile_y in map_height:
		$Tiles/Terrain.set_cell(Vector2i(line, tile_y), TILE_SOURCES.TERRAIN, Vector2i(TILE_TYPE.LINE,0))
	$EnemyHandler._setup()

func _process(delta: float) -> void:
	var mouse_tm_pos = $Tiles/Terrain.local_to_map(get_global_mouse_position())
	if(Input.is_action_just_pressed("right_click")):
		var atl_coords = $Tiles/Terrain.get_cell_atlas_coords(mouse_tm_pos)
		if(atl_coords.y == 0):
			$Tiles/Terrain.set_cell(mouse_tm_pos, 0, Vector2i(atl_coords.x, 1))
		else:
			if(not unit_occupied_cells.has(mouse_tm_pos)):
				unit_occupied_cells.append(mouse_tm_pos)
				spawn_unit(infantry_scene, mouse_tm_pos)
		#$UICanvas/UIMain/BuildingMenu.position = $UICanvas/UIMain.get_local_mouse_position()
		#$UICanvas/UIMain/BuildingMenu.show()

func _new_game():
	pass

func _game_over():
	get_tree().paused = true
	
func spawn_unit(unit_scene : Resource, pos : Vector2i):
	var new_unit = unit_scene.instantiate()
	$AlliedUnits.add_child(new_unit)
	new_unit.position = $Tiles/Terrain.map_to_local(pos)
