#include "gameapi.h"

const int SCREENWIDTH=320 ;
const int SCREENHEIGHT=200 ;
const int SCREENSIZEWORD=32000 ;

const unsigned int SegA000 = 0xA000 ;

char tekcolor = 15 ;
static volatile short int key_holded[128] ;

// Текущее значение генератора
unsigned int rndseed = 0 ;

void setScreen(char num)
{
asm {
  mov ah,0
  mov al,num
  int 0x10
}
}

// Очистка экрана
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

// Установка цвета переднего плана
void setColor(int color) {
  tekcolor = color;
}

void SoundOff(){
asm {
  in al,0x61
  and al,0b11111100
  out 0x61,al
}
}

void SoundFreq(unsigned int freq) {
asm {
  mov cx,freq
  mov al,0b10110110   // Упр.сл.таймера: канал 2, режим 3, дв.слово
  out 0x43,al         // Выводим в регистр режима

  mov dx,0x12
  mov ax,0x34DD       // DX:AX = 1193181
  div cx             // AX = (DX:AX) / СX
  out 0x42,al         // Записываем младший байт счетчика
  mov al,ah
  out 0x42,al         // Записываем старший байт счетчика
}
}

void SoundOn() {
asm {
  in al,0x61
  or al,0b11
  out 0x61,al
}
}

void playSound(int len, int freq) {
  SoundOn() ;
  SoundFreq(freq) ;
  for (int i=0; i<len; i++) {
  int frame = startFrame() ;
  waitFrameCompleted(frame) ;
  }
  SoundOff() ;
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

void waitKeyPressed(char * key, char * scan) {
   while (isKeyPressed(key,scan)==0) { } ;
}

void setCursorXY(char x, char y) {
asm {
  mov dh, y
  mov dl, x
  mov bh, 0
  mov ah, 2
  int 0x10
}
}

// Вывод символа
void drawChar(char c) {
asm {
  mov bh, 0
  mov bl, tekcolor
  mov ah, 0x0E
  mov al, c
  int 0x10
}
}

// Вывод символа в позиции
void drawCharAt(char x, char y, char c) {
  setCursorXY(x,y) ;
  drawChar(c) ;
}

// Установка нового значения генератора
void Randomize() {
asm {
  mov ah,0 
  int 0x1A
  mov rndseed,dx
}
}

// Получение следующего seed
unsigned int getNewSeed() {
  rndseed=rndseed ^ (rndseed << 7) ;
  rndseed=rndseed ^ (rndseed >> 9) ;
  rndseed=rndseed ^ (rndseed << 8) ;
  return rndseed ;
}

// Черновая процедура генерации числа в байте от 0 до d-1
unsigned int genRndByByte(int d) {
  return getNewSeed() % d ;
}

// Вывод цифры в позиции
void drawDigitAt(int x, int y, int d) {
  drawCharAt(x,y,'0'+d) ;
}

// Вывод десятичного числа с ведущими нулями
void drawIntAt(int x, int y, int v) {
  setCursorXY(x,y) ;

  const int D10[4] = { 10000, 1000, 100, 10 } ;

  for (int i = 0; i<4; i++) {
    drawChar('0'+(v / D10[i])) ;
    v=v % D10[i] ;
  }
  drawChar('0'+v) ;
}

// Вывод нуль-терминальной строки в позиции
void drawStringAt(char x, char y, const char * str) {
  setCursorXY(x,y) ;  

  for (int i=0; str[i]!=0; i++){
  char p = str[i] ;
  asm {
  mov bh, 0
  mov bl, tekcolor
  mov ah, 0x0E
  mov al, p
  int 0x10
  }
  }
}

int abs(int v) {
  return (v<0)?-v:v ;
}

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

void setNewKeyHandler()
{
   for (int i=0; i<127; i++)
     key_holded[i]=0 ;
   int_intercept(9, newKeyHandler, 256);
}

void restoreOldKeyHandler()
{
   int_restore(9) ;
}
