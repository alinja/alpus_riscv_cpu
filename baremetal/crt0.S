#include "config.hpp"

	.global _start
	.global __irq_vector

	.text
_start:
	/* init stack */
	la sp, _stack_end
	
	/* Direct interrupt vec base */
#ifdef INCLUDE_IRQ
	li t0, %lo(__irq_vector)
	csrw    mtvec, t0 //vex has fixed 0x14!!!
#endif
	
	tail _Z9__startupv

#ifdef INCLUDE_IRQ
__irq_vector:
	j _Z12__direct_isrv
#endif
