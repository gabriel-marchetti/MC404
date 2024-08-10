FLAGS=--target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax
main.s: main.c
	clang $(FLAGS) -S main.c -o main.s
read.s: read.c
	clang $(FLAGS) -S read.c -o read.s
start.s: start.c
	clang $(FLAGS) -S start.c -o start.s 
main.o: main.s
	clang $(FLAGS) -c main.s -o main.o
read.o: read.s
	clang $(FLAGS) -c read.s -o read.o
start.o: start.s
	clang $(FLAGS) -c start.s -o start.o
prog.x: start.o read.o main.o
	ld.lld start.o read.o main.o -o prog.x
run:
	make prog.x
clean:
	rm *.s *.o *.x 
