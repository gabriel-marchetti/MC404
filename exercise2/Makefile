*.c: *.s
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax *.c -S -o *.s
*.o: *.s
	clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax *.s -c .o *.o 

