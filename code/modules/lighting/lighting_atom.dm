/atom
	var/light_power = 1 // Intensity of the light
	var/light_range = 0 // Range in tiles of the light
	var/light_color     // Hexadecimal RGB string representing the colour of the light

	var/datum/light_source/light
	var/list/light_sources

/atom/proc/set_light(l_range, l_power, l_color)
 	if(l_power != null) light_power = l_power
 	if(l_range != null) light_range = l_range
 	if(l_color != null) light_color = l_color

 	update_light()

/atom/proc/copy_light(atom/A)
	set_light(A.light_range, A.light_power, A.light_color)

/atom/proc/update_light()
	set waitfor = FALSE

	if(!lighting_corners_initialised)
		sleep(20)

	if(!light_power || !light_range)
		if(light)
			light.destroy()
			light = null
	else
		if(!istype(loc, /atom/movable))
			. = src
		else
			. = loc

		if(light)
			light.update(.)
		else
			light = new/datum/light_source(src, .)

/atom/New()
	. = ..()

	if(light_power && light_range)
		update_light()

/atom/Destroy()
	if(light)
		light.destroy()
		light = null

	if(opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	. = ..()

/atom/movable/Destroy()
	var/turf/T = loc
	if(opacity && istype(T))
		T.reconsider_lights()
	. = ..()

/atom/proc/set_opacity(new_opacity)
	if(opacity != new_opacity)
		opacity = new_opacity
		var/turf/T = loc
		if(istype(T))
			T.reconsider_lights()

/atom/Entered(atom/movable/obj, atom/prev_loc)
	. = ..()

	if(obj && prev_loc != src)
		for(var/datum/light_source/L in obj.light_sources)
			L.source_atom.update_light()
