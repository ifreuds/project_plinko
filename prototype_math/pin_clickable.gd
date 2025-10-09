extends Sprite2D

var game_manager = null

func _ready():
	# Find game manager by traversing up
	var current = get_parent()
	while current:
		if current.name == "GameManagerMath":
			game_manager = current
			break
		current = current.get_parent()

	if not game_manager:
		game_manager = get_tree().current_scene

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var pin_screen_pos = get_global_transform_with_canvas().origin
		var distance = pin_screen_pos.distance_to(mouse_pos)
		if distance < 50:  # Within 50 pixels
			# Remove modifier from this pin
			if game_manager:
				game_manager.remove_modifier_from_pin(self)
				print("Removed modifier from ", name)
