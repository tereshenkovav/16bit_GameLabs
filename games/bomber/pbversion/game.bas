$DIM ARRAY
$CPU 80286
$FLOAT EMULATE
$OPTIMIZE SPEED
DEFINT A-Z

TYPE PointXY
  x AS INTEGER
  y AS INTEGER
END TYPE

TYPE Rect
  rleft AS INTEGER
  rtop AS INTEGER
  rright AS INTEGER
  rbottom AS INTEGER
END TYPE

TYPE GameObject
  x AS INTEGER
  y AS INTEGER
  vx AS INTEGER
  vy AS INTEGER
  typ AS INTEGER
  friend AS INTEGER
END TYPE

DECLARE SUB MainMenu()
DECLARE SUB SwitchPage()
DECLARE SUB DrawWhiteRect(re AS Rect)
DECLARE SUB AddFire()
DECLARE SUB AddBomb()
DECLARE SUB AddSuper()
DECLARE SUB AddEnemyTank()
DECLARE SUB AddEnemyBomb()
DECLARE SUB AddEnemyPlane()
DECLARE SUB AddPlaneFire(idx AS INTEGER)
DECLARE SUB AddTankFire(idx AS INTEGER)
DECLARE SUB CalcRectForEnemy(idx AS INTEGER, re AS Rect)
DECLARE SUB CalcRectForFire(idx AS INTEGER, re AS Rect)
DECLARE SUB CalcRectForPlayer(re AS Rect)
DECLARE FUNCTION IsXYInRect(x AS INTEGER, y AS INTEGER, re AS Rect) AS INTEGER
DECLARE FUNCTION IsRectsIntersect(r1 AS Rect, r2 AS Rect) AS INTEGER

DIM mountain(20) AS PointXY
DIM superv(7) AS SHARED PointXY
DIM enemybombr(4) AS SHARED PointXY
DIM fire(50) AS SHARED GameObject
DIM enemy(50) AS SHARED GameObject

REM Позиции гор
DATA 0, 190, 70, 170, 70, 170, 130, 190, 310, 190, 350, 140, 350, 140, 400
DATA 190, 710, 190, 750, 160, 750, 160, 800, 190, 1000, 190, 1040, 150, 1040
DATA 150, 1080, 190, 1060, 170, 1080, 160, 1080, 160, 1120, 190
REM Направления супервыстрела
DATA -6,0,-4,2,-2,4,0,6,2,4,4,2,6,0
REM Векторы лучей бомб
DATA -3,-3,-3,3,3,3,3,-3

SHARED firecount,enemycount,supercount,superv
SHARED playerx,playery,playervx,playervy,playerw,playerw2,playerh,playerh2
SHARED laserwait,laserdelay,bombwait,bombdelay,superwait,superdelay
SHARED ftlaser,ftbomb,ftsuper,etplane,ettank,etbomb
SHARED enemybombd,enemybombr,bomd,bombr,laserw,superd,superr

DIM re AS Rect
DIM rf AS Rect
DIM rp AS Rect

mountainsize = UBOUND(mountain)
firecount = UBOUND(fire)
supercount = UBOUND(superv)
enemycount = UBOUND(enemy)
enemybombrcount = UBOUND(enemybombr)

REM Отладочный вывод хитбоксов
showhitzones = 0

FOR i = 0 TO mountainsize-1: READ mountain(i).x, mountain(i).y:  NEXT i
FOR i = 0 TO supercount-1: READ superv(i).y, superv(i).x: NEXT i
FOR i = 0 TO enemybombrcount-1: READ enemybombr(i).x, enemybombr(i).y: NEXT i

REM Установка экрана и экранных страниц отображаемой и активной
SCREEN 7

WorkEntry:

MainMenu

REM Начальные установки
playerx = 100: playery = 100
playerw = 20: playerw2 = 10
playerh = 10: playerh2 = 5
playervx = 0: playervy = 0
playerbasev = 2
stopx1 = 10: stopx2 = 290: stopy1 = 10: stopy2 = 160
laserw = 10: bombr = 3: bombd = 6: superr = 1: superd = 3
laserwait = 0: laserdelay = 10
bombwait = 0: bombdelay = 30
superwait = 0: superdelay = 100
ftlaser = 1: ftbomb = 2: ftsuper = 3
ettank = 1: etbomb = 2: etplane = 3
enemybombr = 5: enemybombd = 10
enemywait = 20: enemymindelay = 30: enemyvardelay = 30
killtimer = 0: score = 0

FOR i = 0 to firecount-1: fire(i).typ=0: NEXT i
FOR i = 0 to enemycount-1: enemy(i).typ=0: NEXT i

RANDOMIZE TIMER

DIM t AS SINGLE,t1 AS SINGLE
REM Главный цикл
WHILE 1

t = TIMER: t1 = t

CLS
LINE (0,191)-(319,191),2

REM Вывод гор

FOR i=0 TO mountainsize-1 STEP 2
  IF (mountain(i).x>-100)AND(mountain(i).x<420) THEN
    IF (mountain(i+1).x>-100)AND(mountain(i+1).x<420) THEN
      LINE (mountain(i).x,mountain(i).y)-(mountain(i+1).x,mountain(i+1).y),6
    END IF
  END IF
NEXT i

REM Вывод корабля

IF killtimer=0 THEN
  LINE (playerx,playery)-(playerx+playerw,playery+playerh2),10
  LINE (playerx+playerw,playery+playerh2)-(playerx,playery+playerh),10
  LINE (playerx,playery+playerh)-(playerx,playery),10
END IF

REM Вывод выстрелов
FOR i = 0 to firecount-1
  IF fire(i).typ=ftlaser THEN
    LINE (fire(i).x,fire(i).y)-(fire(i).x+laserw,fire(i).y),12
  END IF
  IF fire(i).typ=ftbomb THEN
    CIRCLE (fire(i).x-bombr,fire(i).y-bombr),bombr,12
  END IF
  IF fire(i).typ=ftsuper THEN
    LINE (fire(i).x-superr,fire(i).y-superr)-(fire(i).x+superr,fire(i).y+superr),12
    LINE (fire(i).x-superr,fire(i).y+superr)-(fire(i).x+superr,fire(i).y-superr),12
  END IF
NEXT i

REM Вывод врагов
FOR i = 0 to enemycount-1
  IF enemy(i).typ=ettank THEN
    LINE (enemy(i).x,enemy(i).y+7)-(enemy(i).x+4,enemy(i).y),14
    LINE (enemy(i).x+4,enemy(i).y)-(enemy(i).x+20,enemy(i).y),14
    LINE (enemy(i).x+20,enemy(i).y)-(enemy(i).x+24,enemy(i).y+7),14
    LINE (enemy(i).x+24,enemy(i).y+7)-(enemy(i).x,enemy(i).y+7),14

    LINE (enemy(i).x+16,enemy(i).y)-(enemy(i).x+7,enemy(i).y-6),14
  END IF
  IF enemy(i).typ=etbomb THEN
    CIRCLE (enemy(i).x-enemybombr,enemy(i).y-enemybombr),enemybombr,14
    FOR j = 0 TO enemybombrcount-1
      enemyx1 = enemy(i).x - enemybombr + enemybombr(j).x
      enemyy1 = enemy(i).y - enemybombr + enemybombr(j).y
      LINE (enemyx1,enemyy1)-(enemyx1+enemybombr(j).x,enemyy1+enemybombr(j).y),14
    NEXT j
  END IF
  IF enemy(i).typ=etplane THEN
    LINE (enemy(i).x+playerw,enemy(i).y)-(enemy(i).x,enemy(i).y+playerh2),14
    LINE (enemy(i).x,enemy(i).y+playerh2)-(enemy(i).x+playerw,enemy(i).y+playerh),14
    LINE (enemy(i).x+playerw,enemy(i).y+playerh)-(enemy(i).x+playerw,enemy(i).y),14
  END IF
NEXT i

IF showhitzones=1 THEN
FOR i = 0 to enemycount-1
  IF enemy(i).typ<>0 THEN
    CALL CalcRectForEnemy(i,re): CALL DrawWhiteRect(re)
  END IF
NEXT i
FOR i = 0 to firecount-1
  IF fire(i).typ<>0 THEN
    CALL CalcRectForFire(i,rf): CALL DrawWhiteRect(rf)
  END IF
NEXT i
CALL CalcRectForPlayer(rp): CALL DrawWhiteRect(rp)
END IF

REM Информация о готовности
COLOR 7,0
LOCATE 1,1: PRINT "Laser:"
LOCATE 1,10: PRINT "Bomb:"
LOCATE 1,18: PRINT "Super:"
LOCATE 1,27: PRINT "SCORE:"

COLOR 10,0
IF laserwait=0 THEN
  LOCATE 1,7: PRINT "OK"
END IF
IF bombwait=0 THEN
  LOCATE 1,15: PRINT "OK"
END IF
IF superwait=0 THEN
  LOCATE 1,24: PRINT "OK"
END IF

LOCATE 1,33: PRINT LTRIM$(STR$(score))

REM Переключение страницы
SwitchPage

REM Управление клавиатурой
k$ = INKEY$
IF k$=CHR$(0)+CHR$(72) THEN
  playervy=-playerbasev: playervx=0
END IF
IF k$=CHR$(0)+CHR$(80) THEN
  playervy=playerbasev: playervx=0
END IF
IF k$=CHR$(0)+CHR$(75) THEN
  playervx=-playerbasev: playervy=0
END IF
IF k$=CHR$(0)+CHR$(77) THEN
  playervx=playerbasev: playervy=0
END IF
IF k$=CHR$(27) THEN WorkEntry:
IF k$=CHR$(32) THEN
  playervx=0: playervy=0
END IF
IF killtimer=0 THEN
  IF (k$=CHR$(90))OR(k$=CHR$(122)) THEN AddFire
  IF (k$=CHR$(88))OR(k$=CHR$(120)) THEN AddBomb
  IF (k$=CHR$(67))OR(k$=CHR$(99)) THEN AddSuper
END IF

REM Обновление игры

REM Обновление игрока
INCR playerx,playervx: INCR playery,playervy

IF playerx<=stopx1 THEN
  playerx = stopx1:  playervx = 0
END IF

IF playerx>=stopx2 THEN
  playerx = stopx2: playervx = 0
END IF

IF playery<=stopy1 THEN
  playery = stopy1: playervy = 0
END IF

IF playery>=stopy2 THEN
  playery = stopy2: playervy = 0
END IF

CALL CalcRectForPlayer(rp)
REM Удар игрока о врагов
FOR i = 0 to enemycount-1
  IF enemy(i).typ<>0 THEN
    CALL CalcRectForEnemy(i,re)
    IF IsRectsIntersect(rp,re) THEN
      enemy(i).typ=0
      if killtimer=0 THEN killtimer=36
    END IF
  END IF
NEXT i
REM Удар игрока о снаряды
FOR i = 0 to firecount-1
  IF fire(i).typ<>0 THEN
    IF fire(i).friend=0 THEN
      CALL CalcRectForFire(i,rf)
      IF IsRectsIntersect(rp,rf) THEN
        fire(i).typ=0
        if killtimer=0 THEN killtimer=36
      END IF
    END IF
  END IF
NEXT i

REM Удар врагов о снаряды
FOR i = 0 to enemycount-1
  IF enemy(i).typ<>0 THEN
    CALL CalcRectForEnemy(i,re)
    FOR j = 0 to firecount-1
      IF (fire(j).typ<>0)AND(fire(j).friend=1) THEN
        CALL CalcRectForFire(j,rf)
        IF IsRectsIntersect(re,rf) THEN
          IF enemy(i).typ=ettank THEN INCR score,400
          IF enemy(i).typ=etplane THEN INCR score,200
          IF enemy(i).typ=etbomb THEN INCR score,100
          enemy(i).typ=0
          fire(j).typ=0
        END IF
      END IF
    NEXT j
  END IF
NEXT i

REM Обновление выстрелов
FOR i = 0 to firecount-1
  IF fire(i).typ<>0 THEN
    INCR fire(i).x,fire(i).vx
    INCR fire(i).y,fire(i).vy
    IF (fire(i).x>=320)OR(fire(i).x<=0) THEN fire(i).typ=0
    IF (fire(i).y>=190)OR(fire(i).y<=0) THEN fire(i).typ=0
  END IF
NEXT i
IF laserwait>0 THEN DECR laserwait
IF bombwait>0 THEN DECR bombwait
IF superwait>0 THEN DECR superwait

REM Обновление врагов
FOR i = 0 to enemycount-1
  IF enemy(i).typ<>0 THEN
    INCR enemy(i).x,enemy(i).vx
    INCR enemy(i).y,enemy(i).vy
    IF (enemy(i).x>=320)OR(enemy(i).x<=0) THEN enemy(i).typ=0
    IF (enemy(i).y>=190)OR(enemy(i).y<=0) THEN enemy(i).typ=0
  END IF
  IF enemy(i).typ=etplane THEN
    IF (enemy(i).y>=stopy2)OR(enemy(i).y<=stopy1) THEN enemy(i).vy=-enemy(i).vy
    if enemy(i).y MOD 40 < 2 THEN AddPlaneFire(i)
  END IF
  IF enemy(i).typ=etbomb THEN
    enemy(i).vy=0
    IF enemy(i).y<playery THEN enemy(i).vy=1
    IF enemy(i).y>playery THEN enemy(i).vy=-1
  END IF
  IF enemy(i).typ=ettank THEN
    if enemy(i).x MOD 100 = 0 THEN AddTankFire(i)
  END IF
NEXT i

IF enemywait>0 THEN DECR enemywait

IF enemywait = 0 THEN
  enemywait = enemymindelay + CINT(RND(1)*enemyvardelay)

  tekrnd = CINT(RND(1)*2)
  if tekrnd = 0 THEN AddEnemyTank
  if tekrnd = 1 THEN AddEnemyPlane
  IF tekrnd = 2 THEN AddEnemyBomb
END IF

REM Прокрутка гор
FOR i=0 to mountainsize-1
  DECR mountain(i).x, 2
  IF mountain(i).x<-300 THEN INCR mountain(i).x, 1400
NEXT i

IF killtimer>0 THEN
  DECR killtimer
  IF killtimer=0 THEN WorkEntry:
END IF

REM Ожидание кадра
WHILE t1=t: t1=TIMER: WEND

WEND

REM Раздел процедур и функций

SUB MainMenu()
CLS

COLOR 15,0
LOCATE 5,5: PRINT "BASIC-written game prototype"
LOCATE 6,7: PRINT "for 16bit DOS realmode"

LOCATE 8,5: PRINT "Controls:"
LOCATE 9,7: PRINT "Arrows - moving"
LOCATE 10,7: PRINT "Space - stop"
LOCATE 11,7: PRINT "Z - laser"
LOCATE 12,7: PRINT "X - bomb"
LOCATE 13,7: PRINT "C - superfire"

LOCATE 15,5: PRINT "Press Space to start game"
LOCATE 16,7: PRINT "or Escape to exit"

REM Переключение страницы
SwitchPage

WHILE 1
  k$ = INKEY$
  IF k$=CHR$(32) THEN EXIT SUB
  IF k$=CHR$(27) THEN
    SCREEN 0
    END
  END IF
WEND
END SUB

SUB AddFire()
  IF laserwait>0 THEN EXIT SUB
  FOR i = 0 to firecount-1
    IF fire(i).typ=0 THEN
       fire(i).typ=ftlaser
       fire(i).x=playerx+playerw
       fire(i).y=playery+playerh2
       fire(i).vx=8
       fire(i).vy=0
       fire(i).friend=1
       laserwait=laserdelay
       EXIT SUB
    END IF
  NEXT i
END SUB

SUB AddBomb()
  IF bombwait>0 THEN EXIT SUB
  FOR i = 0 to firecount-1
    IF fire(i).typ=0 THEN
       fire(i).typ=ftbomb
       fire(i).x=playerx+playerw2
       fire(i).y=playery+playerh
       fire(i).vx=playervx
       fire(i).vy=4
       fire(i).friend=1
       bombwait=bombdelay
       EXIT SUB
    END IF
  NEXT i
END SUB

SUB AddSuper()
  IF superwait>0 THEN EXIT SUB
  superwait=superdelay
  j = 0
  FOR i = 0 to firecount-1
    IF fire(i).typ=0 THEN
       fire(i).typ=ftsuper
       fire(i).x=playerx+playerw
       fire(i).y=playery+playerh2
       fire(i).vx=superv(j).x+playervx
       fire(i).vy=superv(j).y+playervy
       fire(i).friend=1
       IF j=supercount-1 THEN EXIT SUB
       INCR j
    END IF
  NEXT i
END SUB

SUB AddEnemyTank()
FOR i = 0 to enemycount-1
  IF enemy(i).typ=0 THEN
     enemy(i).typ=ettank
     enemy(i).x=310
     enemy(i).y=183
     enemy(i).vx=-2
     enemy(i).vy=0
     EXIT SUB
  END IF
NEXT i
END SUB

SUB AddEnemyBomb()
FOR i = 0 to enemycount-1
  IF enemy(i).typ=0 THEN
     enemy(i).typ=etbomb
     enemy(i).x=310
     enemy(i).y=20 + CINT(RND(1)*130)
     enemy(i).vx=-3
     enemy(i).vy=0
     EXIT SUB
  END IF
NEXT i
END SUB

SUB AddEnemyPlane()
FOR i = 0 to enemycount-1
  IF enemy(i).typ=0 THEN
     enemy(i).typ=etplane
     enemy(i).x=290
     enemy(i).y=30 + CINT(RND(1)*110)
     enemy(i).vy=-2
     enemy(i).vx=0
     EXIT SUB
  END IF
NEXT i
END SUB

SUB AddPlaneFire(idx AS INTEGER)
FOR i = 0 to firecount-1
  IF fire(i).typ=0 THEN
     fire(i).typ=ftlaser
     fire(i).x=enemy(idx).x-playerw
     fire(i).y=enemy(idx).y+playerh2
     fire(i).vx=-8
     fire(i).vy=0
     fire(i).friend=0
     EXIT SUB
  END IF
NEXT i
END SUB

SUB AddTankFire(idx AS INTEGER)
FOR i = 0 to firecount-1
  IF fire(i).typ=0 THEN
     fire(i).typ=ftsuper
     fire(i).x=enemy(idx).x
     fire(i).y=enemy(idx).y-10
     fire(i).vx=-4
     fire(i).vy=-2
     fire(i).friend=0
     EXIT SUB
  END IF
NEXT i
END SUB

SUB CalcRectForEnemy(idx AS INTEGER, re AS Rect)
  re.rleft = enemy(idx).x
  re.rtop = enemy(idx).y
  IF enemy(idx).typ=etbomb THEN
    DECR re.rleft,enemybombd
    DECR re.rtop,enemybombd
    re.rright = enemy(idx).x
    re.rbottom = enemy(idx).y
  END IF
  IF enemy(idx).typ=ettank THEN
    re.rright = re.rleft + 24
    re.rbottom = re.rtop + 7
  END IF
  IF enemy(idx).typ=etplane THEN
    re.rright = re.rleft + playerw
    re.rbottom = re.rtop + playerh
  END IF
END SUB

SUB CalcRectForFire(idx AS INTEGER, re AS Rect)
  re.rleft = fire(idx).x
  re.rtop = fire(idx).y
  IF fire(idx).typ=ftlaser THEN
    re.rright = re.rleft+laserw
    re.rbottom = re.rtop
  END IF
  IF fire(idx).typ=ftbomb THEN
    DECR re.rleft,bombd
    DECR re.rtop,bombd
    re.rright = re.rleft + bombd
    re.rbottom = re.rtop + bombd
  END IF
  IF fire(idx).typ=ftsuper THEN
    DECR re.rleft, superr
    DECR re.rtop, superr
    re.rright = re.rleft + superd
    re.rbottom = re.rtop + superd
  END IF
END SUB

SUB CalcRectForPlayer(re AS Rect)
  re.rleft = playerx
  re.rtop = playery
  re.rright = re.rleft + playerw
  re.rbottom = re.rtop + playerh
END SUB

FUNCTION IsRectsIntersect(r1 AS Rect, r2 AS Rect) AS INTEGER
  FUNCTION=0

  IF IsXYInRect(r1.rleft,r1.rtop,r2) THEN FUNCTION=1
  IF IsXYInRect(r1.rleft,r1.rbottom,r2) THEN FUNCTION=1
  IF IsXYInRect(r1.rright,r1.rtop,r2) THEN FUNCTION=1
  IF IsXYInRect(r1.rright,r1.rbottom,r2) THEN FUNCTION=1
  IF IsXYInRect(r2.rleft,r2.rtop,r1) THEN FUNCTION=1
  IF IsXYInRect(r2.rleft,r2.rbottom,r1) THEN FUNCTION=1
  IF IsXYInRect(r2.rright,r2.rtop,r1) THEN FUNCTION=1
  IF IsXYInRect(r2.rright,r2.rbottom,r1) THEN FUNCTION=1
END FUNCTION

FUNCTION IsXYInRect(x AS INTEGER, y AS INTEGER, re AS Rect) AS INTEGER
  FUNCTION=0
  IF (re.rleft <= x)AND(x <= re.rright) THEN
    IF (re.rtop <= y)AND(y <= re.rbottom) THEN FUNCTION=1
  END IF
END FUNCTION

SUB DrawWhiteRect(re AS Rect)
  LINE (re.rleft,re.rtop)-(re.rright,re.rtop),15
  LINE (re.rright,re.rtop)-(re.rright,re.rbottom),15
  LINE (re.rright,re.rbottom)-(re.rleft,re.rbottom),15
  LINE (re.rleft,re.rbottom)-(re.rleft,re.rtop),15
END SUB

SUB SwitchPage()
  STATIC pageindex
  SCREEN ,,1-pageindex,pageindex
  pageindex=1-pageindex
END SUB
