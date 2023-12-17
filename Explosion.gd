extends AnimationPlayer

func _process(delta):
	$AudioStreamPlayer2D.position = get_parent().position
	$AnimatedSprite.position = get_parent().position
	$Light2D.position = get_parent().position

func _ready():
	yield(get_tree().create_timer(2), "timeout")
	self.get_animation("Explosion").loop = false
	self.play("Explosion")
	# wait for the animation to finish plus a little bit
	yield(self, "animation_finished")
	yield(get_tree().create_timer(1), "timeout")
	self.stop()	
