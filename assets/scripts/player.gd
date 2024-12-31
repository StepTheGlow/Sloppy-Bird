extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#VARIABLES
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var Bird = "NIGHTPOOL"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if direction == 1:
			animated_sprite_2d.play(Bird+"_WALK")
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.play(Bird+"_WALK")
			animated_sprite_2d.flip_h =  true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.play(Bird+"_IDLE")

	move_and_slide()

										# BUTTONS #

func _on_touch_screen_button_pressed() -> void:
	animated_sprite_2d.play("NIGHTPOOL_WALK")
	animated_sprite_2d.flip_h =  true

func _on_button_button_down() -> void:
	Input.action_press("ui_left")
func _on_button_button_up() -> void:
	Input.action_release("ui_left")

#RIGHT BUTTON

func _on_right_button_down() -> void:
	Input.action_press("ui_right")
func _on_right_button_up() -> void:
	Input.action_release("ui_right")

#JUMP & FLY BUTTON

func _on_jump_button_down() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		 # Replace with function body.

func _on_fly_button_down() -> void:
	velocity.y = JUMP_VELOCITY # Replace with function body.


func _on_change_pressed() -> void:
	if Bird == "NIGHTPOOL":
		Bird = "GROOVYPOOL"
	elif Bird == "GROOVYPOOL":
		Bird = "DEADPOOL" # Replace with function body.
	else:
		Bird = "NIGHTPOOL"



func _on_fall_zone_body_entered(_body: Node2D) -> void:
	velocity.y = -600
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene() # Replace with function body.
 # Replace with function body.
