extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

var isGravityDown = 1

var isPlayerGoingRight = 1

var shootTimer = 0
const SHOOT_COOLDOWN = 0.25

const BULLET_SPEED = 3000
const BULLET_OFFSET = 100

const PUSH_FORCE = 2000

const Bullet = preload("res://scenes/bullet.tscn")
const BulletType = preload("res://scripts/bullet.gd")

func _process(delta: float) ->  void:
	shootTimer -= delta
	
	if Input.is_action_just_pressed("shoot"):
		if shootTimer > 0: # shoot on cooldown
			return
			
		var newBullet = Bullet.instantiate()
		get_parent().add_child(newBullet)
		newBullet.position = Vector2(position.x + BULLET_OFFSET * isPlayerGoingRight, position.y)
		newBullet.apply_impulse(Vector2(BULLET_SPEED * isPlayerGoingRight, 0), Vector2.ZERO)
		
		shootTimer = SHOOT_COOLDOWN
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_on_ceiling():
		velocity += get_gravity() * delta * isGravityDown

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or is_on_ceiling()):
		velocity.y = JUMP_VELOCITY * isGravityDown
		isGravityDown = isGravityDown * -1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		isPlayerGoingRight = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Check for collisions after moving
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is BulletType:
			var rigidBody = collision.get_collider()
			var forceDirection = -collision.get_normal()
			var forceMagnitude = PUSH_FORCE
			rigidBody.apply_force(forceDirection * forceMagnitude)
