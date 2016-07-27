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
		log_startup_debug("Job setup complete in [stop_watch(watch)]s.", R_DEBUG)


/datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	setup_pregame_master()

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()

	createRandomZlevel()

	setup_objects()
	setupgenetics()
	SetupXenoarch()

	transfer_controller = new

	log_startup("Initializations complete")
	initialization_stage |= INITIALIZATION_COMPLETE

/datum/controller/game_controller/proc/setup_pregame_master()
	var/overwatch = start_watch()

	log_startup_orange(" * STARTING GAME SETUP INITIALIZATIONS * ")
	log_startup_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")

	world.load_motd()
	world.load_mode()

	world.load_mods()
	world.load_mentors()

	populate_gender_datum_list()

	LoadBans()
	loadJobBans()

	createDatacore()

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