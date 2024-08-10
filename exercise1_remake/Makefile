FLAGS=--target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax
file1.s: file1.c
	clang $(FLAGS) file1.c -S -o file1.s
file2.s: file1.c
	clang $(FLAGS) file2.c -S -o file2.s
file1.o: file1.s
	clang $(FLAGS) file1.s -c -o file1.o
file2.o: file2.s
	clang $(FLAGS) file2.s -c -o file2.o
prog.x: file1.o file2.o
	ld.lld file1.o file2.o -o prog.x
run:
	make prog.x
clean:
	rm *.s *.o *.x
