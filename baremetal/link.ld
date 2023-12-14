OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
    RAM (rwx)  : ORIGIN = 0x00000000, LENGTH = 8192
}

SECTIONS
{
	. = 0x00000000;
	
	.text : {
		*(.text) 
	} > RAM
	
	.data : {
		*(.data)
	} > RAM
	
	.bss : {
		*(.bss)
	} > RAM
	
	.init_array : {
		__init_array_start = .;
		*(.init_array)
		__init_array_end = .;
	} > RAM
	
	_stack_end = ORIGIN(RAM) + LENGTH(RAM);
}
