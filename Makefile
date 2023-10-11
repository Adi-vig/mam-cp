run:
	./asm_game

obj:
	nasm -felf64 graphics.asm    -o obj/graphics.o
	nasm -felf64 linked_list.asm -o obj/linked_list.o
	nasm -felf64 main.asm        -o obj/main.o
	nasm -felf64 memory.asm 	 -o obj/memory.o
	nasm -felf64 utils.asm 		 -o obj/utils.o

	
link:
	ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 obj/graphics.o obj/linked_list.o obj/main.o obj/memory.o obj/utils.o  -o asm_game  -lX11 
	

all:
	nasm -felf64 graphics.asm    -o obj/graphics.o
	nasm -felf64 linked_list.asm -o obj/linked_list.o
	nasm -felf64 main.asm        -o obj/main.o
	nasm -felf64 memory.asm 	 -o obj/memory.o
	nasm -felf64 utils.asm 		 -o obj/utils.o

	ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 obj/graphics.o obj/linked_list.o obj/main.o obj/memory.o obj/utils.o  -o asm_game  -lX11 

	./asm_game


