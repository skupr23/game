extends Node2D

@export var picture: Texture2D

var good = true
signal clicked(num: int)
var id = 0

func _ready() -> void:
	$Sprite2D.texture = picture

func _process(delta: float) -> void:
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		clicked.emit(id)
