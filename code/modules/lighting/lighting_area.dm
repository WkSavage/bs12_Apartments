/area
	luminosity           = 1
	var/dynamic_lighting = 1

/area/New()
	. = ..()

	if(dynamic_lighting)
		luminosity = 0