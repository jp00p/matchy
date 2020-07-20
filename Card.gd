extends Control

export(int) var card_value = 0
var card_texture = null
var card_back_texture = null
onready var label = $CenterContainer/Label 
var revealed = false
var solved = false
signal flipped

func _ready():	
	hide()
	
func _enter_tree():
	var card_front = $Art/FrontRect
	var card_back = $Art/BackRect
	if GLOBALS.selected_game == "tng":
		card_back_texture = load("res://cardbacks/Babylong_5_CCG_cardback.jpg")
	else:
		card_back_texture = load("res://cardbacks/148174-9560737Fr.jpg")
		
	card_front.texture = card_texture
	card_back.texture = card_back_texture
	
	$CenterContainer/Label.text = str(card_value)
	

func after_flip():
	$Art/Back.set_visible(false)

func reveal(): # function to reveal or hide this card (val is a boolean)
	if solved or revealed: 
		return # don't do anything to this card after solved	
	$AnimationPlayer.play("flip_show")
	yield($AnimationPlayer, "animation_finished")
	revealed = true
	
func hide():
	if solved or !revealed: 
		return 
	$AnimationPlayer.play("flip_hide")
	yield($AnimationPlayer, "animation_finished")
	revealed = false
	
func solve():
	solved = true
	$AnimationPlayer.play("solve")
	yield($AnimationPlayer, "animation_finished")
	#self.set_visible(false)  don't hide it because then the grid shifts

func _input(event):
	if event.is_action_pressed("click"):
		if get_global_rect().has_point(event.position):
			if(!revealed and !solved):
				# dont do anything to a card that is revealed or solved already
				#yield($AnimationPlayer, "animation_finished")
				emit_signal("flipped", self)
