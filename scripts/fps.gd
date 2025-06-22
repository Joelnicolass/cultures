extends Label

func _process(delta):
    var fps = Engine.get_frames_per_second()
    var text = "FPS: %d" % fps
    if fps < 30:
        text += " (Low FPS!)"
    elif fps < 60:
        text += " (Medium FPS)"
    else:
        text += " (High FPS)"
    
    self.text = text
    self.modulate = Color(1, 1, 1, 1) if fps >= 30 else Color(1, 0, 0, 1)