extends KinematicBody2D

const bulletPath = preload("res://bullets.tscn")

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

const UP = Vector2(0,-1)
const GRAVITY = 20
const MAXFALLSPEED = 360
const MAXSPEED = 80
const JUMPFORCE = 400
const ACCEL = 200

var speed = 500

var normalspeed = 200
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var motion = Vector2()
var facing_right = true
var jump_max = 2
var jump_count = 0

var resistance = 0.7
var friction = 0.5

#Dash
var dashDirection = Vector2(1, 0)
var canDash = false
var dashing = false

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	
# warning-ignore:unused_argument
func _physics_process(delta):
	motion.y += GRAVITY
	
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
		
	if facing_right == true:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1
		
	motion.x = clamp(motion.x,-MAXSPEED,MAXSPEED)
		
	if Input.is_action_pressed("right"):
		motion.x += ACCEL
		facing_right = true
		$AnimationPlayer.play("RunRight")
	elif Input.is_action_pressed("left"):
		motion.x -= ACCEL
		facing_right = false
		$AnimationPlayer.play("RunRight")
	else:
		motion.x = lerp(motion.x,0,0.2)
		$AnimationPlayer.play("IdleUp")
		
	#resetting jump_count
	if is_on_floor() and jump_count!=0:
		jump_count = 0	
		
	if jump_count<jump_max:
		if Input.is_action_just_pressed("jump"):
			motion.y = -JUMPFORCE
			jump_count += 1
			$AnimationPlayer.play("JumpRoll")
	else:
			animationPlayer.play("fall")
			velocity.y = lerp(velocity.x, 0, resistance)
		
	if Input.is_action_just_pressed("attack"):
		attack_player()
		
	motion = move_and_slide(motion,UP)
	
func attack_player():
	$AnimationPlayer.play("AttackRight")
		
func _process(delta):
	if Input.is_action_just_pressed("fire"):
		shoot()
		
	$Node2D.look_at(get_global_mouse_position())


func shoot():
	var bullet = bulletPath.instance()
	
	get_parent().add_child(bullet)
	bullet.position = $Node2D/Position2D.global_position
	
	bullet.velocity = get_global_mouse_position() - bullet.position

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSounds = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSounds)
	
func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

