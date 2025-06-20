## Base class for all cards (enemy or player).
class_name Card

extends Node

var hand_position
## Slot card is in.
var in_slot : Node2D
var card_type : String
var attack : int
var health : int
var is_defeated : bool = false
var ability_script
