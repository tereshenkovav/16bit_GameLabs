#include <stdio.h>
#include <int.h>

/*
  Прототип программы для установки и тестирования перехвата клавиатуры и
  формирования массива удержания клавиш
*/

inline int startFrame()
{
int r = 0 ;
asm {
  mov ah,0 
  int 1Ah
  mov r,dx
}
return r ;
}

int isKeyPressed(char * key, char * scan) {
  int r = 0 ;
asm {
  mov ah,1
  int 0x16
  jz nokey
  mov bx,[key]
  mov [bx],al 
  mov bx,[scan]
  mov [bx],ah 
  mov r,1
  mov ah,00
  int 0x16
nokey:
}
  return r ;
}

static volatile short int key_holded[128] ;

int newKeyHandler(struct INT_DATA *pd) {
  static volatile int code ;
  asm {
    xor ax,ax
    in  al,0x60
    mov code,ax
  }
  if ((code!=0)&&(code!=224)) {
    if (code<128) key_holded[code]=1; else key_holded[code-128]=0 ;
  }
  int_prev(pd) ;
}

int isKeyHolded(int code) {
  return key_holded[code] ;
}

void main()
{
   char key ;
   char code ;
   printf("start key tester\n") ;

   for (int i=0; i<127; i++)
     key_holded[i]=0 ;
   int_intercept(9, newKeyHandler, 256);

   int frame = startFrame() ;
   int cnt=0 ;
   while (cnt<100) {
     while (startFrame()==frame) {} ;
     frame = startFrame() ;

     for (int i=0; i<127; i++)
       if (isKeyHolded(i)) printf("H: %d ",i) ;
     if (isKeyPressed(&key,&code)) printf("\nkey=%d code=%d\n",key,code) ;
     cnt++ ;
   }
   int_restore(9) ;
   printf("exit key tester\n") ;

}
