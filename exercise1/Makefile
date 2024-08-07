file1.s: file1.c
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax file1.c -S -o file1.s
file2.s: file2.c
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax file2.c -S -o file2.s
file1.o: file1.s
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax file1.s -c -o file1.o
file2.o: file2.s
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax file2.s -c -o file2.o
file.x: file1.o file2.o
	make file1.o
	make file2.o
	ld.lld file1.o file2.o -o prog.x
clean:
	rm *.s *.o *.x
