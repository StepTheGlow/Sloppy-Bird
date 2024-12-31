extends Node2D
@onready var transition = $transition
@onready var player = $Player
@onready var camera_2d = $Player/Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	camera_2d.limit_left = 50
	camera_2d.limit_right = 2000 # limit camera


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_to_ghost_town_body_entered(body):
	if body.name == "Player":                 #change scene
		transition.play("fade_out")
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/ghost_town.tscn")
