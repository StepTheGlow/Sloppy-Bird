extends CharacterBody2D
@onready var red_slime_animation = $red_slime_animation
@onready var ray_cast_2d_left = $RayCast2D_left 
@onready var ray_cast_2d_right = $RayCast2D_right
@onready var damage_cooldown = $"damage cooldown"

var can_take_damage = true
var player_in_range = false
var damage = 0
var dead = false
const max_life = 15
var life = 10
var speed = -50
const JUMP_VELOCITY = -400.0
var turn_left = false
var turn_right = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _process(delta):
	deal_with_damage()
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
		red_slime_animation.play("red_right")
	else:
		speed = abs(speed) * -1
		red_slime_animation.play("red_left")

func deal_with_damage():
	if Global.player_attacking == true and player_in_range == true and can_take_damage == true:
		damage = 5
		print(life)
		velocity.y -= 500
		damage_cooldown.start()
		can_take_damage = false
		Global.player_attacking = false
		print(life)
		take_damage(damage)
func enemy():
	pass

func _on_damage_cooldown_timeout():
	can_take_damage = true #cooldown
	
func take_damage(damage_taken):
	life = life - damage_taken
	if life <= 0 and !dead:
		death()
func death():
	dead = true
	await get_tree().create_timer(1).timeout
	queue_free()
	
	
func _on_hitbox_area_entered(_area): # Replace with function body.
	flip()
	
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_in_range = true # Replace with function body.


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_in_range = false # Replace with function body.
