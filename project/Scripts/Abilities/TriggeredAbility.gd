class_name TriggeredAbility

extends Node


enum TRIGGER {PLAYED, ATTACK}

var trigger_type : TRIGGER


func _init() -> void:
    print("Initializing abstract base class 'TriggeredAbility'!")
    print("Override this method (_init) and type-hint your ability!")
    print("e.g. trigger_type = TRIGGER.PLAYED")


func trigger_ability(battle_manager, triggering_card: Card):
    print("Triggered abstract base class 'TriggeredAbility' trigger_ability() func.")
    print(battle_manager)
    print(triggering_card)
