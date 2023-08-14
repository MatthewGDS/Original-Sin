class_name MyHitBox
extends Area2D

export var damage := 5


func _init() -> void:
	collision_layer = 4
	collision_mask = 0
