/proc/irc_notify()
	send2mainirc("Server starting up on byond://[config.serverurl ? config.serverurl : (config.server ? config.server : "[world.address]:[world.port]")]")

/proc/connectDB()
	if(!setup_database_connection())
		world.log << "Your server failed to establish a connection with the feedback database."
	else
		world.log << "Feedback database connection established."

/proc/connectOldDB()
	if(!setup_old_database_connection())
		world.log << "Your server failed to establish a connection with the SQL database."
	else
		world.log << "SQL database connection established."
