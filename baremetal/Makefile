# Simple makefile base for minimal baremetal builds for serv risc-v cpu core
PREFIX=riscv64-unknown-elf-
CC=$(PREFIX)g++
OBJCOPY=$(PREFIX)objcopy

CFLAGS=-march=rv32i -mabi=ilp32 -O2
LDFLAGS=-ffreestanding -nostdlib -march=rv32i -mabi=ilp32

OBJS = crt0.o basic_lib.o my_class.o alintstone.o main.o

all:	image.bin

%.o: %.cpp *.hpp
	$(CC) -c $(CFLAGS) -o $@ $<

crt0.o: crt0.S
	$(CC) -c $(CFLAGS) -o $@ $<

image.elf: $(OBJS) link.ld
	$(CC) $(LDFLAGS) -Tlink.ld -o image.elf $(OBJS)

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@
	#python3 makehex.py $@ > image.hex
	python3 makevhdl.py $@ firmware_mem > firmware_mem_pkg.vhd
	#python3 makehex4.py $@

clean:
	rm -f *.o *.bin *.elf *.hex *.hex?
