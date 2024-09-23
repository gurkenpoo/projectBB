extends CharacterBody3D


@onready var camera = $Camera3D
@onready var raycast = $Camera3D/PhysicsRaycast
@onready var interactpos = $Camera3D/PhysicsRaycast/InteractPos
@onready var bloodyCursor : Sprite2D = $Camera3D/Sprite2D/BloodCursor
@onready var head : Node3D = $".."

var isHoldingObject : bool = false;
var heldObject = null;


const SPEED = 5.0;
const JUMP_VELOCITY = 2.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = 9.8

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	bloodyCursor.hide()
	camera.current = true
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	#if Input.is_action_just_pressed("action"):
	#	print("hola")
		
	if Input.is_action_pressed("ui_cancel"):
		print("Saliendo...")
		get_tree().quit()
		
	pass
		
func _physics_process(delta) -> void:
	# Añadir gravedad.
	showCursor()
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Manejar salto.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtener dirección de input y manejar movimiento/desaceleración.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 4.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 4.0)

	move_and_slide()
	
	#for col_idx in get_slide_collision_count():
	#	var col := get_slide_collision(col_idx)
	#	if col.get_collider() is RigidBody3D:
	#		col.get_collider().apply_central_impulse(-col.get_normal() * 0.3)
	#		col.get_collider().apply_impulse(-col.get_normal() * 0.01, col.get_position())
	
	if Input.is_action_just_pressed("interact"):
		print("agarrar")
		interactWithDoor()
	
	elif Input.is_action_just_released("interact"):
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
				collider.emit_signal("play_bolt_sound")

func releaseObject():
	if isHoldingObject:
		isHoldingObject = false
		heldObject = null

func maintainInteraction():
	if isHoldingObject and heldObject != null:
		var forceDirection = interactpos.global_transform.origin - heldObject.global_transform.origin
		forceDirection = forceDirection.normalized()

		heldObject.apply_central_force(forceDirection * 10)
		
func showCursor():
	bloodyCursor.hide()
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("door"):
			bloodyCursor.show()
		
	
	
