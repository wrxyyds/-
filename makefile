.PHONY: build burn clean
#build文件夹存放可执行文件和目标文件
mbr_source = ./boot/mbr.s
mbr_target = ./build/mbr.bin

loader_source = ./boot/load.s
loader_target = ./build/load.bin

main_source = ./kernel/main.c
main_object = ./build/main.0
main_target = ./build/main.bin

hard_disk = ../hd60M.img

putchar_source = ./lib/kernel/print.s
putchar_object = ./lib/build/print.o

clean:
	rm -rf ./build/*.bin
	rm -rf ./build/*.o

build_boot:   #編譯器編譯intel彙編
	nasm $(mbr_source) -o $(mbr_target) -I ./boot/include/
	nasm $(loader_source) -o $(loader_target) -I ./boot/include/

burn_boot:  #將boot的機器碼送入磁盤
	dd if=$(mbr_target) of=$(hard_disk) bs=512 count=1 conv=notrunc
	dd if=$(loader_target) of=$(hard_disk) bs=512 count=4 conv=notrunc seek=2  

build_kernel:  #編譯內核文件
	gcc-4.4 -o $(main_object) -c -m32 -I lib/kernel/ $(main_source)  
	nasm -f elf -o build/print.o lib/kernel/print.s
	ld -m elf_i386 -Ttext 0x00001500 -e main -o $(main_target)  $(main_object) build/print.o

burn_kernel:   #將內核送入磁盤
	dd if=$(main_target) of=$(hard_disk) bs=512 count=200 conv=notrunc seek=9


#--------------------------------------------------------------------------------------------------------
build:
	make build_boot
	make build_kernel

burn:
	make burn_boot
	make burn_kernel
