#define TICK_LIMIT_PRE
#define TICK_LIMIT_RUNNING 85
#define TICK_LIMIT_MC_INIT 90


#define CHECK_TICK if(world.tick_usage > TICK_LIMIT_RUNNING)  stoplag()
#define CHECK_PRE_TICK if(world.tick_usage > TICK_LIMIT_PRE)  stoplag()
#define CHECK_TICK_MC_INIT if(world.tick_usage > TICK_LIMIT_MC_INIT)  stoplag()