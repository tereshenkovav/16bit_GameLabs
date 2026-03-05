program testack(input, output) ;

type
  TUnit = record
    x:Integer ;
    y:Integer ;
  end ;

var units:array [0..5] of TUnit ;

procedure testasmproc ; extern ;

begin
  units[0].x:=10 ;
  Writeln('Test Ack Pascal') ;
  Writeln('Units[0].x=',units[0].x) ;
  testasmproc ;
end.