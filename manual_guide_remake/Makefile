FLAGS=--target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax
prog.s: prog.c
	clang $(FLAGS) -S prog.c -o prog.s
prog.o: prog.s
	clang $(FLAGS) -c prog.s -o prog.o
prog.x: prog.o
	ld.lld prog.o -o prog.x
run:
	make prog.x
clean:
	rm prog.s prog.o prog.x
