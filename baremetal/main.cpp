// Example program for led flashing
#include "config.hpp"
#include "basic_lib.hpp"
#include "my_class.hpp"
#include "alintstone.hpp"

#define BLINK_IN_IRQ
#define DO_BENCHMARK

unsigned next_timer = 0x00000123; //Global variables are not initialized!
int irq_counter=0;
my_class _gTest;

int led_invert;

static void inline led_set()
{
	if(led_invert)
		*(volatile long int *)(GPIO2_ADDR+8) = 0x00000001; //clear
	else
		*(volatile long int *)(GPIO2_ADDR+4) = 0x00000001; //set
}

static void inline led_clr()
{
	if(led_invert)
		*(volatile long int *)(GPIO2_ADDR+4) = 0x00000001; //set
	else
		*(volatile long int *)(GPIO2_ADDR+8) = 0x00000001; //clear
}

void timer_callback(void)
{
#ifdef BLINK_IN_IRQ
	if(irq_counter&0x01) {
		// blink if magic number from constructor matches
		if(_gTest.get_val() == 0x11223344)
			led_set();
		else
			led_clr();
		next_timer += 50*TICKS_PER_MS;
	} else {
		led_clr();
		next_timer += 450*TICKS_PER_MS;
	}
#else
	next_timer += 1000*TICKS_PER_MS;
#endif
	
	*(volatile long int *)TIMER_ADDR = next_timer;
	irq_counter++;
}
#ifdef DO_BENCHMARK
void run_benchmark(void)
{
	print("Starting benchmark\n\r");
	unsigned int us = 0;

	unsigned int timer0 = get_mtime();
	int call_counter = alintstone();
	unsigned int timer1 = get_mtime();
	us += ((uint64_t)(timer1-timer0)*(1000*65536/TICKS_PER_MS)) / 65536;
	
	print("Call counter: ");
	print(hexstr(call_counter));
	print("\n\r");
	
	print("Benchmark result (us): ");
	print(hexstr(us));
	print("\n\r");
	print(hexstr(irq_counter));
	print("\n\r");
	print(hexstr(get_mtime()));
	print("\n\r");
}
#endif

void run_stack_check(void)
{
#ifdef INCLUDE_STACK_CHECK
	print("Stack free: ");
	print(hexstr(stack_check()));
	print("\n\r");
#endif
}

int main(void)
{
	// Blink once at boot
	led_invert = *(volatile long int *)GPIO_ADDR >> 31; // read board setting
	*(volatile long int *)(GPIO2_ADDR+16) |= 0x00000001; //oen/dir
	led_set();
	timer_wait(500*TICKS_PER_MS);
	led_clr();
	timer_wait(2000*TICKS_PER_MS);

	run_stack_check();
	//_gTest.set_val(0);
	
#ifdef INCLUDE_IRQ
	// Initialize timer irq callback - irq vector is always pointing to static isr
	next_timer = 0;
	*(volatile long int *)TIMER_ADDR = next_timer;
	set_direct_isr(&timer_callback);
	enable_irq();
	enable_timer_irq();
#endif

	while(1) {
		// blink led
#ifndef BLINK_IN_IRQ
		led_set();
		timer_wait(100*TICKS_PER_MS);
		led_clr();
		timer_wait(1900*TICKS_PER_MS);
#endif

		//print("Debugging message at 9600 baud from SERV CPU!\n\r");
#ifdef DO_BENCHMARK
		run_benchmark();
#endif
		run_stack_check();
	}
}
