extends Node

var battle_timer : Timer
var empty_monster_card_slots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    battle_timer = $"../BattleTimer"
    battle_timer.one_shot = true
    battle_timer.wait_time = 1.0

    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot1")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot2")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot3")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot4")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot5")


func enemy_turn():
    $"../EndTurnButton".disabled = true
    $"../EndTurnButton".visibile = false

    $"../EnemyDeck".draw_card()
    # Enemy takes time to think.
    battle_timer.start()
    await battle_timer.timeout

    # Check if free monster card slots; end turn otherwise.
    if empty_monster_card_slots.size() == 0:
        return

    # Play the card in hand with highest attack.


func _on_end_turn_button_pressed() -> void:
    enemy_turn()
    # Player is up next.
    # Reset end turn button.
    $"../EndTurnButton".disabled = false
    $"../EndTurnButton".visibile = true
    # Reset plater deck draw
