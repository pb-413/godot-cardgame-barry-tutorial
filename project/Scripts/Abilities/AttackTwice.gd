extends TriggeredAbility


func _init() -> void:
    trigger_type = TRIGGER.ATTACK


func trigger_ability(battle_manager, triggering_card: Card):
    print("attack twice trigger")
