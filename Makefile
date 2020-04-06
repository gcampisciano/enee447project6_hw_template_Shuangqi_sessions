ARMGNU = arm-none-eabi

TARGET = kernel7.bin
SDTARGET = things_to_copy_to_your_sd_card/kernel7.img
DEPS = *.h

COPS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding

good: BOOT_S=good 
good: $(TARGET).$(BOOT_S)

multi: BOOT_S=multi 
multi: $(TARGET).$(BOOT_S)

stacks: BOOT_S=stacks 
stacks:$(TARGET).$(BOOT_S)

%.o : %.s
	$(ARMGNU)-as $< -o $@

%.o : %.c $(DEPS)
	$(ARMGNU)-gcc $(COPS) -c $< -o $@

OBJECTS := $(patsubst %.s,%.o,$(wildcard *.s)) $(patsubst %.c,%.o,$(wildcard *.c))

$(TARGET).$(BOOT_S): $(OBJECTS)
	make kversion
	$(ARMGNU)-as 1_boot.$(BOOT_S) -o 1_boot.o
	$(ARMGNU)-ld $(OBJECTS) 1_boot.o threads.o -T memmap -o kernel7.elf
	$(ARMGNU)-objdump -D kernel7.elf > kernel7.list
	$(ARMGNU)-objcopy kernel7.elf -O binary $(TARGET)
	cp $(TARGET) $(SDTARGET)
	cp $(TARGET) $(TARGET).$(BOOT_S)

kversion :
	echo char kversion\[\] = \"Kernel version: \[`basename \`pwd\``\, `date`\]\"\; > kversion.c
	$(ARMGNU)-gcc $(COPS) -c kversion.c -o kversion.o

clean :
	rm -f $(OBJECTS)
	rm -f *.bin
	rm -f *.elf
	rm -f *.list
	rm -f *.auto
	rm -f **/*.img
	rm -f $(TARGET).*
