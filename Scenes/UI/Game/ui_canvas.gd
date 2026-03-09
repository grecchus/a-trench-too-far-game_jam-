extends CanvasLayer


func _process(delta: float) -> void:
	if not get_parent() is MAIN: return
	$UIMain/Wave.text = "WAVE: " + str(get_parent().wave)
	var time_left = round(get_parent().wave_timer.time_left)
	$UIMain/WaveTimer.text = "Time to next wave: " + str(time_left)
	$UIMain/RightPanel/Ammo.text = str(get_parent().Player.magazine) + " / " + str(get_parent().Player.magazine_capacity)
	$UIMain/RightPanel/Supplies.text = str(get_parent().supplies)
	
func _ready():
	$UIMain/BuildingMenu/FieldMenu.hide()
	$UIMain/BuildingMenu/TrenchMenu.hide()


func _on_field_menu_id_pressed(id: int) -> void:
	if not get_parent() is MAIN: return
	get_parent().build_field(id)


func _on_trench_menu_id_pressed(id: int) -> void:
	if not get_parent() is MAIN: return
	get_parent().build_trench(id)


func _on_retry_pressed() -> void:
	if not get_parent() is MAIN: return
	print("dziala")
	get_tree().paused = false
	get_parent().new_game()
	$UIMain/GameOver.hide()


func _on_objective_fade_timeout() -> void:
	$UIMain/StartGame.hide()
