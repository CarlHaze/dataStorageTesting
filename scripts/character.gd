class_name Player
extends CharacterBody3D

#movement
@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Camera
@onready var cam_mount = $CamMount
@export var horizontal_sensitivity = 0.2
@export var vertical_sensitivity = 0.2
@onready var first_person_cam = %FirstPersonCam
var vertical_angle = 0

func _ready():
	set_process_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #for locking mouse to game screen

func on_item_picked_up(item:Item):
	print("I got a ", item.name)

#mouse motion
func _input(event):
	if event is InputEventMouseMotion:
		#mouse function on the x axis converts from deg to a radiant becasue input takes radiant and 1 pixel will make it spin
		rotate_y(deg_to_rad(-event.relative.x * horizontal_sensitivity)) 

		var new_angle = vertical_angle + (-event.relative.y * vertical_sensitivity)
	 	#clamp this angle stop doing flips around the character >> 
		new_angle = clamp(new_angle, -60, 60)

		var delta_angle = new_angle - vertical_angle
		cam_mount.rotate_x(deg_to_rad(delta_angle))

		vertical_angle = new_angle

#Movement.
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#Handle sprint.
	var sprint_speed = speed
	if Input.is_action_pressed("sprint"):
		sprint_speed += 2.5
		
	if direction:
		velocity.x = direction.x * sprint_speed
		velocity.z = direction.z * sprint_speed
	else:
		velocity.x = move_toward(velocity.x, 0, sprint_speed)
		velocity.z = move_toward(velocity.z, 0, sprint_speed)

	move_and_slide()
