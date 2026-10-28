#include <i86.h>
#include <conio.h>
#include <malloc.h>
#include <string.h>
#include <stdio.h>

#define VGA_INPUT_STATUS_1   0x3DA
#define VGA_VSYNC_MASK 0x08       

// Функция недописана - нет возврата в key и scan
int isKeyPressed(char * key, char * scan) {
  int r = 0 ;
_asm {
  mov ah,1
  int 0x16
  jz nokey
  mov r,1
  mov ah,00
  int 0x16
nokey:
}
  return r ;
}

int getTimer()
{
  union REGS regs;

  regs.h.ah = 0 ;
  int86(0x1A, &regs, &regs) ;
  return regs.x.dx ;
}

volatile void Wait_For_Vsync()
{
  while(_inp(VGA_INPUT_STATUS_1) & VGA_VSYNC_MASK) { } ;
  while(!(_inp(VGA_INPUT_STATUS_1) & VGA_VSYNC_MASK)) { } ;
}

int main() {

  union REGS regs;

  unsigned int i;
  unsigned int j;
  int p ;
  int dp ;
  unsigned char far * video ;
  unsigned char far * buffer ;
  unsigned char far * sprite ;
  unsigned char c ;
  char key ;
  char scan ;
  int t ;
  FILE * f ;

  buffer = (unsigned char far * )_fmalloc(64000) ;
  sprite = (unsigned char far *)_fmalloc(1024) ;

  video = MK_FP(0xA000,0) ;

  f = fopen("sprite.dat","rb") ;
  for (i=0; i<1024; i++) {
    fread(&c,1,1,f) ;
    sprite[i]=c ;
  }
  fclose(f) ;

  regs.h.al = 0x13;
  regs.h.ah = 0;
  int86( 0x10, &regs, &regs );

  p=0 ;
  dp=1 ;
  while (1) {
    t = getTimer() ;
    _fmemset(buffer,10,64000) ;

    for (i=0; i<32; i++)
      for (j=0; j<32; j++) {
        if (sprite[j*32+i]!=0) buffer[(j+p)*320+(i+p)]=sprite[j*32+i] ;
        if (sprite[j*32+i]!=0) buffer[(j+p+40)*320+(i+p)]=sprite[j*32+i] ;
        if (sprite[j*32+i]!=0) buffer[(j+p)*320+(i+p+40)]=sprite[j*32+i] ;
        if (sprite[j*32+i]!=0) buffer[(j+p+40)*320+(i+p+40)]=sprite[j*32+i] ;
    }

    if (dp>0) Wait_For_Vsync() ;
    _fmemcpy(video,buffer,64000);

   if (isKeyPressed(&key,&scan)) break ;

    p+=dp ;
    if (p==120) dp=-1 ;
    if (p==0) dp=1 ;

    while (t==getTimer()) { } ;
  }

  _ffree(buffer) ;
  _ffree(sprite) ;

  regs.h.al = 0x03;
  regs.h.ah = 0;
  int86( 0x10, &regs, &regs );

  return 0 ;
}
