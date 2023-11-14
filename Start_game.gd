extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var EventManager = get_node("/root/Node2D/EventManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Start_pressed():
	#TextureRect.hide()
	get_node("../StartGame").hide()
	EventManager.show_event("start")
	
	

func _on_End_pressed():
	get_tree().quit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
