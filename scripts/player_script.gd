extends CharacterBody3D

@onready var head : Node3D = $head
@onready var camera : Camera = $head/Camera3D
@onready var raycast : RayCast3D = $head/Camera3D/RayCast3D
@onready var marker : Marker3D = $head/Camera3D/Marker3D
@onready var bloodyCursor : Sprite2D = $head/Camera3D/BloodyCursor

@export_category("Head Bob")
@export var BOB_FREQ : int = 2
@export var BOB_AMP : float = 0.08
@export var t_bob : float= 0

var speed
const WALK_SPEED : float = 2.0
const SPRINT_SPEED  : float = 8.0
const JUMP_VELOCITY : float = 2.5
const SENSITIVITY : float = 0.0027


#FOV variable
const BASE_FOV = 65.0
const FOV_CHANGE = 1.5

#Drag door
var isHoldingObject = false
var heldObject = null


func _ready() -> void:
	bloodyCursor.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40),deg_to_rad(60))
	if Input.is_action_pressed("ui_cancel"):
		print("Saliendo...")
		get_tree().quit()
		
func _physics_process(delta: float) -> void:
	showCursor()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	#Handle sprint.
	if Input.is_action_pressed("sprint"):
		if not is_on_floor():
			speed = WALK_SPEED
		else:
			speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
	
	#head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("interact"):
		print("agarrar")
		interectWithDoor()
		
	elif Input.is_action_just_released("interact"):
		print("soltar")
		releaseObject()
		
	maintainInteraction()
	
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_central_impulse(-col.get_normal() * 0.3)
			col.get_collider().apply_impulse(-col.get_normal() * 0.01, col.get_position())
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos
	
func interectWithDoor():
	if !isHoldingObject:
		raycast.force_raycast_update()
		
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider.is_in_group("door"):
				isHoldingObject = true
				heldObject = collider
				collider.emit_signal("play_bolt_sound")
	elif isHoldingObject:
		isHoldingObject = false
		heldObject = null
				
func releaseObject():
	if isHoldingObject:
		isHoldingObject = false
		heldObject = null
func maintainInteraction():
	if isHoldingObject and heldObject != null:
		var forceDirection = marker.global_transform.origin - heldObject.global_transform.origin
		forceDirection = forceDirection.normalized()
		
		heldObject.apply_central_force(forceDirection * 9)
				
				
			
func showCursor():
	bloodyCursor.hide()
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("door"):
			bloodyCursor.show()
