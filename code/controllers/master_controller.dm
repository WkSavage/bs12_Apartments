//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

var/global/initialization_stage = 0

datum/controller/game_controller
	var/list/shuttle_list // for debugging and VV
	var/init_immediately = FALSE

datum/controller/game_controller/New()
	// there can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		log_debug("Rebuilding Master Controller")
		if(istype(master_controller))
			qdel(master_controller)
		master_controller = src

	if(!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations(setup_titles=1)
		job_master.LoadJobs("config/jobs.txt")
		admin_notice("<span class='danger'>Job setup complete</span>", R_DEBUG)

	if(!syndicate_code_phrase)
		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response	= generate_code_phrase()

/datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	log_red("Initializating master controller...")
	spawn(20)
		createRandomZlevel()

	setup_objects()
	setupgenetics()
	SetupXenoarch()

	transfer_controller = new

	admin_notice("<span class='danger'>Initializations complete.</span>", R_DEBUG)
	initialization_stage |= INITIALIZATION_COMPLETE

datum/controller/game_controller/proc/setup_objects()
	var/watch = 0
	var/count = 0
	var/overwatch = 0
	overwatch = start_watch()

	// Set up antagonists.
	populate_antag_type_list()

	//Set up spawn points.
	populate_spawn_points()

	watch = start_watch()
	log_black("Initializing objects...")
	for(var/atom/movable/object in world)
		if(!deleted(object))
			object.initialize()
			count++
	log_green("	 Initialized [count] objects in [stop_watch(watch)]s.")

	watch = start_watch()
	count = 0
	log_black("Initializing areas...")
	for(var/area/area in all_areas)
		area.initialize()
		count++
	log_green("	 Initialized [count] areas in [stop_watch(watch)]s.")

	watch = start_watch()
	count = 0
	log_black("Initializing atmospherics machinery...")
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()
		count++
	log_green("	 Initialized [count] pipes in [stop_watch(watch)]s.")

	watch = start_watch()
	count = 0
	admin_notice("<span class='danger'>Initializing atmos machinery.</span>", R_DEBUG)
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
			count++
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()
			count++
	log_green("	 Initialized [count] atmospherics machines in [stop_watch(watch)]s.")

	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	log_green("Initializated all objects in [stop_watch(overwatch)]s!")
	log_black(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
