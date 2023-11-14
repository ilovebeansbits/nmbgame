extends Node2D


var text_displayed = false
var choice_made = false
var result_shown = false
var event_background: Texture
var left_sprite: Texture
var right_sprite: Texture
var event_data: Array
onready var main_menu = get_node("/root/Node2D/CanvasLayer")
var skill_check_passed = false

func _ready():
	show_text("Text")
func reload():
	$Background.texture = null
	$LeftSprite.texture = null
	$RightSprite.texture = null
	
	
func show_event(event_name: String):
	reload()
	show()
	print(event_name)
	var file_path = "res://assets/events/%s.txt" % event_name
	var file = File.new()
	if file.file_exists(file_path):
		print("current event name is ",event_name)
		file.open(file_path, File.READ)
		var json_text = file.get_as_text()
		file.close()
		event_data = parse_json(json_text)["events"]
		load_event(0)
	else:
		print("Event file not found: %s" % file_path)

func load_event(event_index) -> void:
	get_node("../CanvasLayer").hide()
	var current_event = event_data[event_index]
	# Load background if it's mentioned in the JSON
	if current_event.has("event_background"):
		var bg_path = "assets/Events/"+current_event["event_background"]
		print(bg_path)
		var bg_texture = load(bg_path)
		$Background.texture = bg_texture 

	# Load event characters if they are mentioned in the JSON
	if current_event.has("Left"):
		var left_path = "assets/Events/"+current_event["Left"]
		var left_texture = load(left_path)
		$LeftSprite.texture = left_texture 
	
	if current_event.has("Right"):
		var right_path = "assets/Events/"+current_event["Right"]
		print(right_path)
		var right_texture = load(right_path)
		$RightSprite.texture = right_texture 

	# Display the initial text and then proceed through the choices and results
	for x in current_event["texts"]:
		show_text(x)
		yield(get_tree().create_timer(3.0), "timeout")  # Waits for 2 seconds before showing the next piece of text
	var current_position = Vector2(100, 500)
	if current_event.has("choices"):
	# Create buttons for each choice
		for choice in current_event["choices"]:
			var choice_button = Button.new()
			choice_button.add_font_override("font",  load("res://assets/new_dynamicfont.tres"))
			choice_button.text = choice["choiceText"]
			choice_button.rect_min_size = Vector2(700, 40)
			choice_button.rect_position = current_position
			var next = (choice["nextEvent"])
			choice_button.connect("pressed", self, "_on_choice_button_pressed", [next])
			add_child(choice_button)
			current_position.y += 50
			print(choice_button.get_path())
			
	if current_event.has("skillCheck"):
		var buff_text = ""
		var buff = 0
		var skill_check = current_event["skillCheck"]
		if skill_check.has("Modifier"):
			for m in skill_check["Modifier"]:
				buff_text+=m["name"]
				buff+=m["value"]
		var skill_value = main_menu.info[skill_check["requiredSkill"]]#检定的内容
		var skill_difference = - int(skill_check["difficulty"])#目前水平和难度的差别
		var random_roll = randi() % 10 + 1  # Generates a number between 1 and 10
		skill_check_passed = random_roll+skill_difference > skill_difference 
		
		var skill_check_button = Button.new()
		skill_check_button.text = "开始检定"
		add_child(skill_check_button)
		print("检定为",skill_check["requiredSkill"],"值为",skill_value)
		print("难度是",skill_check["difficulty"])
		print("roll 出",random_roll)
		print(skill_check_passed)
		skill_check_button.add_font_override("font",  load("res://assets/new_dynamicfont.tres"))
		skill_check_button.rect_min_size = Vector2(200, 40)
		skill_check_button.connect("pressed", self, "_on_skill_check_button_pressed", [skill_check])
		skill_check_button.rect_position=Vector2(100, 500)
		
func _on_skill_check_button_pressed(skill_check):
	clear_choices()
	if skill_check_passed:
		show_text("检定成功")
		load_event(skill_check["successEvent"])
	else:
		show_text("检定失败")
		load_event(skill_check["failureEvent"])
		
		
func clear_choices() -> void:
	for button in get_children():
		if button is Button:
			button.queue_free()
		
func show_text(text: String) -> void:
	var label = $TextLabel 
	label.text = text


func process_next_event():
	if not text_displayed:
		text_displayed = true
		show_text("choiceText")
	elif not choice_made:
		choice_made = true
		# Here you would add your logic for the player to make a choice
	elif not result_shown:
		result_shown = true
		show_text("resultingText")
		
	
func _on_choice_button_pressed(choice):
	print(choice)
	if typeof(choice) == TYPE_STRING and choice == "End":
		clear_choices()
		hide()
		get_node("../CanvasLayer").show()
	else:
		clear_choices()
		load_event(int(choice))
		

