#define SCREENWIDTH 320
#define SCREENHEIGHT 200
#define SCREENSIZEWORD 32000

#define SegA000 0xA000

void setScreen(char num) {
  asm {
    mov ah,0
    mov al,num
    int 0x10
  }
}

void clearScreen()
{
asm {
  mov ax,SegA000
  mov es,ax
  mov di,0
  mov al,0
  mov ah,0
  mov cx,SCREENSIZEWORD
  rep stosw
}
}

void drawLineHorzByLen(int x, int y, int len, char color)
{
  unsigned int pos ;
  if (len<0) {
    pos=SCREENWIDTH*y+x+len+1 ;
    len=-len ;
  }
  else
    pos=SCREENWIDTH*y+x ;
asm {
  mov ax,SegA000
  mov es,ax
  mov di,pos
  mov al,color
  mov cx,len
  rep stosb
}
}

void drawLineVertByLen(int x, int y, int len, char color)
{
  unsigned int pos = SCREENWIDTH*y+x ;
asm {
  mov ax,SegA000
  mov es,ax
  mov di,pos
  mov al,color
  mov cx,len
lab:
  stosb
  add di,SCREENWIDTH
  dec di
  loop lab
}
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

int getTimer()
{
int r = 0 ;
asm {
  mov ah,0 
  int 1Ah
  mov r,dx
}
return r ;
}
