var/datum/controller/failsafe/failsafe

// This thing pretty much just keeps poking the master controller
/datum/controller/failsafe
	processing_interval = 50 // poke the MC every 5 seconds

// For every poke that fails this is lowered by 1. When it reaches 0 the MC is replaced with a new one.
	var/ps_defcon = 6

/datum/controller/failsafe/New()
	. = ..()

	// There can be only one failsafe. Out with the old in with the new (that way we can restart the Failsafe by spawning a new one).
	if(failsafe != src)
		if(istype(failsafe))
			qdel(failsafe)

		failsafe = src

	failsafe.process()

/datum/controller/failsafe/proc/process()
	processing = 1

	spawn(0)
		set background = 1

		while(1) // more efficient than recursivly calling ourself over and over. background = 1 ensures we do not trigger an infinite loop
			if(processing)
				if(processScheduler.processing)
					switch(ps_defcon)
						if(6 to 4)
							ps_defcon--
							log_to_debug("processScheduler did not fire. DEFCON = [ps_defcon].")
						if(3)
							log_blue("processScheduler has not fired in the last [ps_defcon * processing_interval]. DEFCON = [ps_defcon].")
							ps_defcon--
						if(2)
							log_yellow("processScheduler has still not fired in the last [ps_defcon * processing_interval] ticks. DEFCON = [ps_defcon].")
							ps_defcon = 1
						if(1)
							log_red("DEFCON 1. processScheduler has STILL not fired in the last [ps_defcon * processing_interval] ticks. Killing and restarting")
							recover_ps()
				else
					ps_defcon = 6
			else
				ps_defcon = 6

			sleep(processing_interval)

/datum/controller/failsafe/proc/recover_ps()
	qdel(processScheduler)
	processScheduler = new
	spawn(1)
		processScheduler.start()
	ps_defcon = 6