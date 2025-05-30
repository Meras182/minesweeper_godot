extends Area2D

const MINE_PROBABILITY = 15

@export var is_mine : bool = false

@onready var ray_right: RayCast2D = $ray_right
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var polygon_base_color = polygon_2d.color
@onready var label: Label = $Label

@onready var rays = [
	%ray_up,
	%ray_up_right, 
	%ray_right, 
	%ray_down_right, 
	%ray_down, 
	%ray_down_left,
	%ray_left,
	%ray_up_left
]

var is_number_of_neigbouring_mines_shown : bool = false
var is_area_marked : bool = false
var neighbours = []
var mouse_inside_area : bool = false

func _ready():
	# Ensure the Area2D is set to detect input events
	set_process_input(true)
	
	#connect to signals
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
	#define whether tile is mine
	is_mine = set_mine()
	
	#DEBBUGING PUPOSE
	#if is_mine:
	#	polygon_2d.color = Color(1, 0, 0, 1)
	#	polygon_base_color = polygon_2d.color

func _input(event):
	#left_mouse click: uncover tile
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mouse_inside_area:
		if is_mine:
			polygon_2d.color = Color(1, 0, 0, 1) #red
			polygon_base_color = polygon_2d.color
			#game over, call main
			get_parent().stop_current_game()
		else:
			if get_parent().is_unmarked_mines_left():
				show_number_of_neigbouring_mines()
			else:
				#victory, call main
				get_parent().stop_current_game()
	
	#right_mouse_click: mark tile
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and mouse_inside_area:
		if is_area_marked:
			unmark_potential_mine()
		else:
			mark_potential_mine()
			if !get_parent().is_unmarked_mines_left():
				#victory, call main
				get_parent().stop_current_game()
				
func set_mine() -> bool:
	var random_number = randi() % 101
	if random_number <= MINE_PROBABILITY:
		return true
	else:
		return false

func get_mine() -> bool:
	return is_mine

func mark_potential_mine():
	is_area_marked = true
	polygon_2d.color = Color(1, 0.5, 0, 0.8) #orange
	polygon_base_color = polygon_2d.color

func unmark_potential_mine():
	is_area_marked = false
	polygon_2d.color = Color(0.9, 0.9, 0.9, 1)
	polygon_base_color = polygon_2d.color

func get_neighbours():
	for ray in rays: 
		if ray.is_colliding():
			neighbours.append(ray.get_collider())

func get_number_of_neigbouring_mines() -> int:
	var number_of_neigbouring_mines : int = 0
	
	for neighbour in neighbours:
		if neighbour != null and neighbour.get_mine():
			number_of_neigbouring_mines += 1
	
	return number_of_neigbouring_mines

func show_number_of_neigbouring_mines():
	#to ensure that recursion is not infinite
	if !is_number_of_neigbouring_mines_shown:
		is_number_of_neigbouring_mines_shown = true
		
		#fill up list of neighbours, only once
		if neighbours.is_empty():
			get_neighbours()
			
		var number_of_neigbouring_mines = get_number_of_neigbouring_mines()
		
		if number_of_neigbouring_mines == 0:
			polygon_2d.color = Color(0.8, 0.8, 0.8, 0.8) #darkgray
			polygon_base_color = polygon_2d.color
			
			#check neighbour's neighbours
			for neighbour in neighbours:
				neighbour.show_number_of_neigbouring_mines()
			
		else:
			#show number of neighbouring mines
			label.visible = true
			label.text = str(number_of_neigbouring_mines)

func on_mouse_entered():
	mouse_inside_area = true
	polygon_2d.color = Color(0.8, 0.8, 0.8, 0.8) #drkgray

func on_mouse_exited():
	mouse_inside_area = false
	polygon_2d.color = polygon_base_color
