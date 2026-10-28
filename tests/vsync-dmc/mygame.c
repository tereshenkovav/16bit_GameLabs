#include <bios.h>
#include <dos.h>
#include <stdlib.h>
#include <malloc.h>
#include <stdio.h>

union _REGS inregs, outregs;

int getTimer()
{
  inregs.h.ah = 0 ;
  int86(0x1A, &inregs, &outregs) ;
  return outregs.x.dx ;
}

int isKeyPressed(char * key, char * scan) {
  int r = 0 ;
asm {
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

#define VGA_INPUT_STATUS_1   0x3DA
#define VGA_VSYNC_MASK 0x08

void Wait_For_Vsync(void )
{
  while(_inp(VGA_INPUT_STATUS_1) & VGA_VSYNC_MASK) { }
  while(!(_inp(VGA_INPUT_STATUS_1) & VGA_VSYNC_MASK)) { }
}

void main() {
  unsigned char * video = (unsigned char *)MK_FP(0xA000,0) ;
  unsigned char * buf = malloc(64000) ;
  unsigned char * sprite = malloc(1024) ;

  char key ; char scan ;

  FILE * f = fopen("sprite.dat","rb") ;
  fread(sprite,1,1024,f) ;
  fclose(f) ;

  inregs.h.ah = 0 ;
  inregs.h.al = 0x13 ;
  int86(0x10, &inregs, &outregs);
    
  int t ;
  int p = 0 ;
  int dp = 1 ;
  while (1) {
    t = getTimer() ;
    
    memset(buf,10,64000) ;

    for (int i=0; i<32; i++)
      for (int j=0; j<32; j++) {
        if (sprite[j*32+i]!=0) buf[(j+p)*320+(i+p)]=sprite[j*32+i] ;
        if (sprite[j*32+i]!=0) buf[(j+p+40)*320+(i+p)]=sprite[j*32+i] ;
        if (sprite[j*32+i]!=0) buf[(j+p)*320+(i+p+40)]=sprite[j*32+i] ;
        if (sprite[j*32+i]!=0) buf[(j+p+40)*320+(i+p+40)]=sprite[j*32+i] ;
    }

    Wait_For_Vsync() ;
    memcpy(video,buf,64000) ;

    if (isKeyPressed(&key,&scan)) break ;

    p+=dp ;
    if (p==120) dp=-1 ;
    if (p==0) dp=1 ;
    while (t==getTimer()) { } ;
  }

  free(buf) ;
  free(sprite) ;

  inregs.h.ah = 0 ;
  inregs.h.al = 0x03 ;
  int86(0x10, &inregs, &outregs);
}
