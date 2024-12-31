extends CharacterBody2D
signal healthChanged
@onready var animating_dino = $animating_dino
@onready var heart_icon = $UI/heart
@onready var transition = $"../transition"
@onready var damaged = $SFX/damaged
@onready var walking_grass = $"SFX/walking grass"
@onready var wooden_sword = $"CollisionShape2D/wooden sword"

#variables
#damage variables
var enemy_attack_cooldown = true
var enemy_in_range = false
var dmg_sound = true
var dying_animation = false
#main variables
var heart = Global.life
var SPEED = 200
const JUMP_VELOCITY = -600
var JUMP_AGAIN = false
var died = false
var heart_str = str(heart)
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func damage(dmg):
	velocity.y = -500
	damaged.play()
	dying_animation = true
	Global.life -= dmg
	animating_dino.play("dying") # Replace with function body.
	await get_tree().create_timer(1.0).timeout
	dying_animation = false # Replace with function body.
	
func dying():
	#handle dying
	if died == true:
		Global.life = 0
		heart_icon.play("0.0")
		if dmg_sound == true:
			damaged.play()
			dmg_sound = false
		dying_animation = true
		velocity.y = -1000
		animating_dino.play("dying")
		transition.play("fade_out")
		await get_tree().create_timer(2.0).timeout
		Global.life = 3
		if get_tree():
			get_tree().reload_current_scene()
	
		
func _process(delta):
	heart = Global.life
	#animationsd heart
	
	if heart > 0:
		heart_icon.play(str(heart))
	else:
		died = true
		dying()
		
		

		#dino animation
	if (velocity.x > 1 || velocity.x < -1) and dying_animation == false:
		animating_dino.animation = "walking"
	elif dying_animation == false:
		animating_dino.animation = "default"
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if dying_animation == false:
			animating_dino.animation = "jumping"

	# Handle jump.
	if not is_on_floor() and  Input.is_action_just_pressed("up"):
		JUMP_AGAIN = true
		
	if Input.is_action_just_pressed("up") and is_on_floor(): # handle jump again
		velocity.y = JUMP_VELOCITY
		JUMP_AGAIN = false
		
	if JUMP_AGAIN and is_on_floor():
		velocity.y = JUMP_VELOCITY
		JUMP_AGAIN = false
			

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("action"):
		attack()
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 30)

	move_and_slide()
	
	#dino movement
	if velocity.x < 0:
		wooden_sword.flip_h = true
		animating_dino.flip_h = true
		
	if velocity.x > 0:
		wooden_sword.flip_h = false
		animating_dino.flip_h = false



func attack():
	if enemy_in_range == true:
		pass
	Global.player_attacking = true
	if is_on_floor_only() == true:
			position.y += 2
	wooden_sword.visible = true
	wooden_sword.play("attack")
	await get_tree().create_timer(0.5).timeout
	wooden_sword.play_backwards("attack")
	await get_tree().create_timer(0.5).timeout
	Global.player_attacking = false
	wooden_sword.visible = false

func _on_hurtbox_area_entered(area): #slime damage
	if area.name == "hitbox":
		damage(0.25)# Replace with function body.

	#if body.name == "Player":
		#transition.play("fade_out")
		#await get_tree().create_timer(2.0).timeout
		#get_tree().change_scene_to_file("res://scenes/house.tscn") # Replace with function body.





func _on_damagebox_area_entered(area):
	if area.has_method("enemy"):
		enemy_in_range = true # Replace with function body.


func _on_damagebox_area_exited(area):
	if area.has_method("enemy"):
		enemy_in_range = false # Replace with function body.


func _on_damagebox_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_range = true
	 # Replace with function body.


func _on_damagebox_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_range = false # Replace with function body.
