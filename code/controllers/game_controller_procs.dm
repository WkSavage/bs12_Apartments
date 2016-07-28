/datum/controller/game_controller/proc/setup_pregame_master()
	var/overwatch = start_watch()

	log_startup_orange(" * STARTING GAME SETUP INITIALIZATIONS * ")
	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")


	setupTeleportLocs()
	setupGhostTeleportLocs()

	updateHoliday()
	randomise_antigens_order()

	load_whitelist()
	load_alienwhitelist()
	resetInvestigate()

	populate_gear_list()
	load_custom_items()
	load_robot_custom_sprites()

	paiControllerSetup()
	populate_pai_software_list()

	build_map()
	initialise_map_list()

	makepowernets()
	createRadioController()

	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_startup_green("Finished game setup initializations in [stop_watch(overwatch)]s.")
	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")


/datum/controller/game_controller/proc/setup_objects()
	var/watch = start_watch()
	var/count = 0
	var/overwatch = start_watch() // Overall.

	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_startup("Starting object initializations.")
	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

	log_startup("Populating asset cache...")
	populate_asset_cache()
	log_startup_green("	Populated assets in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup("Populating antag type list...")
	populate_antag_type_list()
	log_startup_green("	Populated antag type list in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup("Populating spawn points...")
	populate_spawn_points()
	log_startup_green("	Populated spawn points in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup("Initializing objects...")
	for(var/atom/movable/object in world)
		object.initialize()
		count++
	log_startup_green("	Initialized [count] objects in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup("Initializing areas...")
	for(var/area/area in all_areas)
		area.initialize()
	log_startup_green("	Initialized areas in [stop_watch(watch)]s.")


	watch = start_watch()
	count = 0
	log_startup("Initializing pipe networks...")
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()
		count++
	log_startup_green("	Initialized [count] pipes in [stop_watch(watch)]s.")


	watch = start_watch()
	count = 0
	log_startup("Initializing atmospherics machinery...")
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
			count++
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()
			count++
	log_startup_green("	Initialized [count] atmospherics machines in [stop_watch(watch)]s.")

	log_startup(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

	log_startup_green("Finished object initializations in [stop_watch(overwatch)]s.")

/datum/controller/game_controller/proc/setup_database()
	var/watch = start_watch()

	connectDB()
	connectOldDB()
	ircNotify()