extends CanvasLayer

var book_data = {
	"Book1": {
		"title": "吐纳法",
		"diff":1,
		"unlocked": true,
	},
	"Book2": {
		"title": "邀月手",
		"diff":2,
		"unlocked": true
	},
	"Book3": {
		"title": "轻身法",
		"diff":1,
		"unlocked": true
	},
}
var age = 192
var info = {
	"boney":7,
	"brain":10,
	"luck":5,
	"san":6,
	"fame":0
}
var show_map_menu = false
var show_books = false
var current_location = "无名小镇"
var location_flags = { #决定是否出发初次进城事件
	"洛阳":true,
	"无名小镇":true,
	"长安":true
}
var age_flags = [204]#年龄事件

func _ready():
	# Initially hide the BooksPanel
	$BooksPanel.hide()
	$MapPanel.hide()
	randomize()
	load_local_events()
var events_5_to_8_local = []
var events_9_to_0_local = []
var events_5_to_8_general = ["官兵勒索","酒馆奇谈"]
var events_9_to_0_general = ["负剑少年","夜半敲门"]
var destinations = ["长安","洛阳","濮阳"]
onready var last_read = get_node("BooksPanel/GridContainer/ColorRect/Book1")
onready var event_manager = get_node("../EventManager")
# Function connected to the "pressed" signal of the Study button
func _on_Study_pressed():
	$MapPanel.hide()
	show_books = !show_books
	if show_books:
		$BooksPanel.show()
		for child in $BooksPanel/GridContainer/ColorRect.get_children():
			print(child)  # This will print the object to the output
			var child_name = child.get_name()  # Get the name of the child node
			# Check if the child node's name is in the book_data dictionary and if it is unlocked
			if child_name in book_data and not book_data[child_name]["unlocked"]:
				child.hide()  # If not unlocked, hide the node
	else:
		$BooksPanel.hide()
	
	
func show_current_books():
	$BooksPanel.show()
	
func _on_Book1_pressed():
	var button = get_node("BooksPanel/GridContainer/ColorRect/Book1")
	exercise(button)
	
func _on_Book2_pressed():
	var button = get_node("BooksPanel/GridContainer/ColorRect/Book2")
	exercise(button)
	
func _on_Book3_pressed():
	var button = get_node("BooksPanel/GridContainer/ColorRect/Book3")
	exercise(button)

func update_log(verse):
	$Panel/Gamelog.text+= ("\n")
	$Panel/Gamelog.text+= $Panel/PlayerStatus/Year.text+" 年" + $Panel/PlayerStatus/Month.text +" 月"
	$Panel/Gamelog.text+= verse
	$Panel/Gamelog.cursor_set_line($Panel/Gamelog.get_line_count() - 1)
func _on_Action2_pressed():
	enable_actions(false)
	if last_read.get_node("Status").text == "不可练":
		var grid_container = $BooksPanel/GridContainer
		var eligible_children = []
		for child in grid_container.get_children():
			var status_label = child.get_node("Status")  # Adjust the path to your Status node
			if status_label and status_label.text != "不可练":
				eligible_children.append(child)
			if eligible_children.size() == 0:
				update_log("无功可练")

		if eligible_children.size() > 0:
			var random_index = randi() % eligible_children.size()
			last_read = eligible_children[random_index]
	
	if last_read.get_node("Status").text == "可练习":
		var current_progress = last_read.get_node("ProgressBar").value
		var progress = max(randi()%10 - int(last_read.get_node("Diff").text),0)/2
		var new_progress = current_progress + progress
		if current_progress < 30 and new_progress >= 30:
			last_read.get_node("Status").text = "玄关"
			last_read.get_node("ProgressBar").value = 30
			var gamelog = last_read.get_node("Title").text+"到达武学玄关！"
			update_log(gamelog)
		elif current_progress < 50 and new_progress >= 50:
			last_read.get_node("Status").text = "玄关"
			last_read.get_node("ProgressBar").value = 50	
			var gamelog = last_read.get_node("Title").text+"到达武学玄关！"
			update_log(gamelog)
		elif current_progress < 70 and new_progress >= 70:
			last_read.get_node("Status").text = "不可练"
			last_read.get_node("ProgressBar").value = 70
			var gamelog = last_read.get_node("Title").text +"进度已满70点，无法以常规方法练习"
			update_log(gamelog)
		else:
			last_read.get_node("ProgressBar").value = new_progress
		var gamelog = last_read.get_node("Title").text+"进度增加了"+str(progress)+"点，现为"+str(last_read.get_node("ProgressBar").value)+"点"
		update_log(gamelog)
	elif last_read.get_node("Status").text == "玄关":
		var random = randi()%2
		if random != 1:
			last_read.get_node("Status").text = "可练习"
			update_log(last_read.get_node("Title")+"已突破武学玄关")
		else:
			update_log(last_read.get_node("Title")+"未突破武学玄关")
	
	
func exercise(book: Button):
	update_age()
	
	enable_actions(true)
	if book.get_node("Status").text == "不可练":
		pass;
	elif book.get_node("Status").text == "可练习":
		last_read = book
		var current_progress = book.get_node("ProgressBar").value
		var progress = max(randi()%10 - int(book.get_node("Diff").text),0)
		var new_progress = current_progress + progress
		if current_progress < 30 and new_progress >= 30:
			last_read.get_node("Status").text = "玄关"
			last_read.get_node("ProgressBar").value = 30
			var gamelog = last_read.get_node("Title").text+"到达武学玄关！"
			update_log(gamelog)
		elif current_progress < 50 and new_progress >= 50:
			last_read.get_node("Status").text = "玄关"
			last_read.get_node("ProgressBar").value = 50	
			var gamelog = last_read.get_node("Title").text+"到达武学玄关！"
			update_log(gamelog)
		elif current_progress < 70 and new_progress >= 70:
			last_read.get_node("Status").text = "不可练"
			last_read.get_node("ProgressBar").value = 70
			var gamelog = last_read.get_node("Title").text +"进度已满70点，无法以常规方法练习"
			update_log(gamelog)
		else:
			last_read.get_node("ProgressBar").value = new_progress
		var gamelog = last_read.get_node("Title").text+"进度增加了"+str(progress)+"点，现为"+str(last_read.get_node("ProgressBar").value)+"点"
		update_log(gamelog)
	elif last_read.get_node("Status").text == "玄关":
		var random = randi()%2
		if random != 1:
			last_read.get_node("Status").text = "可练习"
			update_log(last_read.get_node("Title").text+"已突破武学玄关")
		else:
			update_log(last_read.get_node("Title").text+"未突破武学玄关")
	
func update_age():
	age+=1
	var month = age % 12 + 1
	var year = (age - month)/12 + 1
	$Panel/PlayerStatus/Year.text = str(year)
	$Panel/PlayerStatus/Month.text = str(month)
	#触发年龄相关固定事件
	if age in age_flags:
		print(age)
		var age_event = str(age)
		event_manager.show_event(age_event)
	if age == 300:
		update_log("游戏结束界面老是失败所以先用这个好了")
		yield(get_tree().create_timer(5.0), "timeout")
		get_tree().quit()
		

	
func update_fame(fame_delta):
	info["fame"] += fame_delta
	if (-10<info["fame"]<10): $Panel/FameBg/Fame.text = "默默无闻"
	if (10<info["fame"]<50): $Panel/FameBg/Fame.text = "略有耳闻"
	if (50<info["fame"]<100): $Panel/FameBg/Fame.text = "小有名气"
	if (100<info["fame"]<200): $Panel/FameBg/Fame.text = "中等名气"
	
func load_local_events():
	var file = File.new()
	var filename = "res://assets/Events_" + current_location + ".txt"
	if file.open(filename, File.READ) == OK:
		var json_text = file.get_as_text()
		file.close()
		var events = parse_json(json_text)
		if events == null:
			print("Failed to parse JSON. The text might not be in correct JSON format.")
		else:
			categorize_events(events)
	else:
		print("Failed to open file: " + filename)
		
func categorize_events(events):
	for event in events:
		if event["EventType"] == "5~8":
			events_5_to_8_local.append(event["EventName"])
		elif event["EventType"] == "9~0":
			events_9_to_0_local.append(event["EventName"])
			
func remove_event_by_name(event_name, event_catagory):
	if event_catagory.size() > 0:
		for i in range(event_catagory.size()-1,-1,-1):
			if event_catagory[i] == event_name:
				event_catagory.remove(i)
				update_log("完成事件"+event_name)

func enter_location(location):
	current_location = location
	get_node("Panel/Location").text = current_location	
	load_local_events()
	
func on_Action_pressed():
	enable_actions(false)
	update_log("你决定在周围逛逛")
	var dice = randi()%10
	if dice <=4:
		update_log("无事发生")
	elif 4<dice and dice <9:
		if(events_5_to_8_local.size()>=1):
			var index = randi()%(len(events_5_to_8_local))
			var event = events_5_to_8_local[index]
			update_log("进入事件: "+ event)
			event_manager.show_event(event)
			remove_event_by_name(event,events_5_to_8_local)
		else:
			var index = randi()%(len(events_5_to_8_general))
			var event = events_5_to_8_general[index]
			update_log("进入事件: "+ event)
			event_manager.show_event(event)
			remove_event_by_name(event,events_5_to_8_general)			
	elif 8<dice and dice <11:
		if(events_9_to_0_local.size()>=1):
			var index = randi()%(len(events_9_to_0_local))
			var event = events_9_to_0_local[index]
			update_log("进入事件: "+ event)
			event_manager.show_event(event)
			remove_event_by_name(event,events_9_to_0_local)			
		else:
			var index = randi()%(len(events_9_to_0_general))
			var event = events_9_to_0_general[index]
			update_log("进入事件: "+ event)
			event_manager.show_event(event)
			remove_event_by_name(event,events_9_to_0_general)	
		
		
		#if location specific event available: 
	
func generate_attributes():
	pass;
func on_Action3_pressed():
	enable_actions(false)
	show_map_menu = !show_map_menu

	$MapPanel.show()

	for destination in destinations:
		var location_button = Button.new()
		location_button.text = destination
		location_button.connect("pressed", self, "_on_location_button_pressed", [destination])
		location_button.add_font_override("font",  load("res://assets/new_dynamicfont.tres"))
		location_button.rect_min_size = Vector2(100, 40)
		$MapPanel/GridContainer.add_child(location_button)
		
func _on_location_button_pressed(destination):
	update_age()
	$Panel/BgMap.texture = load("res://assets/"+destination+".png")
	if location_flags[destination]:
		location_flags[destination] = false
		event_manager.show_event(destination)
	
		
	
func enable_actions(enabled):
	get_node("Panel/Action").disabled = not enabled
	get_node("Panel/Action2").disabled = not enabled
	get_node("Panel/Action3").disabled = not enabled
