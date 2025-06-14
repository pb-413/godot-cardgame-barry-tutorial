extends Node

const EnemyCard = preload("res://Scripts/EnemyCard.gd")
const SMALL_CARD_SCALE = Vector2(0.5, 0.5)
const CARD_MOVE_SPEED = 0.2
const STARTING_HEALTH = 10
const WAIT_FOR_ATTACK_ANIMATION = 0.15
const BATTLE_POS_OFFSET = 25

var battle_timer : Timer
var end_turn : Button
var empty_monster_card_slots : Array = []
var enemy_monsters_on_field: Array = []
var enemy_health
var player_monsters_on_field: Array = []
var player_health
var player_cards_attacked_this_turn: Array = []
var is_enemy_turn = false
var is_player_attacking = false

enum PLAYER {SELF, ENEMY}


func update_player_hp(num: int):
    player_health = num
    $"../PlayerHealth".text = str(num)


func update_enemy_hp(num: int):
    enemy_health = num
    $"../EnemyHealth".text = str(num)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    end_turn = $"../EndTurnButton"

    battle_timer = $"../BattleTimer"
    battle_timer.one_shot = true

    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot1")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot2")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot3")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot4")
    empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot5")

    update_player_hp(STARTING_HEALTH)
    update_enemy_hp(STARTING_HEALTH)


func _on_end_turn_button_pressed() -> void:
    is_enemy_turn = true

    $"../CardManager".unselect_selected_monster()
    # Hide end turn button.
    toggle_end_turn_button()

    await enemy_turn()

    # Player is up next.
    # Reset end turn button.
    toggle_end_turn_button()
    # Reset player deck draw
    $"../PlayerDeck".reset_draw()
    $"../CardManager".reset_played_monster()
    # Refresh attackers.
    player_cards_attacked_this_turn = []

    is_enemy_turn = false


func toggle_end_turn_button():
    if end_turn.disabled:
        end_turn.disabled = false
        end_turn.visible = true
    else:
        end_turn.disabled = true
        end_turn.visible = false


func enemy_turn():
    # Enemy takes time to think.
    await sleep()

    # Deck has cards.
    if $"../EnemyDeck".deck.size() != 0:
        $"../EnemyDeck".draw_card()
        # Enemy takes time to think with new card.
        await sleep()

    await play_monster_algo_strongest(empty_monster_card_slots)

    if enemy_monsters_on_field.size() != 0:
        var attackers = enemy_monsters_on_field.duplicate()
        for card in attackers:
            if player_monsters_on_field.size() != 0:
                var target = player_monsters_on_field.pick_random()
                await target_attack(card, target, PLAYER.ENEMY)
            else:
                await direct_attack(card, PLAYER.ENEMY)


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
    var random_empty_slot = slots.pick_random()
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
    enemy_monsters_on_field.append(card_with_highest_atk)
    card_with_highest_atk.in_slot = random_empty_slot

    # Finish playing monster.
    await sleep()


func direct_attack(card: Card, active_player: PLAYER):
    var new_pos_y
    if active_player == PLAYER.ENEMY:
        new_pos_y = 1080
    else:
        is_player_attacking = true
        toggle_end_turn_button()
        new_pos_y = 0
        player_cards_attacked_this_turn.append(card)
    var new_pos = Vector2(card.position.x, new_pos_y)

    var old_z_index = card.z_index
    card.z_index = 5

    # Animate card to position (attack animation)
    var tween = get_tree().create_tween()
    tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)
    await sleep(WAIT_FOR_ATTACK_ANIMATION)

    if active_player == PLAYER.ENEMY:
        update_player_hp(max(0, player_health - card.attack))
    else:
        update_enemy_hp(max(0, enemy_health - card.attack))

    var tween2 = get_tree().create_tween()
    tween2.tween_property(card, "position", card.in_slot.position, CARD_MOVE_SPEED)
    card.z_index = old_z_index

    await sleep()

    if is_player_attacking:
        is_player_attacking = false
        toggle_end_turn_button()


func target_attack(attacker: Card, defender: Card, active_player: PLAYER):
    if active_player == PLAYER.SELF:
        is_player_attacking = true
        toggle_end_turn_button()
        player_cards_attacked_this_turn.append(attacker)
        $"../CardManager".selected_monster = null
    # Animation prep.
    var new_pos = Vector2(
        defender.position.x,
        # TODO doesn't this sign depend on who the attacking player is?
        defender.position.y + BATTLE_POS_OFFSET # + for the enemy attacking?
    )
    var old_z_index = attacker.z_index
    attacker.z_index = 5
    # Animate card to position (attack animation).
    var tween = get_tree().create_tween()
    tween.tween_property(attacker, "position", new_pos, CARD_MOVE_SPEED)
    await sleep(WAIT_FOR_ATTACK_ANIMATION)

    # Reset animation.
    var tween2 = get_tree().create_tween()
    tween2.tween_property(attacker, "position", attacker.in_slot.position, CARD_MOVE_SPEED)
    attacker.z_index = old_z_index

    # Card damage.
    defender.health = max(0, defender.health - attacker.attack)
    defender.get_node("Health").text = str(defender.health)
    attacker.health = max(0, attacker.health - defender.attack)
    attacker.get_node("Health").text = str(attacker.health)

    await sleep()

    # Destroy cards if health is 0.
    var was_card_destroyed = false
    if attacker.health == 0:
        destroy_card(attacker, active_player)
        was_card_destroyed = true
    if defender.health == 0:
        var defending_player
        if active_player == PLAYER.ENEMY:
            defending_player = PLAYER.SELF
        else:
            defending_player = PLAYER.ENEMY
        destroy_card(defender, defending_player)
        was_card_destroyed = true
    if was_card_destroyed:
        await sleep()

    if is_player_attacking:
        is_player_attacking = false
        toggle_end_turn_button()


func destroy_card(card: Card, card_owner: PLAYER):
    # Move to discard.
    var new_pos
    if card_owner == PLAYER.SELF:
        card.is_defeated = true
        new_pos = $"../PlayerDiscard".position
        player_monsters_on_field.erase(card)
        card.in_slot.card_in_slot = false
        card.in_slot.get_node("Area2D/CollisionShape2D").disabled = false
        card.get_node("Area2D/CollisionShape2D").disabled = true
    else:
        new_pos = $"../EnemyDiscard".position
        enemy_monsters_on_field.erase(card)
        # Enemy and player track empty slots differently!
        empty_monster_card_slots.append(card.in_slot)
    card.in_slot = null
    var tween = get_tree().create_tween()
    tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)


func enemy_card_selected(defender: Card):
    var attacker : Variant = $"../CardManager".selected_monster
    var attack_ready = attacker and not is_player_attacking
    var valid_defender = defender in enemy_monsters_on_field
    if attack_ready and valid_defender:
        $"../CardManager".selected_monster = null
        target_attack(attacker, defender, PLAYER.SELF)


func sleep(seconds=1.0):
    battle_timer.wait_time = seconds
    battle_timer.start()
    await battle_timer.timeout
