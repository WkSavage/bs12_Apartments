
//list(ckey = real_name,)
//Since the ckey is used as the icon_state, the current system will only permit a single custom robot sprite per ckey.
//While it might be possible for a ckey to use that custom sprite for several real_names, it seems rather pointless to support it.
var/list/robot_custom_icons

/mob/living/silicon/robot/proc/set_custom_sprite()
	var/rname = robot_custom_icons[ckey]
	if(rname && rname == real_name)
		custom_sprite = 1
		icon = CUSTOM_ITEM_SYNTH
		var/list/valid_states = icon_states(icon)
		if(icon_state == "robot")
			if("[ckey]-Standard" in valid_states)
				icon_state = "[ckey]-Standard"
			else
				src << "<span class='warning'>Could not locate [ckey]-Standard sprite.</span>"
				icon =  'icons/mob/robots.dmi'
