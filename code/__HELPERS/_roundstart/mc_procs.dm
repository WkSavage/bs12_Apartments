/datum/controller/game_controller/proc/setup_pregame()
	var/watch = 0
	watch = start_watch()

	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_startup("Starting game setup initializations...")
	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

	LoadBans()
	build_map()
	get_holiday()
	makepowernets()
	create_datacore()
	load_world_procs()
	investigate_reset()
	load_custom_items()
	jobban_loadbanfile()
	populate_gear_list()
	setup_teleport_locs()
	pai_controller_setup()
	create_radio_controller()
	randomise_antigens_order()
	load_robot_custom_sprites()
	setup_ghost_teleport_locs()
	populate_gender_datum_list()
	populate_pai_software_list()

	log_startup_green("	 Finished game setup initializations in [stop_watch(watch)]s.")
	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

/datum/controller/game_controller/proc/setup_objects()
	var/watch = 0
	var/count = 0
	var/overwatch = 0

	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_startup("Starting object initializations...")
	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

	watch = start_watch()
	overwatch = start_watch()

	log_startup_orange("Populating asset cache...")
	populate_asset_cache()
	log_startup_green("	 Populated assets in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_orange("Populating antag type list...")
	populate_antag_type_list()
	log_startup_green("	 Populated antag type list in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_orange("Populating spawn points...")
	populate_spawn_points()
	log_startup_green("	 Populated spawn points in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_orange("Initializing areas...")
	for(var/area/area in all_areas)
		area.initialize()
	log_startup_green("	 Initialized areas in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_yellow("Initializing objects...")
	for(var/atom/movable/object in world)
		if(!deleted(object))
			object.initialize()
			count++
	log_startup_green("	 Initialized [count] objects in [stop_watch(watch)]s.")


	watch = start_watch()
	count = 0
	log_startup_yellow("Initializing pipe networks...")
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()
		count++
	log_startup_green("	 Initialized [count] pipes in [stop_watch(watch)]s.")


	watch = start_watch()
	count = 0
	log_startup_yellow("Initializing atmospherics machinery...")
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
			count++
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()
			count++
	log_startup_green("	 Initialized [count] atmospherics machines in [stop_watch(watch)]s.")

	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_startup_green("	 Initializated all objects in [stop_watch(overwatch)]s.")
	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")


/datum/controller/game_controller/proc/gen_syndicate_codes()
	if(!syndicate_code_phrase)
		syndicate_code_phrase = generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response = generate_code_phrase()
