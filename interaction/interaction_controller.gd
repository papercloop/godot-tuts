extends Node

@onready var interaction_controller: Node = %InteractionController
@onready var interaction_raycast: RayCast3D = %InteractionRaycast
@onready var player_camera: Camera3D = %Camera3D
@onready var player_hand: Marker3D = %Hand
@onready var default_reticle: TextureRect = %DefaultReticle
@onready var highlight_reticle: TextureRect = %HighlightReticle
@onready var interacting_reticle: TextureRect = %InteractingReticle
@onready var interactable_check: Area3D = %InteractableCheck

@onready var outline_material: Material = preload("res://materials/highlight.tres")

var current_object: Object # we are already interacting with this.

var last_potential_object: Object # last thing we could possibly have been interacting with

var interaction_component: Node

func _ready() -> void:
	interactable_check.body_entered.connect(_on_body_entered)
	interactable_check.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:

	if interaction_component and interaction_component.is_interacting:
		default_reticle.visible = false
		highlight_reticle.visible = false
		interacting_reticle.visible = true

	# if on previous frame we were interacting with an object, we want to keep interacting with it.
	if current_object: 
		if  player_camera.global_transform.origin.distance_to(current_object.global_transform.origin) > 3.0:
			if interaction_component:
				interaction_component.postInteract()
			current_object = null
			_unfocus()

		if interaction_component:
			if Input.is_action_just_pressed("secondary"):
				interaction_component.auxInteract()
				current_object = null
				_unfocus()
			elif Input.is_action_pressed("primary"):
				interaction_component.interact()
			else:
				interaction_component.postInteract()
				current_object = null
				_unfocus()

	# if on previous frame we were not interacting with an object, let's see if we can.
	else:
		var potential_object: Object = interaction_raycast.get_collider()

		if potential_object and potential_object is Node:
			interaction_component = potential_object.get_node_or_null("InteractionComponent")
			if !interaction_component: 
				_unfocus()
			else:
				if !interaction_component.can_interact:
					return

				last_potential_object = current_object
				_focus()

				if Input.is_action_just_pressed("primary"):
					current_object = potential_object
					interaction_component.preInteract(player_hand, player_camera)

					if interaction_component.interaction_type == interaction_component.InteractionType.ITEM:
						interaction_component.connect("item_collected", Callable(self, "_on_item_collected"))
					
					# This kind of feels like it should live in the interaction_component? Like interaction_controller shouldn't care what type of object it's interacting with?
					if interaction_component.interaction_type == interaction_component.InteractionType.DOOR:
						interaction_component.set_direction(current_object.to_local(interaction_raycast.get_collision_point()))
		else:
			_unfocus()
						

func is_camera_locked() -> bool:
	if interaction_component:
		if interaction_component.lock_camera and interaction_component.is_interacting:
			return true
	return false

func _focus() -> void:
	default_reticle.visible = false
	highlight_reticle.visible = true
	interacting_reticle.visible = false

func _unfocus() -> void:
	default_reticle.visible = true
	highlight_reticle.visible = false
	interacting_reticle.visible = false

func _on_item_collected(item: Node):
	# Inventory system
	prints("Player collected:", item)

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		var name = body.name
		var ic = body.get_node_or_null("InteractionComponent")

		if ic and ic.interaction_type == ic.InteractionType.ITEM:
			print("body entered")
			var mesh: MeshInstance3D = body.find_child("MeshInstance3D", true, false)
			mesh.material_overlay = outline_material

func _on_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		var ic = body.get_node_or_null("InteractionComponent")

		if ic and ic.interaction_type == ic.InteractionType.ITEM:
			print("body exited")
			var mesh: MeshInstance3D = body.find_child("MeshInstance3D", true, false)
			mesh.material_overlay = null
		return
	
























		
