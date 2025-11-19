extends RigidBody2D

const TIME_TO_LIVE = 100
var timeAlive = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timeAlive += delta
	
	if timeAlive >= TIME_TO_LIVE:
		queue_free()
