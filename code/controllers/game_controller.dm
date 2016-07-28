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
