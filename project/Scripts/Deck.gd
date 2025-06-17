## Base class for all decks (enemy or player).
class_name Deck

extends Node2D

const CARD_DRAW_SPEED = .3
const STARTING_HAND_SIZE = 4
const CARD_DATABASE_PATH = "res://Resources/CardDatabase.tres"

var deck : Array
var card_database_reference : Dictionary
var card_scene : Resource
var hand_node : Node2D


## 'deck' must be defined in order to ready a Deck object.
func _ready():
    deck.shuffle()
    $RichTextLabel.text = str(deck.size())
    card_database_reference = load(CARD_DATABASE_PATH).data

    for i in range(STARTING_HAND_SIZE):
        draw_card()


func draw_card() -> Variant:
    var out_of_cards = deck.size() <= 0
    if out_of_cards:
        return

    var card_drawn_name : String = deck[0]
    deck.erase(card_drawn_name)

    # Drew last card? -> Hide deck.
    if deck.size() <= 0:
        hide_deck()

    $RichTextLabel.text = str(deck.size())

    var new_card = card_scene.instantiate()
    var card_image_path = str("res://Assets/" + card_drawn_name + "Card.png")
    new_card.get_node("CardImage").texture = load(card_image_path)
    new_card.card_type = card_database_reference[card_drawn_name]["Type"]
    if new_card.card_type == "Monster":
        new_card.attack = card_database_reference[card_drawn_name]["Attack"]
        new_card.health = card_database_reference[card_drawn_name]["Health"]
        new_card.get_node("Attack").text = str(new_card.attack)
        new_card.get_node("Health").text = str(new_card.health)
        new_card.get_node("Ability").visible = false
    else:
        new_card.get_node("Attack").visible = false
        new_card.get_node("Health").visible = false
        new_card.get_node("Ability").text = card_database_reference[card_drawn_name]["Ability"]
    $"../CardManager".add_child(new_card)
    new_card.name = "card"
    hand_node.add_card_to_hand(new_card, CARD_DRAW_SPEED)
    return new_card


func hide_deck():
    $Sprite2D.visible = false
    $RichTextLabel.visible = false
