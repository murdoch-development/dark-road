extends AnimationPlayer

func _ready():
	self.get_animation("Explosion").loop = false
	self.play("Explosion")
	# wait for the animation to finish plus a little bit
	yield(self, "animation_finished")
	yield(get_tree().create_timer(1), "timeout")
	self.stop()	
