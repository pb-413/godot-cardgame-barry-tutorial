extends TriggeredAbility


const ARROW_DAMAGE = 1


func _init() -> void:
    trigger_type = TRIGGER.PLAYED
    needs_reset = false


func trigger_ability(battle_manager, triggering_card: Card):
    battle_manager.toggle_end_turn_button()

    await battle_manager.sleep()

    battle_manager.damage_enemy_hp(ARROW_DAMAGE)

    await battle_manager.sleep()

    battle_manager.toggle_end_turn_button()
