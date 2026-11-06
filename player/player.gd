extends CharacterBody3D


@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var camera: Camera3D = $Head/Eyes/Camera3D
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var standup_check: RayCast3D = $StandupCheck
@onready var headbob: Bob = Bob.new()

# Movement variables
const walking_speed: float = 3.0
const sprinting_speed: float = 5.0
const crouching_speed: float = 1.0
var current_speed: float = 3.0
var moving: bool = false

var input_dir: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO

const crouching_depth: float = 0.9
const jump_velocity: float = 4.0
const lerp_speed: float = 10.0

# Player Settings
var mouse_sensitivity: float = 0.2
var base_fov = 90.0


# State Machine
enum PlayerState {
	IDLE_STAND,
	IDLE_CROUCH,
	CROUCHING,
	WALKING,
	SPRINTING,
	AIR
}
var player_state: PlayerState = PlayerState.IDLE_STAND




func _ready() -> void:
	return




func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * mouse_sensitivity)
		head.rotate_x(deg_to_rad(-event.relative.y) * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
				var viewport_size = get_viewport().get_visible_rect().size
				get_viewport().warp_mouse(Vector2(viewport_size.x / 2, viewport_size.y / 2))
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)




func _physics_process(delta: float) -> void:
	
	updatePlayerState()

	updateCamera(delta)

	# falling:
	if not is_on_floor():
		if velocity.y >= 0: # jumping upwards
			velocity += get_gravity() * delta
		else: # falling down
			velocity += get_gravity() * delta * 2.0

	else: # Jumping
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	
	# Movement Logic
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x,0, input_dir.y)).normalized(), delta * 10.0)
	if direction: 
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else: # player not pressing movement
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)




	
	move_and_slide()


func updatePlayerState() -> void:
	moving = (input_dir != Vector2.ZERO)

	if not is_on_floor():
		player_state = PlayerState.AIR

	else:
		if Input.is_action_pressed("crouch"):
			if not moving:
				player_state = PlayerState.IDLE_CROUCH
			else: 
				player_state = PlayerState.CROUCHING

		elif !standup_check.is_colliding():
			if not moving:
				player_state = PlayerState.IDLE_STAND
			elif Input.is_action_pressed("sprint"):
				player_state = PlayerState.SPRINTING
			else: 
				player_state = PlayerState.WALKING

	updatePlayerColShape(player_state)
	updatePlayerSpeed(player_state)




func updatePlayerColShape(_player_state: PlayerState) -> void:
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	else:
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true


func updatePlayerSpeed(_player_state: PlayerState) -> void:
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
		current_speed = crouching_speed

	elif _player_state == PlayerState.WALKING:
		current_speed = walking_speed

	elif _player_state == PlayerState.SPRINTING:
		current_speed = sprinting_speed


func updateCamera(_delta: float) -> void:
	if player_state == PlayerState.AIR:
		pass
	
	if player_state == PlayerState.CROUCHING or player_state == PlayerState.IDLE_CROUCH:
		head.position.y = lerp(head.position.y, 1.8 - crouching_depth, _delta * lerp_speed)
		camera.fov = lerp(camera.fov, base_fov * 0.95, _delta * lerp_speed)
		headbob.setBob(eyes, "crouching")

	elif player_state == PlayerState.IDLE_STAND:
		head.position.y = lerp(head.position.y, 1.8, _delta * lerp_speed)
		camera.fov = lerp(camera.fov, base_fov, _delta * lerp_speed)
		headbob.setBob(eyes, "none") 

	elif player_state == PlayerState.WALKING:
		head.position.y = lerp(head.position.y, 1.8, _delta * lerp_speed)
		camera.fov = lerp(camera.fov, base_fov, _delta * lerp_speed)
		headbob.setBob(eyes, "walking")

	elif player_state == PlayerState.SPRINTING:
		head.position.y = lerp(head.position.y, 1.8, _delta * lerp_speed)
		camera.fov = lerp(camera.fov, base_fov * 1.05, _delta * lerp_speed)
		headbob.setBob(eyes, "sprinting")

	var headbobPosition = headbob.getBobLocation(eyes, _delta, moving, lerp_speed)
	eyes.position.x = headbobPosition.x
	eyes.position.y = headbobPosition.y
