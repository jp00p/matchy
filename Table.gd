extends Node2D

onready var Card = preload("res://Card.tscn") # points to the Card scene!
var deck = [] # empty array, our deck of match2 cards
var last_flipped_card = null # for checking matches
var cards_revealed = 0 # obvious counter
var fronts = []
var isOnBuild = true

func load_fronts(game):
	var path_to_fronts
	if(game == "tng"):
		path_to_fronts = "res://tngcards/"
	else:
		path_to_fronts = "res://ds9cards/"
	var temp_fronts = []
	var dir = Directory.new()
	dir.open(path_to_fronts)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		print(file)
		if file == "":
			print("All files")
			break
		if isOnBuild:# exported version
			if file.ends_with('.import'):  
				var file_name = file.replace('.import', '')
				if file_name.ends_with('.jpg'):
					temp_fronts.append(load(path_to_fronts+file_name))
		else:# in editor version
			if file.ends_with('.jpg'): 
				temp_fronts.append(load(path_to_fronts+file))
		
	dir.list_dir_end()
	print(temp_fronts)
	temp_fronts.shuffle()
	return temp_fronts


func _ready():
	
	if OS.has_feature("standalone"):
		print("Running an exported build.")
		isOnBuild = true
	else:
		print("Running from the editor.")
		
	randomize() # new random numbers each time the game runs
	fronts = load_fronts(GLOBALS.selected_game)
	build_deck(18) # build our match2 deck
	deck.shuffle() # shuffle the deck!
	for i in range(deck.size()): # for each value in the deck...
		var card = Card.instance() # create a new Card scene
		card.connect("flipped", self, "card_flipped") # connect the new Card's signal
		card.card_value = deck[i]
		card.card_texture = fronts[deck[i]]
		$CardContainer.add_child(card) # add the new Card to the table!


func build_deck(num): # builds a deck of match2 cards (num is an integer, the number of cards desired)
	
	var deck1 = [] # two temporary decks
	var deck2 = [] # empty arrays
	
	for i in range(floor(num/2)): # for each number of cards desired (divided by 2, rounded down)
		# divided by 2 because each card will be duplicated!  so if you want 12 cards, we are making 6x2 cards
		deck1.push_front(i) # add that number to the temp deck
		deck2.push_front(i) # and the other temp deck
	
	deck = deck1 + deck2 # combine the two temp decks into the real deck


func card_flipped(flipped_card):
	if(cards_revealed >= 2): 
		return # dont let them flip more than 2!
		
	cards_revealed += 1
	flipped_card.reveal() # show the card we clicked
	
	if last_flipped_card == null: # no other cards flipped right now?
		last_flipped_card = flipped_card # set it to the card we just flipped
		return # and that's all we wanna do in this case bye!
	else:
		# we have already flipped one card
		if(last_flipped_card.card_value == flipped_card.card_value): # does it match the card we previously flipped?
			
			print("match!")
			yield(get_tree().create_timer(1), "timeout") # wait half a sec
			flipped_card.solve()
			last_flipped_card.solve()
			
		else: # it doesn't match the previously flipped card
			
			print("not a match")
			yield(get_tree().create_timer(1), "timeout") # wait half a sec
			for n in $CardContainer.get_children(): # loop over all the Card scenes that are in $CardContainer
				n.hide() # run the Card's reveal() function to hide them
					
		last_flipped_card = null # either way (with 2 cards), we clear the last flipped card
		cards_revealed = 0 # and reset this counter


func _on_Button_pressed():
	get_tree().change_scene("res://Title.tscn")
