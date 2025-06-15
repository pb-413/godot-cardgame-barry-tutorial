extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4
const COLLISION_MASK_ENEMY_CARD = 8 # layer/mask 4, value 8.

var card_manager_reference
var deck_reference
var battle_manager_ref


func _ready() -> void:
    card_manager_reference = $"../CardManager"
    deck_reference = $"../PlayerDeck"
    battle_manager_ref = $"../BattleManager"


func _input(event: InputEvent) -> void:
    if ( event is InputEventMouseButton
         and event.button_index == MOUSE_BUTTON_LEFT ):
        if event.pressed:
            emit_signal("left_mouse_button_clicked")
            raycast_at_cursor()
        else:
            emit_signal("left_mouse_button_released")


func raycast_at_cursor():
    var space_state = get_world_2d().direct_space_state
    var parameters = PhysicsPointQueryParameters2D.new()
    parameters.position = get_global_mouse_position()
    parameters.collide_with_areas = true
    var result = space_state.intersect_point(parameters)
    if result.size() > 0:
        var collider = result[0].collider
        var result_mask = collider.collision_mask
        if result_mask == COLLISION_MASK_CARD:
            # Card clicked.
            var card_found = collider.get_parent()
            if card_found:
                card_manager_reference.card_clicked(card_found)
        elif result_mask == COLLISION_MASK_DECK:
            # Deck clicked.
            if not deck_reference.has_drawn_for_turn:
                deck_reference.draw_card()
        elif result_mask == COLLISION_MASK_ENEMY_CARD:
            # Enemy card clicked.
            var enemy_card_found = collider.get_parent()
            if enemy_card_found:
                battle_manager_ref.enemy_card_selected(enemy_card_found)
