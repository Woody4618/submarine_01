extends Node2D

@export var head: Sprite2D;
@export var animation: AnimationPlayer;

# Declare variables
var speed = 100  # Speed of movement in pixels per second
var direction = Vector2(1, 0)  # Direction of movement (1, 0) is to the right

func _ready():
	# Any setup can be done here, like setting the initial position
	animation.play("Idle");
	pass

func _process(delta):
	# Update the sprite's position based on speed and direction
	global_position += direction * speed * delta
