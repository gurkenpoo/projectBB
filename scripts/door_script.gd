extends RigidBody3D

@onready var boltLock : AudioStreamPlayer3D = $BoltLock;
signal play_bolt_sound;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_bolt_sound.connect(_on_play_bolt_lock_sound)
	input_ray_pickable = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	


func _on_play_bolt_lock_sound():
	if boltLock:
		boltLock.play()
