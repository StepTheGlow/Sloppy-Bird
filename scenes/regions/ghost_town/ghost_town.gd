extends Node2D
#player position variables
var player_start_posx = 250
var player_start_posy = -50
var back_house_posx = 880
var back_house_posy = -824
var back_bazaar_posx = 8719 #back from bazaar
var back_bazaar_posy = -1918
var in_house_door = false
#node
@onready var transition = $transition
@onready var camera_2d = $Player/Camera2D
@onready var tooltip = $Player/CollisionShape2D/tooltip
@onready var gpu_particles_2d = $Player/UI/GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_2d.limit_right = 9640
	camera_2d.limit_bottom = 190   #limit camera
	#change player position
	if Global.loaded_game == true:
		$Player.position.x = player_start_posx
		$Player.position.y = player_start_posy
	elif Global.entered_bazaar == true: # Replace with function body. 
		$Player.position.x = back_bazaar_posx #back from bazaar
		$Player.position.y = back_bazaar_posy
		Global.entered_sword_house = false
	elif Global.entered_sword_house == true:
		$Player.position.x = back_house_posx
		$Player.position.y = back_house_posy
	else:
		$Player.position.x = player_start_posx
		$Player.position.y = player_start_posy
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	gpu_particles_2d.visible = true
	camera_2d.limit_right = 9640
	if in_house_door == true:
		if Input.is_action_just_pressed("action"):
			go_to_house()



func _on_bazaar_body_entered(body):
	if body.name == "Player":
		Global.entered_bazaar = true
		transition.play("fade_out")
		await get_tree().create_timer(2.0).timeout
		Global.loaded_game = false
		get_tree().change_scene_to_file("res://scenes/regions/bazaar/Bazaar.tscn")

 # Replace with function body.
func go_to_house():
	Global.entered_sword_house = true
	transition.play("fade_out")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/regions/ghost_town/structures/house.tscn")

func _on_house_body_entered(body):
	if body.name == "Player":
		tooltip.visible = true
		in_house_door = true
		
		#get_tree().change_scene_to_file() # Replace with function body.


func _on_house_body_exited(body):
	if body.name == "Player":
		tooltip.visible = false
		in_house_door = false # Replace with function body.


func _on_death_zone_body_entered(body: Node2D) -> void:
	if body == $Player:
		Global.life = 0
