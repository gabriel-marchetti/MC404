char input_buffer[10];
extern int read(int, const void*, int);

int main()
{
  int n = read(0, (void*) input_buffer, 10);

  return 0;
}
