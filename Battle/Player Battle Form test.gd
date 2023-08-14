extends KinematicBody2D


var Gravity = 20
var Speed = 150
var Motion = Vector2()
var UP = Vector2(0, -1)
var jumpforce = 400
var state_machine

func _physics_process(delta):
	Motion.y += Gravity
	
	state_machine = $AnimationTree.get('parameters/playback')
	
	if Input.is_action_pressed("left"):
		Motion.x = -Speed
		$Sprite.flip_h = true
		state_machine.travel('RunRight')
	elif Input.is_action_pressed("right"):
		Motion.x = Speed
		$Sprite.flip_h = false
		state_machine.travel('RunRight')
	else:
		Motion.x = 0
		state_machine.travel('IdleRight')
		
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			Motion.y = -jumpforce
	else:
		if Motion.y == 0:
			state_machine.travel('JumpRoll')
		elif Motion.y > 0:
			state_machine.travel('fall')
		else:
			state_machine.travel('JumpEnd')
			
	Motion = move_and_slide(Motion,UP)
