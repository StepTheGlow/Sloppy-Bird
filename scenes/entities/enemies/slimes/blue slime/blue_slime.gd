extends CharacterBody2D
@onready var blue_slime_animation = $blue_slime_animation
@onready var ray_cast_2d_left = $RayCast2D_left 
@onready var ray_cast_2d_right = $RayCast2D_right



var speed = -30
const JUMP_VELOCITY = -400.0
var turn_left = false
var turn_right = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if ray_cast_2d_left.is_colliding() == false or ray_cast_2d_right.is_colliding() == false and is_on_floor():
		flip()
		
	velocity.x = speed
	move_and_slide()

func flip():
	turn_right = !turn_right
	scale.x = abs(scale.x) * 1
		
	if turn_right == true:
		speed = abs(speed)
		blue_slime_animation.play("blue_right")
	else:
		speed = abs(speed) * -1
		blue_slime_animation.play("blue_left")


func _on_hitbox_area_entered(_area): # Replace with function body.
	flip()
