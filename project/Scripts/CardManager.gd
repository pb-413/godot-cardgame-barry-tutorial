extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const INIT_CARD_SCALE = Vector2(.6, .6)
const HIGHLIGHT_CARD_SCALE = Vector2(.65, .65)
const SLOTTED_CARD_SCALE = Vector2(.5, .5)
const HIGHLIGHT_SELECTED = 20

var card_being_dragged : Card
var screen_size : Vector2
var is_hovering_on_card
var player_hand_reference
var input_manager_reference
var has_played_monster_card_per_turn : bool = false
var battle_manager : Node
var selected_monster: Card


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    screen_size = get_viewport_rect().size
    player_hand_reference = $"../PlayerHand"
    input_manager_reference = $"../InputManager"
    input_manager_reference.connect("left_mouse_button_released",
                                    on_left_click_released)
    battle_manager = $"../BattleManager"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if card_being_dragged:
        var mouse_pos = get_global_mouse_position()
        card_being_dragged.position = Vector2(
            clamp(mouse_pos.x, 0, screen_size.x),
            clamp(mouse_pos.y, 0, screen_size.y)
        )


func card_clicked(card: Card):
    if battle_manager.is_player_attacking:
        return

    if card.in_slot:
        player_attack(card)
    else:
        start_drag(card)


func player_attack(card: Card):
    if card in battle_manager.player_cards_attacked_this_turn:
        return
    if battle_manager.is_enemy_turn:
        return
    if card.card_type != "Monster":
        return

    var ACTIVE_PLAYER = battle_manager.PLAYER.SELF
    if battle_manager.enemy_monsters_on_field.size() == 0:
        battle_manager.direct_attack(card, ACTIVE_PLAYER)
    else:
        # card = select_card_for_battle(card)?
        select_card_for_battle(card)


func select_card_for_battle(card: Card) -> Variant:
    if selected_monster:
        # Un-highlight last pick.
        selected_monster.position.y += HIGHLIGHT_SELECTED
        if selected_monster == card:
            # De-select it.
            selected_monster = null
        else:
            # Select new attacker instead.
            selected_monster = card
            card.position.y -= HIGHLIGHT_SELECTED
    else:
        selected_monster = card
        card.position.y -= HIGHLIGHT_SELECTED
    return selected_monster


func unselect_selected_monster():
    if selected_monster:
        selected_monster.position.y += HIGHLIGHT_SELECTED
        selected_monster = null


func start_drag(card: Card):
    card.scale = INIT_CARD_SCALE
    card_being_dragged = card


func reset_unplayed_card():
    player_hand_reference.add_card_to_hand(card_being_dragged)
    is_hovering_on_card = false
    card_being_dragged = null


func finish_drag():
    card_being_dragged.scale = HIGHLIGHT_CARD_SCALE
    var card_slot_found = raycast_check_for_card_slot()

    # Protect state by reseting card_being_dragged if a play won't happen.
    if not card_slot_found:
        reset_unplayed_card()
        return # Can't continue with a null for card_slot_found.
    if card_slot_found.card_in_slot:
        reset_unplayed_card()
    # Card dropped in empty slot.
    if card_being_dragged.card_type != card_slot_found.card_slot_type:
        reset_unplayed_card()
    # Don't let them play more than one monster per turn.
    if has_played_monster_card_per_turn and card_being_dragged.card_type == "Monster":
        reset_unplayed_card()
    if not card_being_dragged:
        return

    card_being_dragged.scale = SLOTTED_CARD_SCALE
    card_being_dragged.in_slot = card_slot_found
    card_being_dragged.z_index = -1 # under cards in hand
    player_hand_reference.remove_card_from_hand(card_being_dragged)
    card_being_dragged.position = card_slot_found.position
    card_slot_found.card_in_slot = true
    card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
    if card_being_dragged.card_type == "Monster":
        $"../BattleManager".player_monsters_on_field.append(card_being_dragged)
        has_played_monster_card_per_turn = true
        # Toggle play indicator to red (1).
        $"../PlayIndicator/Area2D/AnimatedSprite2D".frame = 1
    else:
        input_manager_reference.inputs_disabled = true
        card_being_dragged.ability_script.trigger_ability(battle_manager, card_being_dragged)
        input_manager_reference.inputs_disabled = false

    is_hovering_on_card = false
    card_being_dragged = null


func connect_card_signals(card):
    card.connect("hovered", on_hover_over_card)
    card.connect("hovered_off", on_hover_off_card)


func on_left_click_released():
    if card_being_dragged:
        finish_drag()


func on_hover_over_card(card: Card):
    if card.in_slot:
        return
    if !is_hovering_on_card:
        is_hovering_on_card = true
        highlight_card(card, true)


func on_hover_off_card(card: Card):
    if !card_being_dragged and !card.in_slot and !card.is_defeated:
        highlight_card(card, false)
        var new_card_hovered = raycast_check_for_card()
        if new_card_hovered:
            highlight_card(new_card_hovered, true)
        else:
            is_hovering_on_card = false


func highlight_card(card: Card, hovered: bool):
    if card.in_slot:
        return
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
        var card : Card = get_card_with_highest_z_index(result)
        return card
    return null


func get_card_with_highest_z_index(cards: Array):
    var highest_z_card : Card = cards[0].collider.get_parent()
    var highest_z_index = highest_z_card.z_index

    # Loop over other cards
    for i in range(1, cards.size()):
        var current_card : Card = cards[i].collider.get_parent()
        if current_card.z_index > highest_z_index:
            highest_z_card = current_card
            highest_z_index = current_card.z_index

    return highest_z_card


func reset_played_monster():
    has_played_monster_card_per_turn = false
    # Toggle play indicator to green (0).
    $"../PlayIndicator/Area2D/AnimatedSprite2D".frame = 0
