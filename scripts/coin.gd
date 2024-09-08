extends Area2D


@onready var games_manager = %GameManager
@onready var animation_player = $AnimationPlayer
@onready var solana_manager: Node2D = %SolanaManager

func _on_body_entered(body):
	print("coin collected")
	games_manager.add_point()
	animation_player.play("collect")
	solana_manager.collect_coin();
	
