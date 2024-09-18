extends CharacterBody3D


@onready var camera = $Camera3D
@onready var raycast = $Camera3D/PhysicsRaycast
# @onready var animation_player = get_node("../scene/projectBB/Door_Group/AnimationPlayer")
@onready var interactpos = $Camera3D/PhysicsRaycast/InteractPos


var isHoldingObject = false;
var heldObject = null;


const SPEED = 1.0;
const JUMP_VELOCITY = 2.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if Input.is_action_just_pressed("action"):
		print("hola")
		
	pass
		
func _physics_process(delta):
	

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		


		

	move_and_slide()
	if Input.is_action_just_pressed("action"):
		interactWithDoor()
 
	maintainInteraction()
 
func interactWithDoor():
 
	if !isHoldingObject:
		raycast.force_raycast_update()
 
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider.is_in_group("door"):
				isHoldingObject = true
				heldObject = collider
 
	elif isHoldingObject:
		isHoldingObject = false
		heldObject = null
 
func maintainInteraction():
	if isHoldingObject and heldObject != null:
		var forceDirection = interactpos.global_transform.origin - heldObject.global_transform.origin
		forceDirection = forceDirection.normalized()
 
		heldObject.apply_central_force(forceDirection * 2)
