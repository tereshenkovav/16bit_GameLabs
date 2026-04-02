#include "..\include\lib16bit.h"

void main() {
  setScreen(0x13) ;

  int x = 100 ;
  int y = 100 ;
  int dx = 2 ;
  int dy = 2 ;

  const SZ = 32 ;

  char key,code ;

  while (isKeyPressed(&key,&code)==0) {
    // Render
    clearScreen() ;
    drawLineHorzByLen(x,y,SZ,10) ;
    drawLineHorzByLen(x,y+SZ-1,SZ,11) ;
    drawLineVertByLen(x,y,SZ,12) ;
    drawLineVertByLen(x+SZ-1,y,SZ,14) ;

    // Update
    x+=dx ;
    y+=dy ;
    if (x<=0) dx=-dx ;
    if (x>=320-SZ-1) dx=-dx ; 
    if (y<=0) dy=-dy ;
    if (y>=200-SZ-1) dy=-dy ; 

    // Wait timer (18FPS)
    int t = getTimer() ;
    while (t==getTimer()) { } ;
  }

  setScreen(0x3) ;
}
