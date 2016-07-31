/proc/load_world_procs()
	world.load_mode()
	world.load_motd()
	world.load_mods()
	world.load_mentors() // no need to write another hook.

/proc/create_radio_controller()
	radio_controller = new/datum/controller/radio()

/proc/create_datacore()
	data_core = new/datum/datacore()

/proc/setup_teleport_locs()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station) || istype(AR, /area/wizard_station))
			continue
		if(teleportlocs.Find(AR.name)) .
			continue
		var/turf/picked = pick_area_turf(AR.type, list(/proc/is_station_turf))
		if(picked)
			teleportlocs += AR.name
			teleportlocs[AR.name] = AR
	teleportlocs = sortAssoc(teleportlocs)

/proc/setup_ghost_teleport_locs()
	for(var/area/AR in world)
		if(!AR.x)
			continue
		if(ghostteleportlocs.Find(AR.name))
			continue
		var/turf/picked = pick_area_turf(AR.type)
		if(picked)
			ghostteleportlocs[AR.name] = AR
	ghostteleportlocs = sortAssoc(ghostteleportlocs)

/proc/load_whitelists()
	if(config.usewhitelist)
		load_whitelist()
	if(config.usealienwhitelist)
		if(config.usealienwhitelistSQL)
			if(!load_alienwhitelistSQL())
				world.log << "Could not load alienwhitelist via SQL"
		else
			load_alienwhitelist()

/proc/populate_gear_list()
	for(var/geartype in typesof(/datum/gear)-/datum/gear)
		var/datum/gear/G = geartype
		var/use_name = initial(G.display_name)
		var/use_category = initial(G.sort_category)

		if(!loadout_categories[use_category])
			loadout_categories[use_category] = new/datum/loadout_category(use_category)
		var/datum/loadout_category/LC = loadout_categories[use_category]
		gear_datums[use_name] = new geartype
		LC.gear[use_name] = gear_datums[use_name]

	loadout_categories = sortAssoc(loadout_categories)
	for(var/loadout_category in loadout_categories)
		var/datum/loadout_category/LC = loadout_categories[loadout_category]
		LC.gear = sortAssoc(LC.gear)

/proc/load_custom_items()
	var/datum/custom_item/current_data
	for(var/line in splittext(file2text("config/custom_items.txt"), "\n"))
		line = trim(line)
		if(line == "" || !line || findtext(line, "#", 1, 2))
			continue
		if(findtext(line, "{", 1, 2) || findtext(line, "}", 1, 2)) // New block!
			if(current_data && current_data.assoc_key)
				if(!custom_items[current_data.assoc_key])
					custom_items[current_data.assoc_key] = list()
				var/list/L = custom_items[current_data.assoc_key]
				L |= current_data
			current_data = null
		var/split = findtext(line,":")
		if(!split)
			continue
		var/field = trim(copytext(line,1,split))
		var/field_data = trim(copytext(line,(split+1)))
		if(!field || !field_data)
			continue
		if(!current_data)
			current_data = new()
		switch(field)
			if("ckey")
				current_data.assoc_key = lowertext(field_data)
			if("character_name")
				current_data.character_name = lowertext(field_data)
			if("item_path")
				current_data.item_path = text2path(field_data)
			if("item_name")
				current_data.name = field_data
			if("item_icon")
				current_data.item_icon = field_data
			if("inherit_inhands")
				current_data.inherit_inhands = text2num(field_data)
			if("item_desc")
				current_data.item_desc = field_data
			if("req_access")
				current_data.req_access = text2num(field_data)
			if("req_titles")
				current_data.req_titles = splittext(field_data,", ")
			if("kit_name")
				current_data.kit_name = field_data
			if("kit_desc")
				current_data.kit_desc = field_data
			if("kit_icon")
				current_data.kit_icon = field_data
			if("additional_data")
				current_data.additional_data = field_data

/proc/populate_gender_datum_list()
	for(var/type in typesof(/datum/gender))
		var/datum/gender/G = new type
		gender_datums[G.key] = G

/proc/pai_controller_setup()
	paiController = new/datum/paiController()

/proc/populate_pai_software_list()
	for(var/type in typesof(/datum/pai_software) - /datum/pai_software)
		var/datum/pai_software/P = new type()
		if(pai_software_by_key[P.id])
			var/datum/pai_software/O = pai_software_by_key[P.id]
			world << "<span class='warning'>pAI software module [P.name] has the same key as [O.name]!</span>"
			continue
		pai_software_by_key[P.id] = P
		if(P.default)
			default_pai_software[P.id] = P

/proc/load_robot_custom_sprites()
	var/config_file = file2text("config/custom_sprites.txt")
	var/list/lines = splittext(config_file, "\n")
	robot_custom_icons = list()
	for(var/line in lines)
		var/split_idx = findtext(line, "-") //this works if ckey cannot contain dashes, and findtext starts from the beginning
		if(!split_idx || split_idx == length(line))
			continue //bad entry
		var/ckey = copytext(line, 1, split_idx)
		var/real_name = copytext(line, split_idx+1)
		robot_custom_icons[ckey] = real_name

/proc/build_map()
	if(!config.use_overmap)
		return 1
	testing("Building overmap...")
	var/obj/effect/mapinfo/data
	for(var/level in 1 to world.maxz)
		data = locate("sector[level]")
		if(data)
			testing("Located sector \"[data.name]\" at [data.mapx],[data.mapy] corresponding to zlevel [level]")
			map_sectors["[level]"] = new data.obj_type(data)

/proc/randomise_antigens_order()
	ALL_ANTIGENS = shuffle(ALL_ANTIGENS)

/proc/initialise_map_list()
	for(var/type in typesof(/datum/map) - /datum/map)
		var/datum/map/M
		if(type == using_map.type)
			M = using_map
			M.setup_map()
		else
			M = new type
		if(!M.path)
			world << "<span class=danger>Map '[M]' does not have a defined path, not adding to map list!</span>"
			world.log << "Map '[M]' does not have a defined path, not adding to map list!"
		else
			all_maps[M.path] = M
	return 1
