//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

//Set in world.New()
var/global/datum/controller/game_controller/master_controller

var/global/last_tick_duration     = 0
var/global/controller_iteration   = 0
var/global/initialization_stage   = 0
var/global/air_processing_killed  = 0
var/global/pipe_processing_killed = 0

/datum/controller
	var/processing = 0
	var/iteration = 0
	var/processing_interval = 0

/datum/controller/game_controller
	var/init_immediately = FALSE
	var/list/shuttle_list  // For debugging and VV

/datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		log_debug("Rebuilding Master Controller")
		if(istype(master_controller))
			qdel(master_controller)
		master_controller = src

	var/watch=0
	if(!job_master)
		watch = start_watch()
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations(setup_titles=1)
		job_master.LoadJobs("config/jobs.txt")
		log_startup_progress("Job setup complete in [stop_watch(watch)]s.", R_DEBUG)

	if(!syndicate_code_phrase)
		syndicate_code_phrase = generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response = generate_code_phrase()

/datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	setup_hooks()

	createRandomZlevel()

	setup_objects()
	setupgenetics()
	SetupXenoarch()

	transfer_controller = new

	log_startup_progress("Initializations complete")
	initialization_stage |= INITIALIZATION_COMPLETE


/datum/controller/game_controller/proc/setup_hooks()
	var/watch = start_watch()
	var/overwatch = start_watch() // Overall.


	log_startup_progress("Loading world.dm startup procs...")
	world.load_mode()
	world.load_motd()
	world.load_mods()
	world.load_mentors()
	log_startup_progress("	Loaded world.dm procs in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Initializing the raido controller...")
	createRadioController()
	log_startup_progress("	Initialized the raido controller in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Initializing roundstart datums...")
	createDatacore()
	populate_gender_datum_list()
	log_startup_progress("	Initialized the datacore datum in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Loading teleport-locs...")
	setupTeleportLocs()
	setupGhostTeleportLocs()
	log_startup_progress("	Loaded teleport-locs in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Loading whitelists...")
	load_whitelist()
	load_alienwhitelist()
	log_startup_progress("	Loaded whitelists in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Loading bans...")
	resetInvestigate()
	loadJobBans()
	LoadBans()
	log_startup_progress("	Loaded bans in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Populating gear list & Loading custom items...")
	populate_gear_list()
	log_startup_progress("	Populated gear in [stop_watch(watch)]s.")
	var/watch_items = start_watch()
	load_custom_items()
	log_startup_progress("	Loaded custom items in [stop_watch(watch_items)]s.")


	watch = start_watch()
	log_startup_progress("Initializing paiController and software...")
	paiControllerSetup()
	populate_pai_software_list()
	log_startup_progress("	Initialized the datacore datum in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Loading custom robot sprites...")
	load_robot_custom_sprites()
	log_startup_progress("	Loaded custom robot sprites in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Building map assets...")
	build_map()
	initialise_map_list()
	log_startup_progress("	Finished building map assets in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Building powernets...")
	makepowernets()
	log_startup_progress("	Finished building powernets in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Generating gas data and randomizing antigens...")
	randomise_antigens_order()
	generateGasData()
	log_startup_progress("	Finished gas data and antigens in [stop_watch(watch)]s.")

	log_startup_progress("Finished startup initializations in [stop_watch(overwatch)]s.")


/datum/controller/game_controller/proc/setup_objects()
	var/watch = start_watch()
	var/count = 0
	var/overwatch = start_watch() // Overall.


	log_startup_progress("Populating asset cache...")
	populate_asset_cache()
	log_startup_progress("	Populated assets in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Populating antag type list...")
	populate_antag_type_list()
	log_startup_progress("	Populated antag type list in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Populating spawn points...")
	populate_spawn_points()
	log_startup_progress("	Populated spawn points in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Initializing objects...")
	for(var/atom/movable/object in world)
		object.initialize()
		count++
	log_startup_progress("	Initialized [count] objects in [stop_watch(watch)]s.")


	watch = start_watch()
	log_startup_progress("Initializing areas...")
	for(var/area/area in all_areas)
		area.initialize()
	log_startup_progress("	Initialized areas in [stop_watch(watch)]s.")


	watch = start_watch()
	count = 0
	log_startup_progress("Initializing pipe networks...")
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()
		count++
	log_startup_progress("	Initialized [count] pipes in [stop_watch(watch)]s.")


	watch = start_watch()
	count = 0
	log_startup_progress("Initializing atmospherics machinery...")
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
			count++
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()
			count++
	log_startup_progress("	Initialized [count] atmospherics machines in [stop_watch(watch)]s.")


	log_startup_progress("Finished object initializations in [stop_watch(overwatch)]s.")
