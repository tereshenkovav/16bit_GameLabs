#ifndef GAMEAPI_H
#define GAMEAPI_H

// Константы для клавиш
static const char KEY_ENTER = 13 ;
static const char SCAN_LEFT = 75 ;
static const char SCAN_RIGHT = 77 ;
static const char SCAN_UP = 72 ;
static const char SCAN_DOWN = 80 ;
static const char SCAN_ESCAPE = 1 ;

int isKeyPressed(char * key, char * scan) ;

void waitKeyPressed(char * key, char * scan) ;

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

// Ожидание прохода таймера через ноль
inline void waitFrameCompleted(int frame)
{
asm {
  mov ah,0 
lab:
  int 1Ah
  cmp frame,dx
  je lab
}
}

void setScreen(char num);
// Очистка экрана
void clearScreen();
// Установка цвета переднего плана
void setColor(int color);
// Играть звук длиной len тактов частоты freq
void playSound(int len, int freq);
void setCursorXY(char x, char y);
// Вывод символа в позиции
void drawCharAt(char x, char y, char c);
// Установка нового значения генератора
void Randomize();
// Черновая процедура генерации числа в байте от 0 до d-1
unsigned int genRndByByte(int d);
// Вывод цифры в позиции
void drawDigitAt(int x, int y, int d);
// Вывод десятичного числа с ведущими пробелами
void drawIntAt(int x, int y, int v);
// Вывод нуль-терминальной строки в позиции
void drawStringAt(char x, char y, const char * str);
int abs(int v);
int isKeyHolded(int code) ;
void setNewKeyHandler() ;
void restoreOldKeyHandler() ;
#endif
