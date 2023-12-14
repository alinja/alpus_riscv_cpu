#define INCLUDE_IRQ
//#define INCLUDE_MEMCPY

//SERV/Servant
//#define GPIO_ADDR 0x40000000
//#define TIMER_ADDR 0x80000000
//#define TICKS_PER_MS 125000

//VexRiscV ex
#define GPIO_ADDR  0x80000000
#define TIMER_ADDR 0x80000004
#define TICKS_PER_MS 125000

#define INCLUDE_STACK_CHECK
#define STACK_CHECK_STACK_SIZE 128 // words
#define STACK_CHECK_MAGIC      0xfeedbeef
