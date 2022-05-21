nasm  -I include -o loader.bin loader.S 
nasm  -I include -o mbr.bin mbr.S
dd if=/home/return/Desktop/Project/boot/mbr.bin \
of=/home/return/Desktop/Project/bochs/hd64M.img \
bs=512 count=1 conv=notrunc

dd if=/home/return/Desktop/Project/boot/loader.bin \
of=/home/return/Desktop/Project/bochs/hd64M.img \
bs=512 count=3 seek=2 conv=notrunc

bin/bochs -f bochsrc.disk

gcc -m32 -I lib/kernel/ -c -o lib/kernel/main.o lib/kernel/main.c



nasm -f elf -o lib/kernel/print.o lib/kernel/print.S
//这里开始
gcc -m32 -I lib/kernel -c -o build/timer.o device/timer.c

gcc -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-builtin \
-o build/main.o kernel/main.c

nasm -f elf -o build/print.o lib/kernel/print.S
nasm -f elf -o build/kernel.o kernel/kernel.S

gcc -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-builtin \
-o build/interrupt.o kernel/interrupt.c

gcc -m32 -I lib/kernel/ -I lib/ -I kernel/ -c -fno-builtin \
-o build/init.o kernel/init.c

ld -m elf_i386 -Ttext 0xc0001500 -e main -o build/kernel.bin \
build/main.o build/init.o build/interrupt.o build/print.o build/kernel.o \
build/timer.o 

dd if=/home/return/Desktop/Project/build/kernel.bin \
of=/home/return/Desktop/Project/bochs/hd64M.img \
bs=512 count=200 seek=9 conv=notrunc

0xc0101D98

18665011


21816237