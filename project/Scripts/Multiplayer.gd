extends Node2D

# The port that the server listens for communications on.
const SERVER_ADDRESS = "localhost"
# Higher number resulted in more reliable use
# Context: "Ports below 1024 are considered privileged" -Google search
const PORT = 9999
# Troubleshooting in CMD:
# - netstat -ano | findstr <port number>
# - tasklist | findstr <process id>
# - taskkill /F /PID <process id>

# Create multiplayer object called 'peer' using ENet networking library.
var peer = ENetMultiplayerPeer.new()

@export var player_field_scene: PackedScene
@export var enemy_field_scene: PackedScene

# To host safely and repeatitively,
# do I have to teardown the server during quit? -> No, use higher port number!
#func _ready():
    #get_tree().set_auto_accept_quit(false)
#
#func _notification(what: int) -> void:
    #if what == NOTIFICATION_WM_CLOSE_REQUEST:
        ## Shutdown networking server.
        #multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
        #get_tree().quit()

func _dissable_button(button: Button):
    button.disabled = true
    button.visible = false

func dissable_buttons():
    _dissable_button($JoinButton)
    _dissable_button($PlayBotButton)
    _dissable_button($HostButton)


func _on_peer_connected(peer_id):
    var enemy_scene = enemy_field_scene.instantiate()
    add_child(enemy_scene)

    get_node("PlayerField").host_set_up()

func _on_host_button_pressed() -> void:
    dissable_buttons()

    # Create server (set our object 'peer' to a server that listens on PORT).
    peer.create_server(PORT)

    # 'multiplayer' is a built-in property of all scenes in Godot
    # (accessible from anywhere).
    # 'multiplayer_peer' is a property of multiplayer where we can assign the
    # object responsible for networking.
    multiplayer.multiplayer_peer = peer

    multiplayer.peer_connected.connect(_on_peer_connected)

    var player_scene = player_field_scene.instantiate()
    add_child(player_scene)


func _on_join_button_pressed() -> void:
    dissable_buttons()

    peer.create_client(SERVER_ADDRESS, PORT)
    multiplayer.multiplayer_peer = peer

    var player_scene = player_field_scene.instantiate()
    add_child(player_scene)

    var enemy_scene = enemy_field_scene.instantiate()
    add_child(enemy_scene)

    player_scene.client_set_up()
