extends CharacterBody3D

@onready var agent : NavigationAgent3D = $agent
@onready var target : CharacterBody3D = $"/root/L_Main/Player"
@onready var ap = $Alien3/AnimationPlayer
@onready var Ray : RayCast3D = $E_RayCast3d
@onready var E_View = $E_View


enum {
	Run,
	Walk,
	Punch,
	Idle,
	Dead,
	Dead001,
	Alert1,
	Alert2,
	Alert3,
	Hit1,
	Hit2,
	Punch2,
	Punch3,
	Dead2,
	Dead3,
	Look
}
var state = Idle
const distance = 3
var E_lookdistance = 10
@export var speed = 6
@export var health = 100
var look_vel = 100

@export var gravity_multiplier := 3.0
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity")* gravity_multiplier)

#Manages look player
#func _physics_process(delta):
#	var current_location = global_transform.origin*delta
#	var next_location = agent.get_next_location()*delta
#	var new_velocity = (next_location - current_location).normalized() * speed * delta
#	agent.set_velocity(new_velocity+velocity)
#	#look_at_player(velocity)
	
# Manages stats & deltas
func _process(delta):
	var current_location = global_transform.origin*delta
	var next_location = agent.get_next_location()*delta
	var new_velocity = (next_location - current_location ).normalized() * speed * delta
	agent.set_velocity(new_velocity)
	$DeadTimer.wait_time= 1

	
	
#	look_at_player(new_velocity)

	if Ray.is_colliding() and transform.origin.distance_to(target.transform.origin) > distance:
		state = Run


	if health * delta <= 0 :
		$DeadTimer.start()
		#queue_free()w

	match state:
		Look:
			look_at_player(new_velocity)
		Idle:
			ap.play("Idle1")
		Walk:
			ap.play("Walk")
		Run:
			if health * delta >= 0 :
				ap.play("Run")
				move_and_collide(velocity)
				look_at_player(new_velocity+velocity)
		Punch:
			if health * delta >= 0 :
				ap.play("Punch")
				look_at_player(new_velocity)
			
			
		Dead:
			ap.play("Dead")
			
		Dead001:
			ap.play("Dead001")
		Alert1:
			ap.play("Alert1")
		Alert2:
			ap.play("Alert2")
		Alert3:
			ap.play("Alert3")
		Hit1:
			ap.play("Hit1")
		Hit2:
			ap.play("Hit2")
		Dead2:
			ap.play("Dead2")
		Dead3:
			ap.play("Dead3")
			


# Manages target loc
func update_target_location(target_location):
	agent.set_target_location(target_location)

# look func
func look_at_player(target_location):
	if target_location != null and target_location != global_transform.origin:
		look_at((target_location*-1).normalized() * look_vel, Vector3.UP)
	
#checked reached player actions
func _on_agent_target_reached():
	state = Punch
	print("attack")
	
#Velocity compute
func _on_agent_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .01)

func _on_e_view_body_entered(body):
	state = Look
	if body.is_in_group("Player") and transform.origin.distance_to(target.transform.origin) > distance:
		state = Run

		print("look")
	else:
		state = Idle


func _on_e_view_body_exited(body):
	if body.is_in_group("Player"):
		state = Idle
		print("notlook")


func _on_dead_timer_timeout():
	var deads=[Dead,
		Dead001,
		Dead2,
		Dead3]
	var random_index = randi()%deads.size()
	var random_dead = deads[random_index]
	state = random_dead
	print("dead")
	#queue_free()
