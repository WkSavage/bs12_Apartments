// Standardized medthod for tracking startup times.
/proc/log_red(var/message)
	admin_notice("<span class='danger'>[message]</span>")
	log_to_dd(message)

/proc/log_blue(var/message)
	admin_notice("<B><FONT color='blue'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_green(var/message)
	admin_notice("<B><FONT color='green'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_black(var/message)
	admin_notice("<B><FONT color='black'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_purple(var/message)
	admin_notice("<B><FONT color='purple'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_yellow(var/message)
	admin_notice("<B><FONT color='yellow'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_orange(var/message)
	admin_notice("<B><font color='#FFA500'>[message]</FONT></B>")
	log_to_dd(message)

/proc/log_to_debug(var/message)
	log_to_dd(message)