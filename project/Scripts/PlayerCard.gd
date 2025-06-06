extends Card

signal hovered
signal hovered_off


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # On init card, connect to parent: CardManager
    # Else, error
    get_parent().connect_card_signals(self)


func _on_area_2d_mouse_entered() -> void:
    emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
    emit_signal("hovered_off", self)
