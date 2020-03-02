#
#
# Makefile for 512-byte games
#
#

all: os

dirs:
	mkdir -p bin

.PHONY: os run clean

os: dirs
	nasm -f bin -o bin/main.bin src/main.asm
	dd status=noxfer conv=notrunc if=bin/main.bin of=bin/os.flp

run: os
	qemu-system-i386 -fda bin/os.flp
clean:
	rm -rf bin
