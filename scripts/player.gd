extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var coyoteTimer = $CoyoteTimer

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

var jumping

var isGravityDown = 1

var isPlayerGoingRight = 1

var shootTimer = 0
const SHOOT_COOLDOWN = 0.25

const BULLET_SPEED = 3000
const BULLET_OFFSET = 50

const PUSH_FORCE = 2000

const Bullet = preload("res://scenes/bullet.tscn")
const BulletType = preload("res://scripts/bullet.gd")

var jumped = false

const MAX_VELOCITY = 3000

func _process(delta: float) ->  void:
	print(velocity.y, " ", MAX_VELOCITY)
	
	shootTimer = max(shootTimer - delta, 0)
	
	if Input.is_action_just_pressed("shoot"):
		if shootTimer > 0: # shoot on cooldown
			return
			
		var newBullet = Bullet.instantiate()
		get_parent().add_child(newBullet)
		newBullet.position = Vector2(position.x + BULLET_OFFSET * isPlayerGoingRight, position.y)
		newBullet.apply_impulse(Vector2(BULLET_SPEED * isPlayerGoingRight, 0), Vector2.ZERO)
		
		shootTimer = SHOOT_COOLDOWN
		
		
func canJump() -> bool:
	return ((is_on_floor() or is_on_ceiling()) or not coyoteTimer.is_stopped()) and not jumped


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_on_ceiling():
		velocity += get_gravity() * delta * isGravityDown
		velocity.y = clampf(velocity.y, -MAX_VELOCITY, MAX_VELOCITY)
	else:
		jumped = false

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and canJump():
		jumped = true
		velocity.y = JUMP_VELOCITY * isGravityDown
		
		isGravityDown = isGravityDown * -1
		if isGravityDown == 1:
			sprite.flip_v = false
		else:
			sprite.flip_v = true
		sprite.play("jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		isPlayerGoingRight = direction
		if isPlayerGoingRight == 1:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.play("idle")
		
	if not is_on_ceiling() and not is_on_floor():
		sprite.play("jump")

	var wasOnFloorOrCeilling = is_on_ceiling() or is_on_floor()
	
	move_and_slide()
	
	#start coyote timer
	if wasOnFloorOrCeilling and not is_on_ceiling() and not is_on_floor() and not jumped:
		coyoteTimer.start()

	# Check for collisions after moving
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is BulletType:
			var rigidBody = collision.get_collider()
			var forceDirection = -collision.get_normal()
			var forceMagnitude = PUSH_FORCE
			rigidBody.apply_force(forceDirection * forceMagnitude)
