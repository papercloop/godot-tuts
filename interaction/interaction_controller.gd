extends Node

@onready var interaction_controller: Node = %InteractionController
@onready var interaction_raycast: RayCast3D = %InteractionRaycast
@onready var player_camera: Camera3D = %Camera3D
@onready var player_hand: Marker3D = %Hand

var current_object: Object # we are already interacting with this.

var last_potential_object: Object # last thing we could possibly have been interacting with

var interaction_component: Node

func _process(delta: float) -> void:

	# if on previous frame we were interacting with an object, we want to keep interacting with it.
	if current_object: 
		if interaction_component:
			if Input.is_action_just_pressed("secondary"):
				interaction_component.auxInteract()
				current_object = null
			elif Input.is_action_pressed("primary"):
				interaction_component.interact()
			else:
				interaction_component.postInteract()
				current_object = null

	# if on previous frame we were not interacting with an object, let's see if we can.
	else:
		var potential_object: Object = interaction_raycast.get_collider()

		if potential_object and potential_object is Node:
			interaction_component = potential_object.get_node_or_null("InteractionComponent")
			if interaction_component: 
				if !interaction_component.can_interact:
					return

				last_potential_object = current_object

				if Input.is_action_pressed("primary"):
					current_object = potential_object
					interaction_component.preInteract(player_hand)
					
					if interaction_component.interaction_type == interaction_component.InteractionType.DOOR:
						prints("set_direction should be firing")
						interaction_component.set_direction(current_object.to_local(interaction_raycast.get_collision_point()))
						

func is_camera_locked() -> bool:
	if interaction_component:
		if interaction_component.lock_camera and interaction_component.is_interacting:
			return true
	return false





