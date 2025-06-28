extends TriggeredAbility


var already_activated_this_turn : bool = false


func _init() -> void:
    trigger_type = TRIGGER.ATTACK
    needs_reset = true


func trigger_ability(battle_manager, triggering_card: Card):
    if already_activated_this_turn:
        return

    if triggering_card in battle_manager.player_cards_attacked_this_turn:
        battle_manager.player_cards_attacked_this_turn.erase(triggering_card)
        already_activated_this_turn = true


func end_turn_reset():
    already_activated_this_turn = false
