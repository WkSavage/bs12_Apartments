
/proc/power_failure(var/announce = 1, var/severity = 2, var/list/affected_z_levels)
	if(announce)
		command_announcement.Announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", new_sound = 'sound/AI/poweroff.ogg')

	for(var/buildable in machines)
		var/obj/machinery/power/smes/buildable/S = buildable
		CHECK_PRE_TICK
		S.energy_fail(rand(15 * severity,30 * severity))
		CHECK_TICK

	for(var/apc in machines)
		var/obj/machinery/power/apc/C = apc
		if(!C.is_critical && (!affected_z_levels || (C.z in affected_z_levels)))
			CHECK_PRE_TICK
			C.energy_fail(rand(30 * severity,60 * severity))
			CHECK_TICK

/proc/power_restore(var/announce = 1)
	var/list/skipped_areas = list(/area/turret_protected/ai)

	if(announce)
		command_announcement.Announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')
	for(var/apc in machines)
		var/obj/machinery/power/apc/C = apc
		C.failure_timer = 0
		if(C.cell)
			C.cell.charge = C.cell.maxcharge
			CHECK_TICK
	for(var/smes in machines)
		var/obj/machinery/power/smes/S = smes
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas)
			continue
		S.failure_timer = 0
		S.charge = S.capacity
		CHECK_TICK
		S.update_icon()
		S.power_change()
		CHECK_TICK

/proc/power_restore_quick(var/announce = 1)
	if(announce)
		command_announcement.Announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')
	for(var/smes in machines)
		var/obj/machinery/power/smes/S = smes
		S.failure_timer = 0
		S.charge = S.capacity
		CHECK_TICK
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.input_attempt = 1
		S.update_icon()
		S.power_change()
		CHECK_TICK
