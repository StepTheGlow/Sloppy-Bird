extends Node2D
@onready var transition = $transition

func _on_touch_screen_button_pressed():
	transition.play("fade_out")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/regions/ghost_town/ghost_town.tscn")
