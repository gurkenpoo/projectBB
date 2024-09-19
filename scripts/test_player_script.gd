extends CharacterBody3D


@onready var camera = $Camera3D
@onready var raycast = $Camera3D/PhysicsRaycast
@onready var interactpos = $Camera3D/PhysicsRaycast/InteractPos


var isHoldingObject : bool = false;
var heldObject = null;


const SPEED = 1.0;
const JUMP_VELOCITY = 2.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = 9.8

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
	# Añadir gravedad.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Manejar salto.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtener dirección de input y manejar movimiento/desaceleración.
	var input_dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_central_impulse(-col.get_normal() * 0.3)
			col.get_collider().apply_impulse(-col.get_normal() * 0.01, col.get_position())

	if Input.is_action_just_pressed("hold"):
		print("agarrar")
		interactWithDoor()
	
	elif Input.is_action_just_released("hold"):
		print("soltar")
		releaseObject()

	maintainInteraction()

func interactWithDoor():
	if !isHoldingObject:
		raycast.force_raycast_update()

		if raycast.is_colliding():
			print(raycast.get_collider())
			var collider = raycast.get_collider()
			if collider.is_in_group("door"):
				isHoldingObject = true
				heldObject = collider

func releaseObject():
	if isHoldingObject:
		isHoldingObject = false
		heldObject = null

func maintainInteraction():
	if isHoldingObject and heldObject != null:
		var forceDirection = interactpos.global_transform.origin - heldObject.global_transform.origin
		forceDirection = forceDirection.normalized()

		heldObject.apply_central_force(forceDirection * 1)
