/datum/controller/game_controller/proc/setup_pregame()
	var/watch = 0
	watch = start_watch()

	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_red("Starting game setup initializations...")
	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

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

	log_green("Finished game setup initializations in [stop_watch(watch)]s.")
	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

/datum/controller/game_controller/proc/setup_objects()
	var/watch = 0
	var/count = 0
	var/overwatch = 0

	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_red("Starting object initializations...")
	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

	watch = start_watch()
	overwatch = start_watch()

	log_black("Populating asset cache...")
	populate_asset_cache()
	log_green("	 Populated assets in [stop_watch(watch)]s.")

	watch = start_watch()
	log_black("Populating antag type list...")
	populate_antag_type_list()
	log_green("	 Populated antag type list in [stop_watch(watch)]s.")

	watch = start_watch()
	log_black("Populating spawn points...")
	populate_spawn_points()
	log_green("	 Populated spawn points in [stop_watch(watch)]s.")

	watch = start_watch()
	log_black("Initializing areas...")
	for(var/area/area in all_areas)
		area.initialize()
	log_green("	 Initialized areas in [stop_watch(watch)]s.")

	watch = start_watch()
	log_black("Initializing objects...")
	for(var/atom/movable/object in world)
		if(!deleted(object))
			CHECK_TICK_MC_INIT // Counting objects is laggy!!
			object.initialize()
			CHECK_TICK_MC_INIT
			count++
	log_green("	 Initialized [count] objects in [stop_watch(watch)]s.")

	watch = start_watch()
	count = 0
	log_black("Initializing pipe networks...")
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()
		count++
	log_green("	 Initialized [count] pipes in [stop_watch(watch)]s.")

	watch = start_watch()
	count = 0
	log_black("Initializing atmospherics machinery...")
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
			CHECK_TICK_MC_INIT
			count++
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()
			CHECK_TICK_MC_INIT
			count++
	log_green("	 Initialized [count] atmospherics machines in [stop_watch(watch)]s.")

	CHECK_TICK_MC_INIT

	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_green("Initializated all objects in [stop_watch(overwatch)]s!")
	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")


/datum/controller/game_controller/proc/gen_syndicate_codes()
	if(!syndicate_code_phrase)
		syndicate_code_phrase = generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response = generate_code_phrase()
