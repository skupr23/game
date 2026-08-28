extends Node2D
# Cards required to send, indexed by round (round 1 = index 0)
var round_requirements = [2, 3, 3, 4, 4]
var current_round = 0          # index into round_requirements
var choosable = 0              # how many more can be picked this round
var evils = 3                  # number of evil cards total, fixed for the whole game
var mission_wins = 0
var mission_fails = 0
var nodes: Array[Node] = []
var chosen: Array[Node] = []
var game_over = false
var door_pos = Vector2(0,0)
@onready var chosen_label: Label = $CanvasLayer/ChosenLabel
@onready var result_label: Label = $CanvasLayer/ResultLabel
@onready var wins_label: Label = $CanvasLayer/WinsLabel
@onready var fails_label: Label = $CanvasLayer/FailsLabel
@onready var round_label: Label = $CanvasLayer/RoundLabel

func _ready() -> void:
	nodes.append($Agent)
	nodes.append($Agent2)
	nodes.append($Agent3)
	nodes.append($Agent4)
	nodes.append($Agent5)
	nodes.append($Agent6)
	nodes.append($Agent7)
 
	var i = 0
	for node in nodes:
		node.clicked.connect(choose)
		node.id = i
		i += 1
		node.good = true
	door_pos = $Door.position
	# Assign good/evil ONCE for the whole game
	var remaining_evils = evils
	while remaining_evils > 0:
		var pick = nodes[randi_range(0, nodes.size() - 1)]
		if pick.good:
			pick.good = false
			remaining_evils -= 1
			print(pick.id)
	chosen_label.visible = false
 

var move = false
var active = true
var move_back = false
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and active:
		move = true
		active = false
		start_round()
	if move:
		$Door.position.y -= 500 *delta
		if $Door.position.y < -1000:
			move = false
	if move_back:
		$Door.position.y += 500 *delta
		if $Door.position.y > door_pos.y:
			$Door.position.y = door_pos.y
			move_back = false
			active = true

func start_round() -> void:
	if shooting_phase:
		return
	chosen_label.visible = true
	choosable = round_requirements[current_round]
	chosen = []
	# reset visuals only — good/evil identities stay fixed
	for node in nodes:
		node.modulate = Color("afafaf")
 
	update_labels()
	result_label.text = "Round %d - send %d cards" % [current_round + 1, choosable]
	result_label.modulate = Color.WHITE
 
func choose(id: int) -> void:
	if game_over:
		return
	if shooting_phase:
		shoot(id)
		return
	var node = nodes[id]
	if node in chosen:
		chosen.erase(node)
		node.modulate = Color("afafaf")
		choosable += 1
	else:
		if choosable == 0:
			return
		node.modulate = Color.WHITE
		choosable -= 1
		chosen.append(node)
	update_labels()
 
func _on_button_pressed() -> void:
	if game_over or choosable != 0:
		return
	var bads = 0
	for node in chosen:
		if node.good == false:
			bads += 1
	if bads > 0:
		mission_fails += 1
		result_label.text = "Mission Failed!"
		result_label.modulate = Color.RED
	else:
		mission_wins += 1
		result_label.text = "Mission Success!"
		result_label.modulate = Color.GREEN
	update_labels()
	if mission_fails == 3:
		end_game()
		return
	current_round += 1
	if current_round == 5:
		choose_bad_guys()
		return
	await get_tree().create_timer(1.2).timeout
	start_round()
 
func end_game() -> void:
	game_over = true
	for node in nodes:
		node.modulate = Color.WHITE
	
	result_label.text = "YOU LOSE THE GAME!"
	result_label.modulate = Color.RED
	await get_tree().create_timer(1.2).timeout
	get_tree().reload_current_scene()
 
func update_labels() -> void:
	chosen_label.text = "Chosen: %d/%d" % [round_requirements[current_round] - choosable, round_requirements[current_round]]
	wins_label.text = "Successes  %d" % mission_wins
	fails_label.text = "| %d Fails" % mission_fails
	round_label.text = "Round: %d/5" % [current_round + 1]
 

var shooting_phase = false
func choose_bad_guys():
	for node in nodes:
		node.modulate = Color("afafaf")
	close_game()
	chosen = []
	chosen_label.text = "Shoot the Bad Guys"
	wins_label.text = "Shoot the Bad Guys" 
	fails_label.text = "Shoot the Bad Guys" 
	round_label.text = "Shoot the Bad Guys" 
	$Button.queue_free()
	shooting_phase = true

func shoot(id: int):
	var node = nodes[id]
	if node in chosen:
		pass
	else:
		mission_wins += 1
		node.modulate = Color.RED
	
	if node.good == false:
		evils -= 1
		result_label.text = "It Was A Bad Guy! %d remaining" % evils 
	else:
		result_label.text = "You Killed a Good Guy! Game Over!"
		game_over = true 
		await get_tree().create_timer(1.2).timeout
		get_tree().reload_current_scene()
	
	if evils == 0:
		await get_tree().create_timer(1.2).timeout
		get_tree().reload_current_scene()

func close_game():
	move_back = true
	
