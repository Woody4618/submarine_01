extends Node2D

var score = 0
@onready var score_label = $ScoreLabel

func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + "/17 coins!" 
	print("point added ")
	

func _on_button_2_pressed() -> void:
	print("mint button pressed")
