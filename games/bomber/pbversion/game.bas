$DIM ARRAY
DEFINT A-Z

TYPE PointXY
  x AS INTEGER
  y AS INTEGER
END TYPE

TYPE GameObject
  x AS INTEGER
  y AS INTEGER
  vx AS INTEGER
  vy AS INTEGER
  typ AS INTEGER
  friend AS INTEGER
END TYPE

DIM mountain(20) AS PointXY
DIM superv(7) AS PointXY
DIM enemybombr(4) AS PointXY
DIM fire(50) AS GameObject
DIM enemy(50) AS GameObject

REM Позиции гор
DATA 0, 190, 70, 170, 70, 170, 130, 190, 310, 190, 350, 140, 350, 140, 400
DATA 190, 710, 190, 750, 160, 750, 160, 800, 190, 1000, 190, 1040, 150, 1040
DATA 150, 1080, 190, 1060, 170, 1080, 160, 1080, 160, 1120, 190
REM Направления супервыстрела
DATA -6,0,-4,2,-2,4,0,6,2,4,4,2,6,0
REM Векторы лучей бомб
DATA -3,-3,-3,3,3,3,3,-3
mountainsize = 20
firecount = 50
supercount = 7
enemycount = 50
enemybombrcount = 4

global_fired_idx = 0
global_idx = 0
REM Отладочный вывод хитбоксов
showhitzones = 0

FOR i = 0 TO mountainsize-1: READ mountain(i).x, mountain(i).y:  NEXT i
FOR i = 0 TO supercount-1: READ superv(i).y, superv(i).x: NEXT i
FOR i = 0 TO enemybombrcount-1: READ enemybombr(i).x, enemybombr(i).y: NEXT i

REM Установка экрана и экранных страниц отображаемой и активной
SCREEN 7

WorkEntry:
GOSUB MainMenu:

REM Начальные установки
playerx = 100
playery = 100
playerw = 20
playerw2 = 10
playerh = 10
playerh2 = 5
playervx = 0
playervy = 0
playerbasev = 2
stopx1 = 10
stopx2 = 290
stopy1 = 10
stopy2 = 160
laserw = 10
bombr = 3
bombd = 6
superr = 1
superd = 3
laserwait = 0
laserdelay = 10
bombwait = 0
bombdelay = 30
superwait = 0
superdelay = 100
ftlaser = 1
ftbomb = 2
ftsuper = 3
ettank = 1
etbomb = 2
etplane = 3
enemybombr = 5
enemybombd = 10
enemywait = 20
enemymindelay = 30
enemyvardelay = 30
killtimer = 0
score = 0
FOR i = 0 to firecount-1: fire(i).typ=0: NEXT i
FOR i = 0 to enemycount-1: enemy(i).typ=0: NEXT i

RANDOMIZE TIMER

DIM t AS SINGLE
DIM t1 AS SINGLE
REM Главный цикл
GameCicle:
t = TIMER
t1 = t

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
px2 = playerx+playerw
py2 = playery+playerh2
py3 = py2+playerh2
LINE (playerx,playery)-(px2,py2),10
LINE (px2,py2)-(playerx,py3),10
LINE (playerx,py3)-(playerx,playery),10
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
  global_idx = i
  GOSUB CalcGlobalRectForEnemy:
  LINE (global_left,global_top)-(global_right,global_top),15
  LINE (global_right,global_top)-(global_right,global_bottom),15
  LINE (global_right,global_bottom)-(global_left,global_bottom),15
  LINE (global_left,global_bottom)-(global_left,global_top),15
  END IF
NEXT i
FOR i = 0 to firecount-1
  IF fire(i).typ<>0 THEN
  global_idx = i
  GOSUB CalcGlobalRectForFire:
  LINE (global_left,global_top)-(global_right,global_top),15
  LINE (global_right,global_top)-(global_right,global_bottom),15
  LINE (global_right,global_bottom)-(global_left,global_bottom),15
  LINE (global_left,global_bottom)-(global_left,global_top),15
  END IF
NEXT i
GOSUB CalcGlobalRectForPlayer:
LINE (global_left,global_top)-(global_right,global_top),15
LINE (global_right,global_top)-(global_right,global_bottom),15
LINE (global_right,global_bottom)-(global_left,global_bottom),15
LINE (global_left,global_bottom)-(global_left,global_top),15
END IF

REM Информация о готовности
COLOR 7,0
LOCATE 1,1: PRINT "Laser:"
LOCATE 1,10: PRINT "Bomb:"
LOCATE 1,18: PRINT "Super:"
LOCATE 1,27: PRINT "SCORE:"

COLOR 10,0
IF laserwait=0 THEN LOCATE 1,7: PRINT "OK": END IF
IF bombwait=0 THEN LOCATE 1,15: PRINT "OK": END IF
IF superwait=0 THEN LOCATE 1,24: PRINT "OK": END IF

s$=STR$(score)
s$=LTRIM$(s$)
LOCATE 1,33: PRINT s$

REM Переключение страницы
SCREEN ,,1-scr1,scr1
scr1=1-scr1

REM Управление клавиатурой
k$ = INKEY$
   IF k$=CHR$(0)+CHR$(72) THEN
     playervy=-playerbasev
     playervx=0
   END IF
   IF k$=CHR$(0)+CHR$(80) THEN
     playervy=playerbasev
     playervx=0
   END IF
   IF k$=CHR$(0)+CHR$(75) THEN
     playervx=-playerbasev
     playervy=0
   END IF
   IF k$=CHR$(0)+CHR$(77) THEN
     playervx=playerbasev
     playervy=0
   END IF
   IF k$=CHR$(27) THEN WorkEntry:
   IF k$=CHR$(32) THEN
     playervx=0
     playervy=0
   END IF
   IF killtimer=0 THEN
   IF k$=CHR$(90) THEN GOSUB AddFire:
   IF k$=CHR$(122) THEN GOSUB AddFire:
   IF k$=CHR$(88) THEN GOSUB AddBomb:
   IF k$=CHR$(120) THEN GOSUB AddBomb:
   IF k$=CHR$(67) THEN GOSUB AddSuper:
   IF k$=CHR$(99) THEN GOSUB AddSuper:
   END IF

REM Обновление игры

REM Обновление игрока
INCR playerx,playervx
INCR playery,playervy

IF playerx<=stopx1 THEN
  playerx = stopx1
  playervx = 0
END IF

IF playerx>=stopx2 THEN
  playerx = stopx2
  playervx = 0
END IF

IF playery<=stopy1 THEN
  playery = stopy1
  playervy = 0
END IF

IF playery>=stopy2 THEN
  playery = stopy2
  playervy = 0
END IF

GOSUB CalcGlobalRectForPlayer:
global_r1x1 = global_left
global_r1y1 = global_top
global_r1x2 = global_right
global_r1y2 = global_bottom
REM Удар игрока о врагов
FOR i = 0 to enemycount-1
  IF enemy(i).typ<>0 THEN
    global_idx = i
    GOSUB CalcGlobalRectForEnemy:
    global_r2x1 = global_left
    global_r2y1 = global_top
    global_r2x2 = global_right
    global_r2y2 = global_bottom
    GOSUB CalcIsGlobalRect1Rect2Intersect:
    IF global_result=1 THEN
      enemy(i).typ=0
      if killtimer=0 THEN killtimer=36
    END IF
  END IF
NEXT i
REM Удар игрока о снаряды
FOR i = 0 to firecount-1
  IF fire(i).typ<>0 THEN
    IF fire(i).friend=0 THEN
    global_idx = i
    GOSUB CalcGlobalRectForFire:
    global_r2x1 = global_left
    global_r2y1 = global_top
    global_r2x2 = global_right
    global_r2y2 = global_bottom
    GOSUB CalcIsGlobalRect1Rect2Intersect:
    IF global_result=1 THEN
      fire(i).typ=0
      if killtimer=0 THEN killtimer=36
    END IF
    END IF
  END IF
NEXT i

REM Удар врагов о снаряды
FOR i = 0 to enemycount-1
  IF enemy(i).typ<>0 THEN
    global_idx = i
    GOSUB CalcGlobalRectForEnemy:
    global_r1x1 = global_left
    global_r1y1 = global_top
    global_r1x2 = global_right
    global_r1y2 = global_bottom

    FOR j = 0 to firecount-1
      IF (fire(j).typ<>0)AND(fire(j).friend=1) THEN
        global_idx = j
        GOSUB CalcGlobalRectForFire:
        global_r2x1 = global_left
        global_r2y1 = global_top
        global_r2x2 = global_right
        global_r2y2 = global_bottom
        GOSUB CalcIsGlobalRect1Rect2Intersect:
        IF global_result=1 THEN
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
    if enemy(i).y MOD 40 < 2 THEN
      global_fired_idx = i
      GOSUB AddPlaneFire:
    END IF
  END IF
  IF enemy(i).typ=etbomb THEN
    enemy(i).vy=0
    IF enemy(i).y<playery THEN enemy(i).vy=1
    IF enemy(i).y>playery THEN enemy(i).vy=-1
  END IF
  IF enemy(i).typ=ettank THEN
    if enemy(i).x MOD 100 = 0 THEN
      global_fired_idx = i
      GOSUB AddTankFire:
    END IF
  END IF
NEXT i

IF enemywait>0 THEN DECR enemywait

IF enemywait = 0 THEN
  enemywait = enemymindelay + CINT(RND(1)*enemyvardelay)

  tekrnd = CINT(RND(1)*2)
  if tekrnd = 0 THEN GOSUB AddEnemyTank:
  if tekrnd = 1 THEN GOSUB AddEnemyPlane:
  IF tekrnd = 2 THEN GOSUB AddEnemyBomb:
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

GOTO GameCicle:

MainMenu:
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
SCREEN ,,1-scr1,scr1
scr1=1-scr1

MenuKeyWait:
k$ = INKEY$
IF k$=CHR$(32) THEN RETURN
IF k$=CHR$(27) THEN
  SCREEN 0
  END
END IF
GOTO MenuKeyWait:

AddFire:
IF laserwait=0 THEN
  FOR i = 0 to firecount-1
    IF fire(i).typ=0 THEN
       fire(i).typ=ftlaser
       fire(i).x=playerx+playerw
       fire(i).y=playery+playerh2
       fire(i).vx=8
       fire(i).vy=0
       fire(i).friend=1
       laserwait=laserdelay
       RETURN
    END IF
  NEXT i
END IF
RETURN

AddBomb:
IF bombwait=0 THEN
  FOR i = 0 to firecount-1
    IF fire(i).typ=0 THEN
       fire(i).typ=ftbomb
       fire(i).x=playerx+playerw2
       fire(i).y=playery+playerh
       fire(i).vx=playervx
       fire(i).vy=4
       fire(i).friend=1
       bombwait=bombdelay
       RETURN
    END IF
  NEXT i
END IF
RETURN

AddSuper:
IF superwait=0 THEN
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
       IF j=supercount-1 THEN RETURN
       INCR j
    END IF
  NEXT i
END IF
RETURN

AddEnemyTank:
FOR i = 0 to enemycount-1
  IF enemy(i).typ=0 THEN
     enemy(i).typ=ettank
     enemy(i).x=310
     enemy(i).y=183
     enemy(i).vx=-2
     enemy(i).vy=0
     RETURN
  END IF
NEXT i
RETURN

AddEnemyBomb:
FOR i = 0 to enemycount-1
  IF enemy(i).typ=0 THEN
     enemy(i).typ=etbomb
     enemy(i).x=310
     enemy(i).y=20 + CINT(RND(1)*130)
     enemy(i).vx=-3
     enemy(i).vy=0
     RETURN
  END IF
NEXT i
RETURN

AddEnemyPlane:
FOR i = 0 to enemycount-1
  IF enemy(i).typ=0 THEN
     enemy(i).typ=etplane
     enemy(i).x=290
     enemy(i).y=30 + CINT(RND(1)*110)
     enemy(i).vy=-2
     enemy(i).vx=0
     RETURN
  END IF
NEXT i
RETURN

AddPlaneFire:
FOR i = 0 to firecount-1
  IF fire(i).typ=0 THEN
     fire(i).typ=ftlaser
     fire(i).x=enemy(global_fired_idx).x-playerw
     fire(i).y=enemy(global_fired_idx).y+playerh2
     fire(i).vx=-8
     fire(i).vy=0
     fire(i).friend=0
     RETURN
  END IF
NEXT i
RETURN

AddTankFire:
FOR i = 0 to firecount-1
  IF fire(i).typ=0 THEN
     fire(i).typ=ftsuper
     fire(i).x=enemy(global_fired_idx).x
     fire(i).y=enemy(global_fired_idx).y-10
     fire(i).vx=-4
     fire(i).vy=-2
     fire(i).friend=0
     RETURN
  END IF
NEXT i
RETURN

CalcGlobalRectForEnemy:
  global_left = enemy(global_idx).x
  global_top = enemy(global_idx).y
  IF enemy(global_idx).typ=etbomb THEN
    DECR global_left,enemybombd
    DECR global_top,enemybombd
    global_right = enemy(global_idx).x
    global_bottom = enemy(global_idx).y
  END IF
  IF enemy(global_idx).typ=ettank THEN
    global_right = global_left + 24
    global_bottom = global_top + 7
  END IF
  IF enemy(global_idx).typ=etplane THEN
    global_right = global_left + playerw
    global_bottom = global_top + playerh
  END IF
RETURN

CalcGlobalRectForFire:
  global_left = fire(global_idx).x
  global_top = fire(global_idx).y
  IF fire(global_idx).typ=ftlaser THEN
    global_right = global_left+laserw
    global_bottom = global_top
  END IF
  IF fire(global_idx).typ=ftbomb THEN
    DECR global_left,bombd
    DECR global_top,bombd
    global_right = global_left + bombd
    global_bottom = global_top + bombd
  END IF
  IF fire(global_idx).typ=ftsuper THEN
    DECR global_left, superr
    DECR global_top, superr
    global_right = global_left + superd
    global_bottom = global_top + superd
  END IF
RETURN

CalcGlobalRectForPlayer:
  global_left = playerx
  global_top = playery
  global_right = global_left + playerw
  global_bottom = global_top + playerh
RETURN

CalcIsGlobalRect1Rect2Intersect:
  global_x =global_r1x1
  global_y =global_r1y1
  GOSUB CalcIsGlobalXYRect2Intersect:
  IF global_result=1 THEN RETURN

  global_x =global_r1x2
  global_y =global_r1y1
  GOSUB CalcIsGlobalXYRect2Intersect:
  IF global_result=1 THEN RETURN

  global_x =global_r1x1
  global_y =global_r1y2
  GOSUB CalcIsGlobalXYRect2Intersect:
  IF global_result=1 THEN RETURN

  global_x =global_r1x2
  global_y =global_r1y2
  GOSUB CalcIsGlobalXYRect2Intersect:
  IF global_result=1 THEN RETURN

  global_x =global_r2x1
  global_y =global_r2y1
  GOSUB CalcIsGlobalXYRect1Intersect:
  IF global_result=1 THEN RETURN

  global_x =global_r2x2
  global_y =global_r2y1
  GOSUB CalcIsGlobalXYRect1Intersect:
  IF global_result=1 THEN RETURN

  global_x =global_r2x1
  global_y =global_r2y2
  GOSUB CalcIsGlobalXYRect1Intersect:
  IF global_result=1 THEN RETURN

  global_x =global_r2x2
  global_y =global_r2y2
  GOSUB CalcIsGlobalXYRect1Intersect:
  IF global_result=1 THEN RETURN

  global_result=0
RETURN

CalcIsGlobalXYRect2Intersect:
  global_result=0
  IF (global_r2x1 <= global_x)AND(global_x <= global_r2x2) THEN
    IF (global_r2y1 <= global_y)AND(global_y <= global_r2y2) THEN global_result=1
  END IF
RETURN

CalcIsGlobalXYRect1Intersect:
  global_result=0
  IF (global_r1x1 <= global_x)AND(global_x <= global_r1x2) THEN
    IF (global_r1y1 <= global_y)AND(global_y <= global_r1y2) THEN global_result=1
  END IF
RETURN
