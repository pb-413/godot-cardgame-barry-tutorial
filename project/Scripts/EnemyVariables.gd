extends Node2D


func _ready() -> void:
    # Keep me so that other's know when I'm ready!
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func set_hp(num: String):
    $EnemyHealth.text = num

func draw_card():
    $EnemyDeck.draw_card()
