#include <bits/stdc++.h>
using namespace std;

int square_root(int number){
  int guess = number / 2;

  for(int i = 0; i < 21; i++){
    guess = guess + number/guess;
    guess /= 2;
  }

  return guess;
}

int main(){
  int Yb, Xc, Ta, Tb, Tc, Tr;
  cin >> Yb >> Xc >> Ta >> Tb >> Tc >> Tr;
  cout << "Yb: " << Yb << '\n';
  cout << "Xc: " << Xc << '\n';
  cout << "Ta: " << Ta << '\n';
  cout << "Tb: " << Tb << '\n';
  cout << "Tc: " << Tc << '\n';
  cout << "Tr: " << Tr << '\n';

  int da, db, dc;
  da = ((Tr-Ta) * 3) / 10;
  db = ((Tr-Tb) * 3) / 10;
  dc = ((Tr-Tc) * 3) / 10;
  int x, y;
  y = (da * da + Yb * Yb - db * db) / (2 * Yb); 
  int x1, x2; 
  x1 = square_root(da * da - y * y);
  x2 = -x1;

  int condition1, condition2;
  condition1 = (x1 - Xc)*(x1 - Xc) + y * y - dc * dc;
  condition2 = (x2 - Xc)*(x2 - Xc) + y * y - dc * dc; 
  x = (condition1 < condition2) ? x1 : x2;

  printf("%4d %4d\n", x, y);

  return 0;
}
