extends Node2D

@export var tile_scene : PackedScene
@export var number_of_rows : int = 0
@export var number_of_columns : int = 0

@onready var label_game_finish: Label = %Label_game_finish
@onready var label_timer: Label = %label_timer
@onready var restart_button: Button = $HBoxContainer/Restart_Button
@onready var start_time = Time.get_unix_time_from_system()

var number_of_tiles : int = 1
var x_multiplier : int = 1
var current_time : float = 0
var is_time_paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#connect to signals
	restart_button.pressed.connect(on_button_pressed)
	
	#instanciate tiles based on number of rows and columns
	for i in range(number_of_rows):
		for j in range(number_of_columns):
			var tile_instance = tile_scene.instantiate() as Area2D
			add_child(tile_instance)
			tile_instance.name = "tile_" + str(number_of_tiles)
			
			#tiles are 40px in height and width
			var x = 40 + j * 42 
			var y = 40 + 42 * i 
			tile_instance.global_position = Vector2(x, y)

func _process(delta: float) -> void:
	if !is_time_paused:
		show_time_since_start()

func stop_current_game():
	if is_unmarked_mines_left():
		show_gameover_label()
	else:
		show_victory_label()
	
	is_time_paused = true
	show_mines()

func show_gameover_label():
	label_game_finish.text = "Game Over!"
	label_game_finish.label_settings.font_color = Color(1, 0, 0, 1)
	label_game_finish.visible = true

func show_victory_label():
	label_game_finish.text = "You won!"
	label_game_finish.label_settings.font_color = Color(0, 1, 0, 1)
	label_game_finish.visible = true

func show_mines():
	#create aray of tiles
	var tiles = get_tree().get_nodes_in_group("group_tiles")
	for tile in tiles:
		if tile.get_mine():
			tile.polygon_2d.color = Color(1, 0, 0, 1)
			tile.polygon_base_color = tile.polygon_2d.color

func show_time_since_start():
	current_time = Time.get_unix_time_from_system()
	label_timer.text = str(floor(current_time - start_time))

func is_unmarked_mines_left() -> bool:
	var tiles = get_tree().get_nodes_in_group("group_tiles")
	for tile in tiles:
		if tile.get_mine() and !tile.is_area_marked:
			return true
	return false

func on_button_pressed():
	#restart game
	get_tree().reload_current_scene()
