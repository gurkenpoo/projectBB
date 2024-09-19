extends Area3D

@onready var ambienceSound : AudioStreamPlayer = $"../AudioStreamPlayer"
@onready var timer : Timer = $"../Timer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body.name == "CharacterBody3D":
		timer.start()
		print(body.name)


func _on_timer_timeout() -> void:
	ambienceSound.play();
	print("reproduciendo sonido...")
	
