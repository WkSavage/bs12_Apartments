var/datum/controller/transfer_controller/transfer_controller

/datum/controller/transfer_controller
	var/timer_buffer = 0
	var/current_tick = 0

/datum/controller/transfer_controller/New()
	timer_buffer = config.vote_autotransfer_initial
	processing_objects += src

/datum/controller/transfer_controller/Destroy()
	processing_objects -= src

/datum/controller/transfer_controller/proc/process()
	current_tick = current_tick + 1
	if(round_duration_in_ticks >= timer_buffer - 1 MINUTES)
		vote.autotransfer()
		timer_buffer = timer_buffer + config.vote_autotransfer_interval
