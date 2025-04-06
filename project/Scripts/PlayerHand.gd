extends Node2D

const CARD_WIDTH = 150
const HAND_Y_POSITION = 955
const DEFAULT_CARD_MOVE_SPEED = 0.1
var player_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    center_screen_x = get_viewport().size.x / 2


func add_card_to_hand(card, speed=DEFAULT_CARD_MOVE_SPEED):
    if card not in player_hand:
        player_hand.insert(0, card)
        update_hand_positions(speed)
    else:
        animate_card_to_position(card, card.hand_position, speed)


func update_hand_positions(speed=DEFAULT_CARD_MOVE_SPEED):
    for i in range(player_hand.size()):
        var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
        var card = player_hand[i]
        card.hand_position = new_position
        animate_card_to_position(card, new_position, speed)


func calculate_card_position(index):
    # To add a space between cards without scaling them,
    # add a padding value.
    var double_pad_propotion = 1.0 + (1.0/16)
    var fake_width = CARD_WIDTH * double_pad_propotion
    var x_offset = (player_hand.size() - 1) * fake_width
    var x_position = center_screen_x + index * fake_width - x_offset / 2
    return x_position


func animate_card_to_position(card, new_position, speed=DEFAULT_CARD_MOVE_SPEED):
    # This function has a default speed,
    # but it is so far always passed a speed from callers.
    # This is because they *also* have speed as a param:
    # - add_card_to_hand
    # - update_hand_positions
    # Should this function *not* have a default?
    var tween = get_tree().create_tween()
    tween.tween_property(card, "position", new_position, speed)


func remove_card_from_hand(card):
    if card in player_hand:
        player_hand.erase(card)
        update_hand_positions()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
