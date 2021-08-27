BASIC=Makefile

all: $(BASIC) bootstrap.iso

bootstrap.iso: $(BASIC) bootstrap.bin cdiso/bootstrap.flp
	dd status=noxfer conv=notrunc if=bootstrap.bin of=cdiso/bootstrap.flp
	mkisofs -o bootstrap.iso -b bootstrap.flp cdiso/

bootstrap.bin: $(BASIC) bootstrap_vga.asm
	nasm -f bin -o bootstrap.bin bootstrap_vga.asm

cdiso/bootstrap.flp: $(BASIC)
	mkdir -p cdiso
	rm -f cdiso/bootstrap.flp
	mkfs.vfat -C cdiso/bootstrap.flp 1440

bootstrap2.bin: $(BASIC) bootstrap2.asm bootstrap2.ld
	nasm -f elf32 bootstrap2.asm -o bootstrap2.o
	mkdir -p isodir/boot
	ld -melf_i386 -T bootstrap2.ld bootstrap2.o -o isodir/boot/bootstrap2.bin
	grub-mkrescue -o bootstrap2.iso --verbose isodir

clean:
	rm -f *.bin *.iso cdiso/*.flp *.o rm -r isodir/boot/*.bin
