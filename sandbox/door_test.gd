extends Node3D

var open : bool = false;
var interactable : bool = true
@export var animationDoorTest : AnimationPlayer;
# Called when the node enters the scene tree for the first time.

func interaction():
	print("interaction")
	if interactable == true:
		interactable = false
		open = !open
		if open == false:
			animationDoorTest.play("closeDoor")
		if open == true:
			animationDoorTest.play("openDoor")
		await get_tree().create_timer(1.0, false).timeout
		interactable = true;
	
	
