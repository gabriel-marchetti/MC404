/* write
 * Parameters:
 * __fd: file descriptor where we will write code.
 * __buf: buffer with the data we want to write.
 * __n: amount of bytes to be written.
 * Return:
 *  Number of bytes effectively written.
 */
void write(int __fd, const void *__buf, int __n){
  __asm__ __volatile__(
    "mv a0, %0  # file descriptor\n"
    "mv a1, %1  # buffer\n"
    "mv a2, %2  # size\n"
    "li a7, 64  # syscall write (64)\n"
    "ecall"
    : // Output List
    :"r"(__fd), "r"(__buf), "r"(__n)
    :"a0", "a1", "a2", "a7"
  );
}
