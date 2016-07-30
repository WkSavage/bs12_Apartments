#define TICK_LIMIT_RUNNING 85
#define TICK_LIMIT_TO_RUN 80

#define CHECK_TICK if (world.tick_usage > CURRENT_TICKLIMIT)  stoplag()