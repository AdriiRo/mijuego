extends CharacterBody2D

@export var gravity_scale = 2
@export var speed = 300
@export var acceleration = 400
@export var friction = 1500
@export var jump_force = -700
@export var air_acceleration = 2000
@export var air_friction = 700
@onready var ani_player = $ani_player


func apply_gravity(delta):
	if not is_on_floor():
		velocity+=get_gravity() * delta * gravity_scale

func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed*input_axis, acceleration*delta)

func apply_friction(input_axis, delta):
	if input_axis==0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction*delta)

func handle_jump():
	if is_on_floor():
		if Input.is_action_pressed("saltar"):
			velocity.y = jump_force
		
func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed*input_axis, air_acceleration *delta)


func update_animation(input_axis):
	if input_axis !=0:
		# velocidad de la animación será dependiente de la velocidad
		ani_player.speed_scale = velocity.length()/100
		ani_player.flip_h = (input_axis<0)
		ani_player.play("run")
	elif not is_on_floor():
		ani_player.play("jump")
	else:
		ani_player.speed_scale=1
		ani_player.play("idle")

func _physics_process(delta: float) -> void:
	var input_axis = Input.get_axis("mover_izquierda","mover_derecha")
	apply_gravity(delta)
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	handle_jump()
	handle_air_acceleration(input_axis, delta)
	update_animation(input_axis)
	move_and_slide()

# Referencia al contador
@onready var contador: Control = $CanvasLayer/Contador

# Contador de monedas
var monedas: int = 0

# Agregamos al player al grupo de jugadores
func _ready() -> void:
	add_to_group("jugadores")
	contador.actualizar(0)
	
# Agrega una moneda al contador del jugador
func add_moneda():
	monedas+=1
	contador.actualizar(monedas)
	
func morir():
		# desactivo las físicas
	set_physics_process(false)
	ani_player.play("muerte")
	$audio_player.play()
	$tiempo.start()
	await $tiempo.timeout
	get_tree().reload_current_scene()
