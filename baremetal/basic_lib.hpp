#include "config.hpp"

typedef unsigned int size_t;
typedef char int8_t;
typedef short int int16_t;
typedef int int32_t;
typedef long long int int64_t;
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long int uint64_t;

int stack_check(void);

//void delay(int n);
void timer_wait(long int ticks);

void bitbang_uart_tx(char c);
const char *hexstr(int a);
void print(const char *str);

static int inline get_mtime() {
	return *(volatile long int *)TIMER_ADDR;
}

void *memcpy(void *dest, const void *src, size_t n);
void *memset(void *s, int c, size_t n);

#ifdef INCLUDE_IRQ
static inline void enable_irq(void) {
    __asm__ volatile ("csrrs    zero, mstatus, 0x8"); //MIE
}
static inline void disable_irq(void) {
    __asm__ volatile ("csrrc    zero, mstatus, 0x8"); //MIE
}

static inline void enable_timer_irq(void) {
	int v = 0x80;
    __asm__ volatile ("csrrs    zero, mie, %0"::"r"(v)); //MTIE
}
static inline void disable_timer_irq(void) {
	int v = 0x80;
    __asm__ volatile ("csrrc    zero, mie, %0"::"r"(v)); //MTIE
}

static inline int read_mcause(void) {
    int v;        
    __asm__ volatile ("csrr    %0, mcause"  : "=r" (v) );
    return v;
}
void set_direct_isr(void (*timer_callback)(void));
#endif
