extends Button

var is_dragging = false
var drag_preview = null
var game_manager = null

func _ready():
	print("========================================")
	print("MODIFIER UI SCRIPT LOADED!")
	print("Node name: ", name)
	print("Node type: ", get_class())
	print("Parent: ", get_parent().name if get_parent() else "NO PARENT")

	# Get reference to game manager
	game_manager = get_tree().current_scene
	print("Game manager found: ", game_manager)
	print("Game manager name: ", game_manager.name if game_manager else "NULL")

	# Test if button is clickable
	print("Button disabled? ", disabled)
	print("Button visible? ", visible)
	print("Button mouse filter: ", mouse_filter)

	# Connect button signals
	print("Connecting signals...")
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)
	print("Signals connected successfully!")
	print("========================================")

func _on_pressed():
	print("!!! BUTTON PRESSED SIGNAL FIRED !!!")

func _input(event):
	if event is InputEventMouseButton:
		print("Mouse event detected: ", event.button_index, " pressed: ", event.pressed)
		var local_pos = get_global_rect()
		var mouse_pos = get_global_mouse_position()
		print("Button rect: ", local_pos)
		print("Mouse pos: ", mouse_pos)
		if local_pos.has_point(mouse_pos):
			print("MOUSE IS OVER BUTTON!")

func _gui_input(event):
	print("GUI INPUT received: ", event)
	if event is InputEventMouseButton:
		print("Mouse button event in _gui_input!")

func _on_button_down():
	print("!!! BUTTON DOWN SIGNAL FIRED !!!")
	print("Button pressed - starting drag")
	is_dragging = true
	# Create a visual preview
	var preview = ColorRect.new()
	preview.size = Vector2(30, 30)
	preview.color = Color(0.2, 1, 0.5, 0.7)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().root.add_child(preview)
	drag_preview = preview

func _on_button_up():
	print("Button released")
	is_dragging = false
	if drag_preview:
		# Check if we're over a pin
		var mouse_pos = get_viewport().get_mouse_position()
		print("Mouse position: ", mouse_pos)
		var target_pin = find_pin_at_position(mouse_pos)
		if target_pin:
			print("Found pin: ", target_pin.name)
			game_manager.add_modifier_to_pin(target_pin)
		else:
			print("No pin found at position")
		drag_preview.queue_free()
		drag_preview = null

func _process(_delta):
	if is_dragging and drag_preview:
		var mouse_pos = get_viewport().get_mouse_position()
		drag_preview.position = mouse_pos - drag_preview.size / 2
		print("Drag preview at: ", drag_preview.position, " mouse: ", mouse_pos)

func find_pin_at_position(screen_pos: Vector2) -> Node2D:
	if not game_manager:
		print("No game manager!")
		return null

	print("=== SEARCHING FOR PIN ===")
	print("Mouse screen position: ", screen_pos)

	# Check all pins
	var pin_visuals = game_manager.get_node("PinVisuals")
	var camera = get_viewport().get_camera_2d()

	print("Camera: ", camera)
	print("Number of pins: ", pin_visuals.get_child_count())

	for pin in pin_visuals.get_children():
		# Convert pin world position to screen position
		var pin_world_pos = pin.global_position
		var pin_screen_pos = pin.get_global_transform_with_canvas().origin

		var distance = pin_screen_pos.distance_to(screen_pos)
		print("Pin ", pin.name, " world:", pin_world_pos, " screen:", pin_screen_pos, " distance: ", distance)

		if distance < 80:  # Larger radius for easier clicking
			print("*** FOUND PIN: ", pin.name, " ***")
			return pin

	print("No pin found nearby")
	return null
