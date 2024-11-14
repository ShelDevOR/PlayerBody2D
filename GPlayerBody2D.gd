@icon("res://addons/PlayerBody2D/ico.png")
class_name PlayerBody2D
extends CharacterBody2D
@export_group("Animation")
@export var Animate:bool
@export var AnimName:Dictionary = {Idle = "", Walk = "", Run = "", Jump = ""}
@export var PlayerAnimatedSprite:AnimatedSprite2D
# --- SPRITES ---
@export var Sprites: Array[Sprite2D]

# --- ERROR & DEBUG OPTIONS ---
@export_group("Error & Debug Options")
## Get errors Info, Keep on is recommended
@export var ErrorInfo: bool
## Auto-assign values if null
@export var AutoValue: bool

# --- CHARACTER MOVEMENT ---
@export_group("Character Movement")
## If true, the player will not move; if false, the player will move
@export var CanMove: bool
## Defines if Player can Jump
@export var CanJump: bool
## Apply gravity so the player can fall
@export var ApplyGravity: bool
## Defines if the Player can Flip
@export var CanFlip: bool

# --- MOVEMENT SPEEDS ---
@export_group("Movement Speeds")
## Run speed
@export var RunSpeed: float
## Jump limit
@export var JumpLimit: float
## Gravity force
@export var Gforce: float
## Walk speed
@export var WalkSpeed: float
## Set the Player speed (not exported)
var Speed: float

# --- CHARACTER TYPE ---
@export_group("Character Type")
@export_enum("2D Default", "TopDown") var CharacterType

# --- RUN SETTINGS ---
@export_group("Run Settings")
## Defines if the Player can run
@export var CanRun: bool
## Assign your run button type
@export_enum("Pressed", "Just pressed") var ButtonType

# --- INPUT MAPPING ---
@export_group("Input Mapping")
@export var InputKey: Dictionary = {
	Left = "",
	Right = "",
	Up = "",
	Down = "",
	Jump = "",
	RunButton = ""
}

# --- STATE VARIABLES ---
var running = false


# --- READY FUNCTION ---
func _ready() -> void:
	Speed = WalkSpeed
	if ErrorInfo:
		show_alerts()

# --- PROCESS FUNCTION ---
func _process(delta: float) -> void:
	if CanMove:
		if CharacterType == 1:
			handle_top_down_movement()
		elif CharacterType == 0:
			handle_default_movement()
		else:
			if AutoValue:
				assign_default_values()
		move_and_slide()

	if CanRun:
		handle_running()

	if CanFlip:
		handle_flip()

	if CanJump and CharacterType == 0:
		handle_jump()

	if ApplyGravity and CharacterType == 0:
		apply_gravity(delta)
	if Animate:
		animate()

# --- MOVEMENT HANDLERS ---
func handle_top_down_movement():
	velocity = Input.get_vector(
		InputKey.Left, 
		InputKey.Right, 
		InputKey.Up, 
		InputKey.Down) * Speed

func handle_default_movement():
	velocity.x = Input.get_axis(InputKey.Left, InputKey.Right) * Speed

# --- ALERTS HANDLING ---
func show_alerts():
	if CharacterType == null:
		show_alert("Eng: You did not choose a character type")
	if Speed == 0:
		show_alert("Eng: You did not assign a value to the Speed")
	if Gforce == 0:
		show_alert("Eng: You did not assign a value for Gravity Force(Gforce)")

func show_alert(Alert: String):
	OS.alert(Alert)

# --- DEFAULT VALUE ASSIGNMENT ---
func assign_default_values():
	if CharacterType == null:
		CharacterType = 0
	if WalkSpeed == 0:
		WalkSpeed = 100
	if RunSpeed == 0:
		RunSpeed = 300
	if JumpLimit == 0:
		JumpLimit = 500
	if Gforce == 0:
		Gforce = 2

# --- RUN HANDLER ---
func handle_running():
	if ButtonType == 0:
		if Input.is_action_pressed(InputKey.RunButton):
			Speed = RunSpeed
		else:
			Speed = WalkSpeed
	elif ButtonType == 1:
		if Input.is_action_just_pressed(InputKey.RunButton):
			running = !running
			print(running)
		if running:
			Speed = RunSpeed
		else:
			Speed = WalkSpeed

# --- FLIP HANDLER ---
func handle_flip():
	if Sprites.size() == 0:
		return
	for sprite in Sprites:
		if velocity.x < 0:
			sprite.flip_h = true
		elif velocity.x > 0:
			sprite.flip_h = false

# --- JUMP HANDLER ---
func handle_jump():
	if is_on_floor() and Input.is_action_just_pressed(InputKey.Jump):
		velocity.y -= JumpLimit

# --- GRAVITY HANDLER ---
func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * Gforce * delta

func animate():
	if velocity == Vector2.ZERO:
		PlayerAnimatedSprite.play(AnimName.Idle)
	elif velocity.y != 0 and CharacterType == 0:
		PlayerAnimatedSprite.play(AnimName.Jump)
	else:
		PlayerAnimatedSprite.play(AnimName.Run if running else AnimName.Walk)
