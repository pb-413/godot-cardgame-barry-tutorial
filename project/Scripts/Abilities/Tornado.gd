extends Node


const TORNADO_DAMAGE = 1


func trigger_ability(battle_manager, triggering_card: Card):
    battle_manager.toggle_end_turn_button()

    await battle_manager.sleep()

    var monsters_to_destroy = []
    for card in battle_manager.enemy_monsters_on_field:
        card.health = max(0, card.health - TORNADO_DAMAGE)
        card.get_node("Health").text = str(card.health)
        if card.health == 0:
            monsters_to_destroy.append(card)

    await battle_manager.sleep()
    for card in monsters_to_destroy:
        battle_manager.destroy_card(card, battle_manager.PLAYER.ENEMY)

    battle_manager.destroy_card(triggering_card, battle_manager.PLAYER.SELF)
    await battle_manager.sleep()

    battle_manager.toggle_end_turn_button()
