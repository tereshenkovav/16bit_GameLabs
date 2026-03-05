#include "const_en.h"
#include "gameapi.h"

// Функции логики
enum BonusType { btNone=0, btSpeedUp=1, btScore=2, btShield=3 } ;

// Структура бонуса
struct Bonus {
  int x ;
  int y ;
  enum BonusType t ;
};

// Структура врагов
struct Enemy {
  int x ;
  int y ;
  int exist ;
};

// Символы для бонусов
const char BONUS_CHARS[4] = { 0, 053, 052, 045 } ;

// Переменные игры
const int MAXBONUS = 16 ;
const int MAXENEMY = 4 ;
struct Bonus bonuses[16] ;
struct Enemy enemy[16] ;
int playerx ;
int playery ;
int T_enemy ;
int T_newenemy ;
int T_player ;

// Символы для вывода героя, врага и пробела
const char HERO = 0100 ;
const char ENEMY = 044 ;
const char SPACE = 040 ;

// Размеры поля и точки спавна врагов
const int BORDER = 1 ;
const int SIZEX = 38 ;
const int SIZEY = 20 ;
const int SPAWNX[4] = {1,38,1,38} ;
const int SPAWNY[4] = {1,1,20,20} ;

const int SCORE_POS_X = 34 ;

// Константы игрового баланса
const int INC_SCORE_BY_BONUS = 100 ;
const int INC_SCORE_BY_KILLENEMY = 50 ;
const int INC_SCORE_BY_ONESEC = 10 ;

const int LIFETIME_FOR_BONUS = 9 ;
const int MOVE_PERIOD_ENEMY = 5 ;
const int MOVE_PERIOD_PLAYER = 6 ;
const int MOVE_PERIOD_PLAYER_FAST = 3 ;
const int PERIOD_NEW_ENEMY = 100 ;

char key ;
char scan ;

// Переменные настройки игры - звук
int soundon = 1 ;

// Новый враг
int newEnemy() {
   int idx = genRndByByte(4) ;
   for (int i=0; i<MAXENEMY; i++)
     if (!enemy[i].exist) {
       enemy[i].x = SPAWNX[idx] ;
       enemy[i].y = SPAWNY[idx] ;
       enemy[i].exist=1 ;
       return i ;
     }
   return MAXENEMY ;
}

// Возврат MAXBONUS - означает, что нет индекса
int getBonusIdxAt(int x, int y) {
   for (int i=0; i<MAXBONUS; i++)
     if (bonuses[i].t!=btNone)
       if ((x==bonuses[i].x)&&(y==bonuses[i].y))
         return i ;
   return MAXBONUS ;
}

// Новый бонус
int newBonus(enum BonusType t) {
   for (int i=0; i<MAXBONUS; i++)
     if (bonuses[i].t==btNone) {
       while (1) {
         int x = BORDER+genRndByByte(SIZEX) ;
         int y = BORDER+genRndByByte(SIZEY) ;
         if ((getBonusIdxAt(x,y)==MAXBONUS)&&((playerx!=x)||(playery!=y))) {
           bonuses[i].x=x ;
           bonuses[i].y=y ;
           bonuses[i].t=t ;
           break ;
         }
       }
       return i;
     }
}

// Двигать игрока
void movePlayer(int dx, int dy) {
    drawCharAt(playerx,playery,SPACE) ;
    playerx+=dx ;
    playery+=dy ;
    setColor(10) ;
    drawCharAt(playerx,playery,HERO) ;
}

// Двигать врага по индексу
void moveEnemy(int i, int dx, int dy) {
    drawCharAt(enemy[i].x,enemy[i].y,SPACE) ;
    int idx = getBonusIdxAt(enemy[i].x,enemy[i].y) ;
    if (idx!=MAXBONUS) {
      setColor(11) ;
      drawCharAt(bonuses[idx].x,bonuses[idx].y,BONUS_CHARS[bonuses[idx].t]) ;
    }
    enemy[i].x+=dx ;
    enemy[i].y+=dy ;
    setColor(12) ;
    drawCharAt(enemy[i].x,enemy[i].y,ENEMY) ;
}

// Звуковые эффекты
inline void playBonusEffect() {
   if (!soundon) return ;
   playSound(2,1000) ;
   playSound(4,2000) ;
}

inline void playGameOverEffect() {
   if (!soundon) return ;
   playSound(4,400) ;
   playSound(3,200) ;
   playSound(2,100) ;
}

void PrintMenu() {
    clearScreen() ;
    setColor(15) ;
    drawStringAt(4,3,GAMETITLE) ;
    drawStringAt(10,6,MENU_START) ;
    drawStringAt(10,7,MENU_SOUND) ;
    drawStringAt(10,8,MENU_HELP) ;
    drawStringAt(10,9,MENU_EXIT) ;

    drawStringAt(POS_TEXT_SOUND_ON_OFF,7,soundon?TEXT_ON:TEXT_OFF) ;

    drawStringAt(4,13,TEXT_AUTHOR) ;
    drawStringAt(4,14,"github.com/tereshenkovav") ;
    drawStringAt(4,15,"tav-developer.itch.io") ;
}

void PrintHelpAndWaitEnter() {
    clearScreen() ;
    setColor(15) ;
    drawStringAt(7,3,HELP0) ;
    drawStringAt(7,4,HELP1) ;
    drawStringAt(7,5,HELP2) ;
    drawStringAt(7,6,HELP3) ;
    setColor(11) ;
    drawStringAt(7,8,HELP4) ;
    drawStringAt(7,9,HELP5) ;
    drawStringAt(7,10,HELP6) ;
    setColor(15) ;
    drawStringAt(7,12,HELP7) ;
    do {
      waitKeyPressed(&key,&scan) ;
    } while (key!=KEY_ENTER) ;
}

void MainGame() {
    setNewKeyHandler() ;

    clearScreen() ;

    // Рисование рамки
    setColor(15) ;
    drawCharAt(0,0,0xDA) ;
    for (int i=BORDER; i<=SIZEX; i++) drawChar(0xC4) ;
    drawChar(0xBF) ;

    for (int i=BORDER; i<=SIZEY; i++) {
        drawCharAt(0,i,0xB3) ;
        drawCharAt(SIZEX+BORDER,i,0xB3) ;
    }

    drawCharAt(0,SIZEY+BORDER,0xC0) ;
    for (int i=BORDER; i<=SIZEX; i++) drawChar(0xC4) ;
    drawChar(0xD9) ;

    // Вывод надписей
    drawStringAt(1,SIZEY+2,BONUS_SPEEDUP) ;
    drawStringAt(POS_TEXT_BONUS_SHIELD,SIZEY+2,BONUS_SHIELD) ;
    drawStringAt(POS_TEXT_BONUS_SCORE,SIZEY+2,BONUS_SCORE) ;

    playerx = 15 ;
    playery = 10 ;

    for (int i=0; i<MAXENEMY; i++)
      enemy[i].exist = 0 ;
    newEnemy() ;

    for (int i=0; i<MAXBONUS; i++)
      bonuses[i].t = btNone ;
    newBonus(btSpeedUp) ;
    newBonus(btSpeedUp) ;
    newBonus(btSpeedUp) ;
    newBonus(btScore) ;
    newBonus(btScore) ;
    newBonus(btScore) ;
    newBonus(btShield) ;
    newBonus(btShield) ;
    newBonus(btShield) ;

    int score = 0 ;

    setColor(10) ;
    drawCharAt(playerx,playery,HERO) ;

    setColor(12) ;
    for (int i=0; i<MAXENEMY; i++)
      if (enemy[i].exist)
        drawCharAt(enemy[i].x,enemy[i].y,ENEMY) ;

    setColor(11) ;
    for (int i=0; i<MAXBONUS; i++)
      if (bonuses[i].t!=btNone)
        drawCharAt(bonuses[i].x,bonuses[i].y,BONUS_CHARS[bonuses[i].t]) ;

    int ticks_common = 0 ;
    int ticks_enemy = 0 ;
    int ticks_player = 0 ;
    int ticks_newenemy = 0 ;
    int left_bonus_speed = 0 ;
    int left_bonus_shield = 0 ;

    T_enemy = MOVE_PERIOD_ENEMY ;
    T_player = MOVE_PERIOD_PLAYER ;
    T_newenemy = PERIOD_NEW_ENEMY ;

    setColor(10) ;
    drawIntAt(SCORE_POS_X,SIZEY+2,score) ;

    for (;;) {
       int frame = startFrame() ;

       if (ticks_player==0) { // Ограничения по тактам
         if (isKeyHolded(SCAN_LEFT))
           if (playerx>BORDER) movePlayer(-1,0) ;
         if (isKeyHolded(SCAN_RIGHT))
           if (playerx<=SIZEX-BORDER) movePlayer(1,0) ;
         if (isKeyHolded(SCAN_UP))
           if (playery>BORDER) movePlayer(0,-1) ;
         if (isKeyHolded(SCAN_DOWN))
           if (playery<=SIZEY-BORDER) movePlayer(0,1) ;

         int idx = getBonusIdxAt(playerx,playery) ;
         if (idx!=MAXBONUS) {
               enum BonusType bt = bonuses[idx].t ;
               if (bt==btSpeedUp) {
                 T_player = MOVE_PERIOD_PLAYER_FAST ;
                 left_bonus_speed = LIFETIME_FOR_BONUS ;
                 setColor(10) ;
                 drawDigitAt(SPEEDUP_POS_X,SIZEY+2,left_bonus_speed) ;
               }
               if (bt==btShield) {
                 left_bonus_shield = LIFETIME_FOR_BONUS ;
                 setColor(10) ;
                 drawDigitAt(SHIELD_POS_X,SIZEY+2,left_bonus_shield) ;
               }
               if (bt==btScore)
                 score+=INC_SCORE_BY_BONUS ;
               bonuses[idx].t=btNone ;
               idx = newBonus(bt) ;
               setColor(11) ;
               drawCharAt(bonuses[idx].x,bonuses[idx].y,BONUS_CHARS[bonuses[idx].t]) ;
               playBonusEffect() ;
         }
       }
       if (ticks_enemy==0) { // Ограничения по тактам
        for (int i=0; i<MAXENEMY; i++)
         if (enemy[i].exist) {
         int dx=0 ;
         int dy=0 ;
         if (abs(playerx-enemy[i].x)>abs(playery-enemy[i].y)) {
           if (playerx<enemy[i].x) dx=-1 ;
           if (playerx>enemy[i].x) dx=1 ;
         }
         else {
           if (playery<enemy[i].y) dy=-1 ;
           if (playery>enemy[i].y) dy=1 ;
         }
         moveEnemy(i,dx,dy) ;
         if ((abs(playerx-enemy[i].x)<2)&&(abs(playery-enemy[i].y)<2)) {
           if (left_bonus_shield==0) {
             setColor(12) ;
             drawStringAt(1,SIZEY+3,TEXT_GAMEOVER) ;
	     playGameOverEffect() ;
             goto Finish ;
           }
           else {
             score+=INC_SCORE_BY_KILLENEMY ;
             // Перерисовка игрока или затирание монстра, по ситуации
             if ((enemy[i].x==playerx)&&(enemy[i].y==playery)) {
               setColor(10) ;
               drawCharAt(playerx,playery,HERO) ;
             }
             else
               drawCharAt(enemy[i].x,enemy[i].y,SPACE) ;
             enemy[i].exist=0 ;
             playBonusEffect() ;
           }
         }
        }
       }
       if (ticks_common==0) { // Ежесекундная процедура
         if (left_bonus_speed>0) {
           left_bonus_speed-- ;
           if (left_bonus_speed==0) {
             T_player = MOVE_PERIOD_PLAYER ;
             drawCharAt(SPEEDUP_POS_X,SIZEY+2,SPACE) ;
           }
           else {
             setColor(10) ;
             drawDigitAt(SPEEDUP_POS_X,SIZEY+2,left_bonus_speed) ;
           }
         }
         if (left_bonus_shield>0) {
           left_bonus_shield-- ;
           if (left_bonus_shield==0) {
             drawCharAt(SHIELD_POS_X,SIZEY+2,SPACE) ;
           }
           else {
             setColor(10) ;
             drawDigitAt(SHIELD_POS_X,SIZEY+2,left_bonus_shield) ;
           }
         }
         score+=INC_SCORE_BY_ONESEC ;
         setColor(10) ;
         drawIntAt(SCORE_POS_X,SIZEY+2,score) ;
       }
       isKeyPressed(&key,&scan) ;
       if (scan==SCAN_ESCAPE) {
          setColor(12) ;
          drawStringAt(1,SIZEY+3,TEXT_GAMEOVER) ;
          break ;
       }
       ticks_common++ ;
       ticks_player++ ;
       ticks_enemy++ ;
       ticks_newenemy++ ;
       // Число тактов связано с FPS=10 и устанавливается в таймере
       if (ticks_common>10) ticks_common=0 ;
       if (ticks_player>T_player) ticks_player=0 ;
       if (ticks_enemy>T_enemy) ticks_enemy=0 ;
       if (ticks_newenemy>T_newenemy) {
          ticks_newenemy=0 ;
          setColor(12) ;
          int idx = newEnemy() ;
          if (idx!=MAXENEMY)
            drawCharAt(enemy[idx].x,enemy[idx].y,ENEMY) ;
       }

       waitFrameCompleted(frame) ;
    }
Finish:
    restoreOldKeyHandler() ;

    do {
      waitKeyPressed(&key,&scan) ;
    } while (key!=KEY_ENTER) ;

}

void main()
{
    setScreen(0x13) ;
    Randomize() ;
    while (1) {
      PrintMenu() ;
      do {
        waitKeyPressed(&key,&scan) ;
      } while ((key<'0')||(key>'4')) ;      
      if (key=='1') MainGame() ;
      if (key=='2') soundon=1-soundon ;
      if (key=='3') PrintHelpAndWaitEnter() ;
      if (key=='0') break ;
    }
    setScreen(0x3) ;
}
