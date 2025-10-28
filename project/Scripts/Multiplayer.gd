extends Node2D

# The port that the server listens for communications on.
const SERVER_ADDRESS = "localhost"
const PORT = 123

# Create multiplayer object called 'peer' using ENet networking library.
var peer = ENetMultiplayerPeer.new()

@export var player_field_scene: PackedScene


func _dissable_button(button: Button):
    button.disabled = true
    button.visible = false

func dissable_buttons():
    _dissable_button($JoinButton)
    _dissable_button($PlayBotButton)
    _dissable_button($HostButton)


func _on_peer_connected(peer_id):
    print("Player joined!")

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
