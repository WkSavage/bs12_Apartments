#define AALARM_MODE_SCRUBBING    1
#define AALARM_MODE_REPLACEMENT  2 // like scrubbing, but faster.
#define AALARM_MODE_PANIC        3 // constantly sucks all air
#define AALARM_MODE_CYCLE        4 // sucks off all air, then refill and switches to scrubbing
#define AALARM_MODE_FILL         5 // emergency fill
#define AALARM_MODE_OFF          6 // shuts it all down.

#define AALARM_SCREEN_MAIN       1
#define AALARM_SCREEN_VENT       2
#define AALARM_SCREEN_SCRUB      3
#define AALARM_SCREEN_MODE       4
#define AALARM_SCREEN_SENSORS    5

#define AALARM_REPORT_TIMEOUT    100

#define RCON_NO    1
#define RCON_AUTO  2
#define RCON_YES   3

#define MAX_TEMPERATURE 90
#define MIN_TEMPERATURE -40