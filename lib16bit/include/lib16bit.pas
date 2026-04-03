unit lib16bit ;

interface

{$LINK lib16bit.obj}

procedure setScreen(num:Byte) ; cdecl ; external ;
procedure clearScreen() ; cdecl ; external ;
procedure drawLineHorzByLen(x,y,l:Integer; color:Byte) ; cdecl ; external ;
procedure drawLineVertByLen(x,y,l:Integer; color:Byte) ; cdecl ; external ;
function isKeyPressed(var key:Byte; var scan:Byte):Integer ; cdecl ; external ;
function getTimer():Integer ; cdecl ; external ;

implementation

end.
