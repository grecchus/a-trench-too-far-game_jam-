extends Node2D
class_name MAIN

@onready var infantry_scene = preload("res://Scenes/Player/infantry.tscn")
@onready var mg_scene = preload("res://Scenes/Player/machine_gun.tscn")

enum TILE_SOURCES{
	TERRAIN
}

enum TILE_TYPE{
	NORMAL,
	LINE
}

enum FIELD{
	TRENCH,
	MORTAR,
	MINES
}
enum TRENCH{
	INFANTRY,
	MACHINE_GUN
}

@export var build_costs_field : Dictionary = {
	FIELD.TRENCH : 10,
	FIELD.MORTAR : 80,
	FIELD.MINES : 20,
}
@export var build_costs_trench : Dictionary = {
	TRENCH.INFANTRY : 20,
	TRENCH.MACHINE_GUN : 60
}

@export var line : int = 10
var wave : int = 0
@export var starting_supplies := 120
var supplies : int = 120
var unit_occupied_cells : Array[Vector2i]
var saved_mouse_pos : Vector2i
@onready var map_height = $Tiles/Terrain.get_used_rect().end.y
@onready var wave_timer = $WaveTimer
@onready var Player = $Player
var player_start_pos : Vector2
const TILE_SIZE := Vector2(64.0, 64.0)

func _ready():
	player_start_pos = Player.global_position
	new_game()
	print($Tiles/Terrain.get_used_rect())
	supplies = starting_supplies
	GV.LINE = line
	for tile_y in map_height:
		$Tiles/Terrain.set_cell(Vector2i(line, tile_y), TILE_SOURCES.TERRAIN, Vector2i(TILE_TYPE.LINE,0))
	$EnemyHandler._setup()
	$UICanvas.show()

func _process(delta: float) -> void:
	var mouse_tm_pos = $Tiles/Terrain.local_to_map(get_global_mouse_position())
	if(Input.is_action_just_pressed("right_click")):
		if($UICanvas/UIMain/BuildingMenu/FieldMenu.visible or $UICanvas/UIMain/BuildingMenu/TrenchMenu.visible):
			get_tree().call_group("BuildingUI", "hide")
			print("should hide")
			return
		var atl_coords = $Tiles/Terrain.get_cell_atlas_coords(mouse_tm_pos)
		saved_mouse_pos = mouse_tm_pos
		if(atl_coords.y == 0):
			$UICanvas/UIMain/BuildingMenu/FieldMenu.show()
			$UICanvas/UIMain/BuildingMenu/TrenchMenu.hide()
			#$Tiles/Terrain.set_cell(mouse_tm_pos, 0, Vector2i(atl_coords.x, 1))
		else:
			$UICanvas/UIMain/BuildingMenu/FieldMenu.hide()
			$UICanvas/UIMain/BuildingMenu/TrenchMenu.show()
			
		$UICanvas/UIMain/BuildingMenu.position = $UICanvas/UIMain.get_local_mouse_position()
		$UICanvas/UIMain/BuildingMenu/FieldMenu.position = $UICanvas/UIMain/BuildingMenu.global_position
		$UICanvas/UIMain/BuildingMenu/TrenchMenu.position = $UICanvas/UIMain/BuildingMenu.global_position

func new_game():
	supplies = starting_supplies
	
	for enemy in $EnemyHandler.get_children():
		enemy.queue_free()
	
	for enemy in $AlliedUnits.get_children():
		enemy.queue_free()
	unit_occupied_cells = []
	
	for tile in $Tiles/Terrain.get_used_cells():
		$Tiles/Terrain.set_cell(tile, 0, Vector2i(0, 0))
	
	for tile_y in map_height:
		$Tiles/Terrain.set_cell(Vector2i(line, tile_y), TILE_SOURCES.TERRAIN, Vector2i(TILE_TYPE.LINE,0))
		
	Player.global_position = player_start_pos
	
	wave = 0
	$EnemyHandler.wave_time = 20.0
	$EnemyHandler.wave_ended()
	print("dziala tutej")



func _game_over():
	$UICanvas/UIMain/GameOver.show()
	$WaveTimer.stop()
	get_tree().paused = true
	
	
func spawn_unit(unit_scene : Resource, pos : Vector2i):
	var new_unit = unit_scene.instantiate()
	$AlliedUnits.add_child(new_unit)
	new_unit.position = $Tiles/Terrain.map_to_local(pos)
	
func build_field(id : int):
	if(build_costs_field[id] > supplies): return
	match id:
		FIELD.TRENCH:
			var atl_coords = $Tiles/Terrain.get_cell_atlas_coords(saved_mouse_pos)
			if(atl_coords.y == 0):
				$Tiles/Terrain.set_cell(saved_mouse_pos, 0, Vector2i(atl_coords.x, 1))
		FIELD.MORTAR:
			return
		FIELD.MINES:
			return
	supplies -= build_costs_field[id]


func build_trench(id : int):
	var unit_scene : Resource
	match id:
		TRENCH.INFANTRY:
			unit_scene = infantry_scene
		TRENCH.MACHINE_GUN:
			unit_scene = mg_scene
	if(build_costs_trench[id] > supplies): return
	if(not unit_occupied_cells.has(saved_mouse_pos)):
		supplies -= build_costs_trench[id]
		unit_occupied_cells.append(saved_mouse_pos)
		spawn_unit(unit_scene, saved_mouse_pos)

func _setup_map_borders():
	var bound_rect = $Tiles/Terrain.get_used_rect()
	var bound_min = bound_rect.position * TILE_SIZE
	var bound_max = bound_rect.end * TILE_SIZE
	
	
	var h_size = Vector2(bound_rect.size.x * TILE_SIZE, TILE_SIZE.y)
	var v_size = Vector2(TILE_SIZE.x, bound_rect.size.y * TILE_SIZE)
	
	#top border
	$Tiles/Border/Top.shape.size = h_size
	$Tiles/Border/Top.global_position = Vector2(h_size.x, -h_size.y) / 2.0 + bound_min
	
	#bottom border
	$Tiles/Border/Bottom.shape.size = h_size
	$Tiles/Border/Bottom.global_position = Vector2(h_size.x, h_size.y) / 2.0 + bound_min + Vector2(0, bound_max.y)
	
	#top border
	$Tiles/Border/Right.shape.size = v_size
	$Tiles/Border/Right.global_position = Vector2(v_size.x, v_size.y) / 2.0 + Vector2(bound_max.x, 0)
	
	#bottom border
	$Tiles/Border/Left.shape.size = v_size
	$Tiles/Border/Left.global_position = Vector2(v_size.x, -v_size.y) / 2.0 + bound_min
