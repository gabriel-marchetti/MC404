char input_buffer[6];
char output_buffer[2];
extern int read(int, const void*, int);
extern void write(int, const void*, int);

char calculation(char s1, char s2, char op){
  char result;
  switch (op) {
    case '+':
      result = (s1 - 48) + (s2 - 48) + 48;
      break;   
    case '-':
      result = (s1 - 48) - (s2 - 48) + 48;
      break;
    case '*':
      result = (s1 - 48) * (s2 - 48) + 48;
      break;
    default:
      result = '0';
      break;
  }
  return result;
}

int main()
{
  char s1, s2, op;
  int n = read(0, input_buffer, 6); // Expecting the '\n' character.
  s1 = input_buffer[0]; s2 = input_buffer[4]; op = input_buffer[2];

  output_buffer[0] = calculation(s1, s2, op);
  output_buffer[1] = '\n';
  write(1, (void *) output_buffer, 2);

  return 0;
}
