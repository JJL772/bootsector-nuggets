#
#
# Makefile for 512-byte games
#
#

all: os

dirs:
	mkdir -p bin

os: dirs
	nasm -f bin -o bin/os.bin src/os.asm
	dd status=noxfer conv=notrunc if=bin/os.bin of=bin/os.flp

runos: os
	qemu-system-i386 -fda bin/os.flp
clean:
	rm -rf bin
ray: dirs
	nasm -f bin -o bin/ray.bin src/raytrace.asm
	dd status=noxfer conv=notrunc if=bin/ray.bin of=bin/ray.flp

runray: ray
	qemu-system-i386 -fda bin/ray.flp
