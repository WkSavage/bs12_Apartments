var/datum/controller/failsafe/failsafe

// This thing pretty much just keeps poking the master controller
/datum/controller/failsafe
	var/processing_interval = 100 // poke the MC every 10 seconds

// ALERT LEVEL. For every poke that fails this is raised by 1. When it reaches 5 the MC is replaced with a new one.
	var/mc_defcon = 0
	var/mc_iteration = 0

/datum/controller/failsafe/New()
	. = ..()

	// There can be only one failsafe. Out with the old in with the new (that way we can restart the Failsafe by spawning a new one).
	if(failsafe != src)
		if(istype(failsafe))
			recover()
			qdel(failsafe)

		failsafe = src

	failsafe.process()

/datum/controller/failsafe/proc/process()
	processing = 1

	spawn(0)
		set background = 1

		while(1) // more efficient than recursivly calling ourself over and over. background = 1 ensures we do not trigger an infinite loop
			iteration++

			if(processing)
				if(master_controller.processing)
					if(masterControllerIteration == master_controller.iteration)
						switch(mc_defcon)
							if(0 to 3)
								mc_defcon++
							if(4)
								admins << "<font color='red' size='2'><b>Warning. The Lighting Controller has not fired in the last [lighting_defcon*processing_interval] ticks. Automatic restart in [processing_interval] ticks.</b></font>"
								mc_defcon = 5
							if(5)
								admins << "<font color='red' size='2'><b>Warning. The Lighting Controller has still not fired within the last [lighting_defcon*processing_interval] ticks. Killing and restarting...</b></font>"
								new /datum/controller/lighting()	//replace the old lighting_controller (hence killing the old one's process)
								master_controller.process()		//Start it rolling again
								mc_defcon = 0
					else
						mc_defcon = 0
						master_controller = master_controller.iteration
			else
				mc_defcon = 0

			sleep(processing_interval)