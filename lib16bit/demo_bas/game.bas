$LINK "lib16bit.obj"
$INCLUDE "lib16bit.bi"
DEFINT A-Z

CALL setScreen(19)

x = 100
y = 100
dx = 2
dy = 2

SZ = 32

WHILE INKEY$=""
  ' Render
  CALL clearScreen()
  CALL drawLineHorzByLen(x,y,SZ,10)
  CALL drawLineHorzByLen(x,y+SZ-1,SZ,11)
  CALL drawLineVertByLen(x,y,SZ,12)
  CALL drawLineVertByLen(x+SZ-1,y,SZ,14)

  ' Update
  INCR x,dx
  INCR y,dy
  IF x<=0 THEN dx=-dx
  IF x>=320-SZ-1 THEN dx=-dx
  IF y<=0 THEN dy=-dy
  IF y>=200-SZ-1 THEN dy=-dy

  ' Wait timer (18FPS)
  t = getTimer()
  WHILE t=getTimer() : WEND
WEND

CALL setScreen(3)
