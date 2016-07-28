// Standardized medthod for tracking startup times.
/proc/log_startup(var/message)
	admin_notice("<span class='danger'>[message]</span>")
	log_to_dd(message)

// Standardized medthod for tracking controller setups
/proc/log_controller(var/message)
	admin_notice("<span class='danger'>[message]</span>")
	log_to_dd(message)

/proc/log_startup_blue(var/message)
	admin_notice("<B><FONT color='blue'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_startup_green(var/message)
	admin_notice("<B><FONT color='green'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_startup_black(var/message)
	admin_notice("<B><FONT color='black'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_startup_purple(var/message)
	admin_notice("<B><FONT color='purple'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_startup_yellow(var/message)
	admin_notice("<B><FONT color='yellow'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_startup_orange(var/message)
	admin_notice("<B><font color='orange'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_startup_debug(var/message)
	log_to_dd(message)