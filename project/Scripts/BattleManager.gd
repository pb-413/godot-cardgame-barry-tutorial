extends Node

const EnemyCard = preload("res://Scripts/EnemyCard.gd")
const SMALL_CARD_SCALE = Vector2(0.5, 0.5)
const CARD_MOVE_SPEED = 0.2

var battle_timer : Timer
var end_turn : Button
var empty_monster_card_slots : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    end_turn = $"../EndTurnButton"

    battle_timer = $"../BattleTimer"
    battle_timer.one_shot = true
    battle_timer.wait_time = 1.0

    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot1")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot2")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot3")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot4")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot5")


func _on_end_turn_button_pressed() -> void:
    # Hide end turn button.
    end_turn.disabled = true
    end_turn.visible = false

    enemy_turn()

    # Player is up next.
    # Reset end turn button.
    end_turn.visible = true
    end_turn.disabled = false
    # Reset player deck draw
    $"../PlayerDeck".reset_draw()
    $"../CardManager".reset_played_monster()

func enemy_turn():
    # Enemy takes time to think.
    battle_timer.start()
    await battle_timer.timeout

    # Deck has cards.
    if $"../EnemyDeck".enemy_deck.size() != 0:
        $"../EnemyDeck".draw_card()
        # Enemy takes time to think with new card.
        battle_timer.start()
        await battle_timer.timeout

    play_monster_algo_strongest(empty_monster_card_slots)


## Play the card in hand with highest attack.
func play_monster_algo_strongest(slots: Array):
    # Check if free card slots; skip play otherwise.
    var num_empty_slots = slots.size()
    if num_empty_slots == 0:
        return

    # Can't play with an empty hand.
    var hand : Array[EnemyCard] = $"../EnemyHand".enemy_hand
    if hand.size() == 0:
        return

    # Choose a slot to play in.
    var random_empty_slot = slots[randi_range(0, num_empty_slots - 1)]
    slots.erase(random_empty_slot)

    # Choose a card to play.
    var card_with_highest_atk = hand[0]
    for card: EnemyCard in hand:
        if card.attack > card_with_highest_atk.attack:
            card_with_highest_atk = card

    # Animate card to possition.
    var tween = get_tree().create_tween()
    tween.tween_property(card_with_highest_atk, "position", random_empty_slot.position, CARD_MOVE_SPEED)
    var tween2 = get_tree().create_tween()
    tween2.tween_property(card_with_highest_atk, "scale", SMALL_CARD_SCALE, CARD_MOVE_SPEED)
    card_with_highest_atk.get_node("AnimationPlayer").play("card_flip")
    $"../EnemyHand".remove_card_from_hand(card_with_highest_atk)
