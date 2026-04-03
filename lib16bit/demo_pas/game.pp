program game ;

uses lib16bit in '..\include\lib16bit.pas' ;

var t,x,y,dx,dy:Integer ;
    key,code:Byte ;
const SZ = 32 ;
begin
  setScreen($13) ;

  x:=100 ;
  y:=100 ;
  dx:=2 ;
  dy:=2 ;

  while (isKeyPressed(key,code)=0) do begin
    // Render
    clearScreen() ;
    drawLineHorzByLen(x,y,SZ,10) ;
    drawLineHorzByLen(x,y+SZ-1,SZ,11) ;
    drawLineVertByLen(x,y,SZ,12) ;
    drawLineVertByLen(x+SZ-1,y,SZ,14) ;

    // Update
    Inc(x,dx) ;
    Inc(y,dy) ;
    if (x<=0) then dx:=-dx ;
    if (x>=320-SZ-1) then dx:=-dx ; 
    if (y<=0) then dy:=-dy ;
    if (y>=200-SZ-1) then dy:=-dy ; 

    // Wait timer (18FPS)
    t:=getTimer() ;
    while (t=getTimer()) do ;
  end ;

  setScreen(3) ;
end.
