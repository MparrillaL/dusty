extends Control


func _on_resume_game_pressed() -> void:
	get_tree().change_scene_to_file("res://escena_principal/escena_principal.tscn")


func _on_inventory_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
