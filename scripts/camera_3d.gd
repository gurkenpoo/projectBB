class_name Camera
extends Camera3D
@export var stopwatch_label : Label

@export var  stopwatch : Stopwatch


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateStopwatch_Label()
	

func updateStopwatch_Label():
	stopwatch_label.text = stopwatch.time_to_string();
