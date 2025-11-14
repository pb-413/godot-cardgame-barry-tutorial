extends Node


const STARTING_HEALTH: int = 10


func host_set_up():
    # Set player and enemy health
    $BattleManager.update_player_hp(STARTING_HEALTH)
    $BattleManager.update_enemy_hp(STARTING_HEALTH)

    # Set deck text count and draw initial hand
    await $PlayerDeck.draw_initial_hand()

    # Make end turn button visible as the host will play first
    $BattleManager.toggle_end_turn_button()

    # Enable inputs
    $InputManager.inputs_disabled = false


func client_set_up():
    pass
