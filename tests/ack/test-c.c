#include <stdio.h>

struct Unit {
  int x ;
  int y ;
} ;

extern void testasmproc() ;

int main() {
  struct Unit units[10] ;
  units[0].x=10 ;
  printf("Test Ack C\n") ;
  printf("Unit [0].x: %d\n",units[0].x) ;
  testasmproc() ;
  return 0 ;
}
