extends CanvasLayer


func _process(delta: float) -> void:
	if not get_parent() is MAIN: return
	$UIMain/Wave.text = "WAVE: " + str(get_parent().wave)
	var time_left = round(get_parent().wave_timer.time_left)
	$UIMain/WaveTimer.text = "Time to next wave: " + str(time_left)
	$UIMain/Ammo.text = str(get_parent().Player.magazine) + " / " + str(get_parent().Player.magazine_capacity)
