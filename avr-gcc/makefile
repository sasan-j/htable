#simulavr -d atmega128 -f runaes.elf -W 0x20,- -R 0x22,- -T exit

#microcontroller type for example atmega8
mcu = atmega128

AESOBJ = aes.o aes_rp.o share.o aes_share.o aes_htable.o runaes.o common.o share_asm.S aes_htable_asm.S
#AESOBJ_norm = aes.o aes_rp.o share.o aes_share.o aes_htable.o runaes_normal.o common.o


all : runaes.elf

runaes.elf : $(AESOBJ)
	avr-gcc -Wa,--gstabs -Wall -mmcu=$(mcu) -O3 -o $@ $(AESOBJ)


#runaes_normal.out : $(AESOBJ_norm)
#        avr-gcc -g -mmcu=$(mcu) -Os -o runaes_normal.out $(AESOBJ_norm)

%.o: %.c 
	avr-gcc -Wa,--gstabs -Wall  -mmcu=$(mcu) -O3 -o $@ -c $<

clean:
	rm -f *.o *.elf
