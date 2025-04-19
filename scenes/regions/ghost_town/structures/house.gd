extends Node2D
var in_chest = false
var in_house_door = false
var opened_chest = false
@onready var transition = $transition
@onready var tooltip = $Player/CollisionShape2D/tooltip
@onready var chest = $chest


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_house_door == true:
		if Input.is_action_just_pressed("action"):
			exit_from_house()
	if in_chest == true:
		if Input.is_action_just_pressed("action"):
			open_chest()
	
	
func exit_from_house():
	Global.loaded_game = false
	transition.play("fade_out")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/regions/ghost_town/ghost_town.tscn")
	
	
	
func _on_door_body_entered(body):
	if body.name == "Player":
		tooltip.visible = true  #shows tooltipp
		in_house_door = true


func _on_door_body_exited(body):
	if body.name == "Player":
		tooltip.visible = false
		in_house_door = false

func _on_chest_body_entered(body):
	if body.name == "Player":
		tooltip.visible = true
		in_chest = true  # Replace with function body.


func _on_chest_body_exited(body):
	if body.name == "Player":
		tooltip.visible = false
		in_chest = false
		if opened_chest == true:
			chest.play_backwards("opening")
			opened_chest = false # Replace with function body.
	
func open_chest():
	tooltip.visible = false
	opened_chest = true
	chest.play("opening")


func _on_ladder_body_entered(body):
	if body.name == "Player":
		$Player.gravity = 0
		$Player.velocity.y -= 100 # Replace with function body.


func _on_ladder_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$Player.gravity = 980 # Replace with function body.
