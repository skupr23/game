extends Node2D

var evils = 3
var choosable = 3
var nodes: Array[Node] = []
var chosen: Array[Node] = []
# Called when the node enters the scene tree for the first time.
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
		i+= 1
		var good = randi_range(0, 1)
		if good == 0 and evils != 0:
			node.good = false
			print(i)
			evils -= 1
	if evils > 0:
		for node in nodes:
			if evils == 0:
				return
			if node.good:
				continue
			print(node.id)
			node.good = false
			evils-=1


func choose(id: int):
	if choosable == 0:
		return
	var node = nodes[id]
	if node in chosen:
		chosen.erase(node)
		node.modulate = Color.WHITE
		choosable += 1
		return
	node.modulate = Color.GREEN
	choosable-=1
	chosen.append(nodes[id])
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	if choosable != 0:
		return
	var bads = 0
	for node in chosen:
		node.modulate = Color.WHITE
		if node.good == false:
			bads += 1
	
	if bads > 0:
		print("lost")
	else:
		print("won")
	chosen = []
	
	choosable = 3
