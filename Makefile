BASIC=Makefile

all: $(BASIC) bootstrap.iso

bootstrap.iso: $(BASIC) bootstrap.bin cdiso/bootstrap.vfd
	dd status=noxfer conv=notrunc if=bootstrap.bin of=cdiso/bootstrap.vfd
	mkisofs -o bootstrap.iso -b bootstrap.vfd cdiso/

bootstrap.bin: $(BASIC) bootstrap_vga.asm
	nasm -f bin -o bootstrap.bin bootstrap_vga.asm

cdiso/bootstrap.vfd: $(BASIC)
	mkdir -p cdiso
	rm -f cdiso/bootstrap.vfd
	mkfs.vfat -C cdiso/bootstrap.vfd 1440

bootstrap2.bin: $(BASIC) bootstrap2.asm bootstrap2.ld
	nasm -f elf32 bootstrap2.asm -o bootstrap2.o
	mkdir -p isodir/boot
	ld -melf_i386 -T bootstrap2.ld bootstrap2.o -o isodir/boot/bootstrap2.bin
	grub-mkrescue -o bootstrap2.iso --verbose isodir

clean:
	rm -f *.bin *.iso cdiso/*.vfd *.o rm -r isodir/boot/*.bin
