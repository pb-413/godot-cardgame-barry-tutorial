extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const INIT_CARD_SCALE = Vector2(.6, .6)
const HIGHLIGHT_CARD_SCALE = Vector2(.65, .65)
const SLOTTED_CARD_SCALE = Vector2(.5, .5)

var card_being_dragged : Node2D
var screen_size : Vector2
var is_hovering_on_card
var player_hand_reference
var has_played_monster_card_per_turn : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    screen_size = get_viewport_rect().size
    player_hand_reference = $"../PlayerHand"
    $"../InputManager".connect("left_mouse_button_released",
                               on_left_click_released)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if card_being_dragged:
        var mouse_pos = get_global_mouse_position()
        card_being_dragged.position = Vector2(
            clamp(mouse_pos.x, 0, screen_size.x),
            clamp(mouse_pos.y, 0, screen_size.y)
        )


func start_drag(card: Node2D):
    card.scale = INIT_CARD_SCALE
    card_being_dragged = card


func finish_drag():
    card_being_dragged.scale = HIGHLIGHT_CARD_SCALE
    var card_slot_found = raycast_check_for_card_slot()
    if card_slot_found and not card_slot_found.card_in_slot:
        # Card dropped in empty slot.
        if card_being_dragged.card_type == card_slot_found.card_slot_type:
            if !has_played_monster_card_per_turn:
                card_being_dragged.scale = SLOTTED_CARD_SCALE
                card_being_dragged.in_slot = card_slot_found
                card_being_dragged.z_index = -1 # under cards in hand
                player_hand_reference.remove_card_from_hand(card_being_dragged)
                card_being_dragged.position = card_slot_found.position
                card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
                card_slot_found.card_in_slot = true
                $"../BattleManager".player_monsters_on_field.append(card_being_dragged)
                card_being_dragged = null
                is_hovering_on_card = false
                has_played_monster_card_per_turn = true
                # Toggle play indicator to red (1).
                $"../PlayIndicator/Area2D/AnimatedSprite2D".frame = 1
                return
    player_hand_reference.add_card_to_hand(card_being_dragged)
    card_being_dragged = null


func connect_card_signals(card):
    card.connect("hovered", on_hover_over_card)
    card.connect("hovered_off", on_hover_off_card)


func on_left_click_released():
    if card_being_dragged:
        finish_drag()


func on_hover_over_card(card):
    if !is_hovering_on_card:
        is_hovering_on_card = true
        highlight_card(card, true)


func on_hover_off_card(card):
    if !card_being_dragged and !card.in_slot:
        highlight_card(card, false)
        var new_card_hovered = raycast_check_for_card()
        if new_card_hovered:
            highlight_card(new_card_hovered, true)
        else:
            is_hovering_on_card = false


func highlight_card(card: Node2D, hovered: bool):
    if hovered:
        card.scale = HIGHLIGHT_CARD_SCALE
        card.z_index = 2
    else:
        card.scale = INIT_CARD_SCALE
        card.z_index = 1


func raycast_check_for_card_slot() -> Variant:
    var space_state = get_world_2d().direct_space_state
    var parameters = PhysicsPointQueryParameters2D.new()
    parameters.position = get_global_mouse_position()
    parameters.collide_with_areas = true
    parameters.collision_mask = COLLISION_MASK_CARD_SLOT
    var result = space_state.intersect_point(parameters)
    if result.size() > 0:
        var slot : Node2D = result[0].collider.get_parent()
        return slot
    return null


func raycast_check_for_card() -> Variant:
    var space_state = get_world_2d().direct_space_state
    var parameters = PhysicsPointQueryParameters2D.new()
    parameters.position = get_global_mouse_position()
    parameters.collide_with_areas = true
    parameters.collision_mask = COLLISION_MASK_CARD
    var result = space_state.intersect_point(parameters)
    if result.size() > 0:
        #var card : Node2D = result[0].collider.get_parent()
        var card = get_card_with_highest_z_index(result)
        return card
    return null


func get_card_with_highest_z_index(cards: Array):
    var highest_z_card : Node2D = cards[0].collider.get_parent()
    var highest_z_index = highest_z_card.z_index

    # Loop over other cards
    for i in range(1, cards.size()):
        var current_card : Node2D = cards[i].collider.get_parent()
        if current_card.z_index > highest_z_index:
            highest_z_card = current_card
            highest_z_index = current_card.z_index

    return highest_z_card


func reset_played_monster():
    has_played_monster_card_per_turn = false
    # Toggle play indicator to green (0).
    $"../PlayIndicator/Area2D/AnimatedSprite2D".frame = 0
