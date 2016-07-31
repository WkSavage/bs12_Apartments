#define TICK_LIMIT_RUNNING 85
#define TICK_LIMIT_TO_RUN 80
#define TICK_LIMIT_MC 84
#define TICK_LIMIT_MC_INIT 90


#define CHECK_TICK if (world.tick_usage > TICK_LIMIT_RUNNING)  stoplag()
#define CHECK_TICK_MC if (world.tick_usage > TICK_LIMIT_MC)  stoplag()
#define CHECK_TICK_MC_INIT if (world.tick_usage > TICK_LIMIT_MC_INIT)  stoplag()