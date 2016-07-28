// All /hook/startup/ Procs()

/hook/startup/proc/load_motd()
	world.load_motd()
	return 1

/hook/startup/proc/load_mode()
	world.load_mode()
	return 1

/hook/startup/proc/load_mods()
	world.load_mods()
	world.load_mentors()
	return 1

/hook/startup/proc/populate_gender_datum_list()
	for(var/type in typesof(/datum/gender))
		var/datum/gender/G = new type
		gender_datums[G.key] = G
	return 1

/hook/startup/proc/loadBans()
	return LoadBans()

/hook/startup/proc/loadJobBans()
	jobban_loadbanfile()
	return 1

/hook/startup/proc/createDatacore()
	data_core = new /datum/datacore()
	return 1