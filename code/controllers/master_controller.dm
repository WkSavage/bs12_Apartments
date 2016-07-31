//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration   = 0
var/global/last_tick_duration     = 0
var/global/air_processing_killed  = 0
var/global/pipe_processing_killed = 0
var/global/initialization_stage   = 0

/datum/controller
	var/processing = 0
	var/iteration = 0
	var/processing_interval = 0

/datum/controller/game_controller
	var/list/shuttle_list
	var/list/digsite_spawning_turfs  = list()
	var/list/artifact_spawning_turfs = list()

/datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		log_debug("Rebuilding Master Controller")
		if(istype(master_controller))
			qdel(master_controller)
		master_controller = src

	if(!job_master)
		job_master = new/datum/controller/occupations()
		job_master.SetupOccupations(setup_titles=1)
		job_master.LoadJobs("config/jobs.txt")
		log_startup_debug("job setup complete!")

/datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	log_startup("Initializating master controller...")
	setup_pregame()
	gen_syndicate_codes()

	create_random_zlevel()

	setup_objects()
	setup_genetics()
	setup_xenoarch()

	transfer_controller = new

	initialization_stage |= INITIALIZATION_COMPLETE
