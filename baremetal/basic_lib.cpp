#include "config.hpp"
#include "basic_lib.hpp"

int main(void);

typedef void (*fptr_t)(void);
extern fptr_t __init_array_start[0], __init_array_end[0];


#ifdef INCLUDE_STACK_CHECK
extern int _stack_end;
void inline __stack_check_init(void)
{
	for(int *p = &_stack_end - STACK_CHECK_STACK_SIZE; p < &_stack_end - 16; p++) {
		*p = STACK_CHECK_MAGIC;
	}
}

int stack_check(void)
{
	int free = 0;
	for(int *p = &_stack_end - STACK_CHECK_STACK_SIZE; p < &_stack_end - 16; p++) {
		if(*p == STACK_CHECK_MAGIC) {
			free++;
		} else {
			break;
		}
	}
	return free;
}
#endif

void __startup(void)
{
#define BUS_TEST_IN_SIM
#ifdef BUS_TEST_IN_SIM
	int a,b;
	*(volatile int *)(0x3000+0) = 0xc0000003;
	a = *(volatile int *)(0x3000+0) ;
	*(volatile char *)(0x3000+0) = 0x01;
	*(volatile char *)(0x3000+1) = 0x02;
	*(volatile char *)(0x3000+2) = 0x03;
	*(volatile char *)(0x3000+3) = 0x04;

	a = *(volatile char *)(0x3000+0) ;
	a = *(volatile char *)(0x3000+1); 
	a = *(volatile char *)(0x3000+2); 
	a = *(volatile char *)(0x3000+3) ;
	a = *(volatile int *)(0x3000+0) ;
	*(volatile short *)(0x3000+0) = 0x0001;
	*(volatile short *)(0x3000+2) = 0x0002;
	
	a = *(volatile int *)(0x3000+0) ;
	a = *(volatile short *)(0x3000+0);
	a = *(volatile short *)(0x3000+2);

	*(volatile long int *)GPIO_ADDR = 0x00000001;
	*(volatile int *)(0x3000+0) = 0xc0000003;
	*(volatile long int *)GPIO_ADDR = 0x00000001;
	a = *(volatile int *)(0x3000+0) ;
	b = *(volatile long int *)GPIO_ADDR;
	*(volatile int *)(0x3000+0) = 0xc0000003;
	b = *(volatile long int *)GPIO_ADDR;
	a = *(volatile int *)(0x3000+0) ;
	*(volatile long int *)GPIO2_ADDR = 0x00000002;
	*(volatile long int *)GPIO2_ADDR = 0x00000003;
	b = *(volatile long int *)GPIO2_ADDR;
	b = *(volatile long int *)GPIO2_ADDR;
#endif
	
#ifdef INCLUDE_STACK_CHECK
	__stack_check_init();
#endif
	//TODO: clear globals
	
	//TODO: init value for globals
	
	//call constructors
	for(fptr_t *p = __init_array_start; p != __init_array_end; p++) {
		(**p)();
	}
	
	main();

	for(;;);
}

#ifdef INCLUDE_MEMCPY
static inline void __mem_common(char *dest, const char *src, size_t n, size_t inc)
{
	for(int i=0; i<n; i++) {
		*dest = *src;
		dest += 1;		
		src += inc;		
	}
}	

void *memcpy(void *dest, const void *src, size_t n)
{
	__mem_common((char *)dest, (char *)src, n, 1);
	return dest;
}

void *memset(void *s, int c, size_t n)
{
	char src = c;
	__mem_common((char *)s, &src, n, 0);
	return s;
}
#endif

#ifdef INCLUDE_IRQ

void (*__timer_callback)(void) = 0;

// Fixed isr, intialized by crt0.S
void __direct_isr(void) __attribute__ ((interrupt ("machine")));
void __direct_isr(void)
{
	// SERV supports only timer irqs
	int mcause = read_mcause();
	if(mcause == 0x80000007)
		if(__timer_callback)
			(*__timer_callback)();
}

void set_direct_isr(void (*timer_callback)(void))
{
	__timer_callback = timer_callback;
}
#endif



/*void __attribute__ ((noinline)) delay(int n)
{
	for(int i=0; i<n; i++) asm("");
}*/

void timer_wait(long int ticks)
{
	long int timer0 = get_mtime();
	
	while(1) {
		long int timer1 = get_mtime();
		if(timer1 - timer0 > ticks) break;
	}
}
void timer_wait_for_mtime(long int mtime)
{
	while(1) {
		long int timer1 = get_mtime();
		if(timer1 - mtime > 0) break;
	}
}

static void __bitbang_uart_tx_setbit(int bit)
{
	if(bit)
		*(volatile long int *)(GPIO2_ADDR+4) = 0x00000002; //set
	else
		*(volatile long int *)(GPIO2_ADDR+8) = 0x00000002; //clear
}

//9600 baud for debugging
void bitbang_uart_tx(char c)
{
	int bitdelay = TICKS_PER_MS*1000/9600;
	*(volatile long int *)(GPIO2_ADDR+16) |= 0x00000002; //oen/dir

	long int mtime0 = get_mtime();

	__bitbang_uart_tx_setbit(0); //start bit 
	mtime0 += bitdelay;
	timer_wait_for_mtime(mtime0);

	char mask=0x01;
	for(int i=0; i<8; i++) { 
		__bitbang_uart_tx_setbit(c & mask); //data0-7
		mask += mask; //shift
		mtime0 += bitdelay;
		timer_wait_for_mtime(mtime0);
	}

	__bitbang_uart_tx_setbit(1); //stop bit
	mtime0 += bitdelay;
	timer_wait_for_mtime(mtime0);
}

const char __hex_lookup[] = "0123456789abcdef";
char __static_hex_str[9];

const char *hexstr(int a)
{
	for(int i=7; i >= 0; i--) {
		__static_hex_str[i] = __hex_lookup[a & 0x000000f];
		//__static_hex_str[i] = a & 0x000000f;
		a >>= 4;
	}
	__static_hex_str[8]=0;
	return __static_hex_str;
}

void print(const char *str)
{
	while(*str) {
		bitbang_uart_tx(*str);
		str++;
	}
}

