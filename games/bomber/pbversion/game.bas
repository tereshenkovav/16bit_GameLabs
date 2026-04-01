DEFINT A-Z
DIM mountainx(20)
DIM mountainy(20)
DIM firex(50)
DIM firey(50)
DIM firevx(50)
DIM firevy(50)
DIM firetype(50)
DIM firefriend(50)
DIM supervx(7)
DIM supervy(7)
DIM enemyx(50)
DIM enemyy(50)
DIM enemytype(50)
DIM enemyvx(50)
DIM enemyvy(50)
DIM enemybombrx(4)
DIM enemybombry(4)

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

FOR i = 0 TO mountainsize-1
  READ mountainx(i)
  READ mountainy(i)
NEXT i

FOR i = 0 TO supercount-1
  READ supervy(i)
  READ supervx(i)
NEXT i

FOR i = 0 TO enemybombrcount-1
  READ enemybombrx(i)
  READ enemybombry(i)
NEXT i

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
FOR i = 0 to firecount-1
  firetype(i)=0
NEXT i
FOR i = 0 to enemycount-1
  enemytype(i)=0
NEXT i

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

i=0
WHILE i<mountainsize
  i1=i+1
  mountainx1 = mountainx(i)
  mountainy1 = mountainy(i)
  mountainx2 = mountainx(i1)
  mountainy2 = mountainy(i1)
  IF mountainx1>-100 THEN
   IF mountainx1<420 THEN
    IF mountainx2>-100 THEN
     IF mountainx2<420 THEN
       LINE (mountainx1,mountainy1)-(mountainx2,mountainy2),6
     END IF
    END IF
   END IF
  END IF
  i=i+2
WEND

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
  IF firetype(i)=ftlaser THEN
    firex1 = firex(i)
    firex2 = firex1+laserw
    firey1 = firey(i)
    LINE (firex1,firey1)-(firex2,firey1),12
  END IF
  IF firetype(i)=ftbomb THEN
    firex1 = firex(i)
    firex1 = firex1-bombr
    firey1 = firey(i)
    firey1 = firey1-bombr
    CIRCLE (firex1,firey1),bombr,12
  END IF
  IF firetype(i)=ftsuper THEN
    firex1 = firex(i)
    firey1 = firey(i)
    firex2 = firex(i)
    firey2 = firey(i)
    firex1 = firex1 - superr
    firex2 = firex2 + superr
    firey1 = firey1 - superr
    firey2 = firey2 + superr
    LINE (firex1,firey1)-(firex2,firey2),12
    LINE (firex2,firey1)-(firex1,firey2),12
  END IF
NEXT i

REM Вывод врагов
FOR i = 0 to enemycount-1
  IF enemytype(i)=ettank THEN
    enemyx1 = enemyx(i)
    enemyx2 = enemyx1+4
    enemyx3 = enemyx2+16
    enemyx4 = enemyx3+4
    enemyy1 = enemyy(i)
    enemyy2 = enemyy1+7

    LINE (enemyx1,enemyy2)-(enemyx2,enemyy1),14
    LINE (enemyx2,enemyy1)-(enemyx3,enemyy1),14
    LINE (enemyx3,enemyy1)-(enemyx4,enemyy2),14
    LINE (enemyx4,enemyy2)-(enemyx1,enemyy2),14

    enemyx1 = enemyx(i)
    enemyy1 = enemyy(i)
    enemyx1 = enemyx1 + 16
    enemyx2 = enemyx1 - 9
    enemyy2 = enemyy1 - 6
    LINE (enemyx1,enemyy1)-(enemyx2,enemyy2),14
  END IF
  IF enemytype(i)=etbomb THEN
    enemyx1 = enemyx(i)
    enemyy1 = enemyy(i)
    enemyx1 = enemyx1 - enemybombr
    enemyy1 = enemyy1 - enemybombr
    CIRCLE (enemyx1,enemyy1),enemybombr,14
    FOR j = 0 TO enemybombrcount-1
      enemyx1 = enemyx(i)
      enemyy1 = enemyy(i)
      enemyx1 = enemyx1 - enemybombr
      enemyy1 = enemyy1 - enemybombr
      enemyx1 = enemyx1 + enemybombrx(j)
      enemyy1 = enemyy1 + enemybombry(j)
      enemyx2 = enemyx1 + enemybombrx(j)
      enemyy2 = enemyy1 + enemybombry(j)
      LINE (enemyx1,enemyy1)-(enemyx2,enemyy2),14
    NEXT j
  END IF
  IF enemytype(i)=etplane THEN
   enemyx1 = enemyx(i)
   enemyy1 = enemyy(i)
   enemyx2 = enemyx1+playerw
   enemyy2 = enemyy1+playerh2
   enemyy3 = enemyy2+playerh2
   LINE (enemyx2,enemyy1)-(enemyx1,enemyy2),14
   LINE (enemyx1,enemyy2)-(enemyx2,enemyy3),14
   LINE (enemyx2,enemyy3)-(enemyx2,enemyy1),14
  END IF
NEXT i

IF showhitzones=1 THEN
FOR i = 0 to enemycount-1
  IF enemytype(i)<>0 THEN
  global_idx = i
  GOSUB CalcGlobalRectForEnemy:
  LINE (global_left,global_top)-(global_right,global_top),15
  LINE (global_right,global_top)-(global_right,global_bottom),15
  LINE (global_right,global_bottom)-(global_left,global_bottom),15
  LINE (global_left,global_bottom)-(global_left,global_top),15
  END IF
NEXT i
FOR i = 0 to firecount-1
  IF firetype(i)<>0 THEN
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
LOCATE 1,1
PRINT "Laser:"
LOCATE 1,10
PRINT "Bomb:"
LOCATE 1,18
PRINT "Super:"
LOCATE 1,27
PRINT "SCORE:"

COLOR 10,0
IF laserwait=0 THEN
  LOCATE 1,7
  PRINT "OK"
END IF

IF bombwait=0 THEN
  LOCATE 1,15
  PRINT "OK"
END IF

IF superwait=0 THEN
  LOCATE 1,24
  PRINT "OK"
END IF

s$=STR$(score)
s$=LTRIM$(s$)
LOCATE 1,33
PRINT s$

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
   IF k$=CHR$(90) THEN
     GOSUB AddFire:
   END IF
   IF k$=CHR$(122) THEN
     GOSUB AddFire:
   END IF
   IF k$=CHR$(88) THEN
     GOSUB AddBomb:
   END IF
   IF k$=CHR$(120) THEN
     GOSUB AddBomb:
   END IF
   IF k$=CHR$(67) THEN
     GOSUB AddSuper:
   END IF
   IF k$=CHR$(99) THEN
     GOSUB AddSuper:
   END IF
   END IF

REM Обновление игры

REM Обновление игрока
playerx = playerx+playervx
playery = playery+playervy

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
  IF enemytype(i)<>0 THEN
    global_idx = i
    GOSUB CalcGlobalRectForEnemy:
    global_r2x1 = global_left
    global_r2y1 = global_top
    global_r2x2 = global_right
    global_r2y2 = global_bottom
    GOSUB CalcIsGlobalRect1Rect2Intersect:
    IF global_result=1 THEN
      enemytype(i)=0
      if killtimer=0 THEN
        killtimer=36
      END IF
    END IF
  END IF
NEXT i
REM Удар игрока о снаряды
FOR i = 0 to firecount-1
  IF firetype(i)<>0 THEN
    IF firefriend(i)=0 THEN
    global_idx = i
    GOSUB CalcGlobalRectForFire:
    global_r2x1 = global_left
    global_r2y1 = global_top
    global_r2x2 = global_right
    global_r2y2 = global_bottom
    GOSUB CalcIsGlobalRect1Rect2Intersect:
    IF global_result=1 THEN
      firetype(i)=0
      if killtimer=0 THEN
        killtimer=36
      END IF
    END IF
    END IF
  END IF
NEXT i

REM Удар врагов о снаряды
FOR i = 0 to enemycount-1
  IF enemytype(i)<>0 THEN
    global_idx = i
    GOSUB CalcGlobalRectForEnemy:
    global_r1x1 = global_left
    global_r1y1 = global_top
    global_r1x2 = global_right
    global_r1y2 = global_bottom

    FOR j = 0 to firecount-1
      IF firetype(j)<>0 THEN
      IF firefriend(j)=1 THEN
        global_idx = j
        GOSUB CalcGlobalRectForFire:
        global_r2x1 = global_left
        global_r2y1 = global_top
        global_r2x2 = global_right
        global_r2y2 = global_bottom
        GOSUB CalcIsGlobalRect1Rect2Intersect:
        IF global_result=1 THEN
          IF enemytype(i)=ettank THEN
            score=score+400
          END IF
          IF enemytype(i)=etplane THEN
            score=score+200
          END IF
          IF enemytype(i)=etbomb THEN
            score=score+100
          END IF
          enemytype(i)=0
          firetype(j)=0
        END IF
      END IF
      END IF
    NEXT j
  END IF
NEXT i

REM Обновление выстрелов
FOR i = 0 to firecount-1
  IF firetype(i)<>0 THEN
    firex(i)=firex(i)+firevx(i)
    firey(i)=firey(i)+firevy(i)
    IF firex(i)>=320 THEN
      firetype(i)=0
    END IF
    IF firex(i)<=0 THEN
      firetype(i)=0
    END IF
    IF firey(i)>=190 THEN
      firetype(i)=0
    END IF
    IF firey(i)<=0 THEN
      firetype(i)=0
    END IF
  END IF
NEXT i
IF laserwait>0 THEN
  laserwait=laserwait-1
END IF
IF bombwait>0 THEN
  bombwait=bombwait-1
END IF
IF superwait>0 THEN
  superwait=superwait-1
END IF

REM Обновление врагов
FOR i = 0 to enemycount-1
  IF enemytype(i)<>0 THEN
    enemyx(i)=enemyx(i)+enemyvx(i)
    enemyy(i)=enemyy(i)+enemyvy(i)
    IF enemyx(i)>=320 THEN
      enemytype(i)=0
    END IF
    IF enemyx(i)<=0 THEN
      enemytype(i)=0
    END IF
    IF enemyy(i)>=190 THEN
      enemytype(i)=0
    END IF
    IF enemyy(i)<=0 THEN
      enemytype(i)=0
    END IF
  END IF
  IF enemytype(i)=etplane THEN
    IF enemyy(i)>=stopy2 THEN
      enemyvy(i)=-enemyvy(i)
    END IF
    IF enemyy(i)<=stopy1 THEN
      enemyvy(i)=-enemyvy(i)
    END IF
    tekrnd = enemyy(i)
    tekrnd = tekrnd MOD 40
    if tekrnd < 2 THEN
      global_fired_idx = i
      GOSUB AddPlaneFire:
    END IF
  END IF
  IF enemytype(i)=etbomb THEN
    enemyvy(i)=0
    IF enemyy(i)<playery THEN
      enemyvy(i)=1
    END IF
    IF enemyy(i)>playery THEN
      enemyvy(i)=-1
    END IF
  END IF
  IF enemytype(i)=ettank THEN
    tekrnd = enemyx(i)
    tekrnd = tekrnd MOD 100
    if tekrnd = 0 THEN
      global_fired_idx = i
      GOSUB AddTankFire:
    END IF
  END IF
NEXT i

IF enemywait>0 THEN
  enemywait=enemywait-1
END IF

IF enemywait = 0 THEN
  tekrnd = CINT(RND(1)*enemyvardelay)
  enemywait = enemymindelay + tekrnd

  tekrnd = CINT(RND(1)*2)
  if tekrnd = 0 THEN
    GOSUB AddEnemyTank:
  END IF
  if tekrnd = 1 THEN
    GOSUB AddEnemyPlane:
  END IF
  IF tekrnd = 2 THEN
    GOSUB AddEnemyBomb:
  END IF
END IF

REM Прокрутка гор
FOR i=0 to mountainsize-1
  mountainx(i) = mountainx(i)-2
  IF mountainx(i)<-300 THEN
    mountainx(i)=mountainx(i)+1400
  END IF
NEXT i

IF killtimer>0 THEN
  killtimer=killtimer-1
  IF killtimer=0 THEN WorkEntry:
END IF
REM Ожидание кадра
WHILE t1=t
  t1=TIMER
WEND

GOTO GameCicle:

MainMenu:
CLS

COLOR 15,0
LOCATE 5,5
PRINT "BASIC-written game prototype"
LOCATE 6,7
PRINT "for 16bit DOS realmode"

LOCATE 8,5
PRINT "Controls:"
LOCATE 9,7
PRINT "Arrows - moving"
LOCATE 10,7
PRINT "Space - stop"
LOCATE 11,7
PRINT "Z - laser"
LOCATE 12,7
PRINT "X - bomb"
LOCATE 13,7
PRINT "C - superfire"

LOCATE 15,5
PRINT "Press Space to start game"
LOCATE 16,7
PRINT "or Escape to exit"

REM Переключение страницы
SCREEN ,,1-scr1,scr1
scr1=1-scr1

MenuKeyWait:
k$ = INKEY$
IF k$=CHR$(32) THEN
  RETURN
END IF
IF k$=CHR$(27) THEN
  SCREEN 0
  END
END IF
GOTO MenuKeyWait:

AddFire:
IF laserwait=0 THEN
  FOR i = 0 to firecount-1
    IF firetype(i)=0 THEN
       firetype(i)=ftlaser
       firex(i)=playerx+playerw
       firey(i)=playery+playerh2
       firevx(i)=8
       firevy(i)=0
       firefriend(i)=1
       laserwait=laserdelay
       RETURN
    END IF
  NEXT i
END IF
RETURN

AddBomb:
IF bombwait=0 THEN
  FOR i = 0 to firecount-1
    IF firetype(i)=0 THEN
       firetype(i)=ftbomb
       firex(i)=playerx+playerw2
       firey(i)=playery+playerh2
       firey(i)=firey(i)+playerh2
       firevx(i)=playervx
       firevy(i)=4
       firefriend(i)=1
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
    IF firetype(i)=0 THEN
       firetype(i)=ftsuper
       firex(i)=playerx+playerw
       firey(i)=playery+playerh2
       firevx(i)=supervx(j)
       firevx(i)=firevx(i)+playervx
       firevy(i)=supervy(j)
       firevy(i)=firevy(i)+playervy
       firefriend(i)=1
       IF j=supercount-1 THEN
         RETURN
       END IF
       j=j+1
    END IF
  NEXT i
END IF
RETURN

AddEnemyTank:
FOR i = 0 to enemycount-1
  IF enemytype(i)=0 THEN
     enemytype(i)=ettank
     enemyx(i)=310
     enemyy(i)=183
     enemyvx(i)=-2
     enemyvy(i)=0
     RETURN
  END IF
NEXT i
RETURN

AddEnemyBomb:
FOR i = 0 to enemycount-1
  IF enemytype(i)=0 THEN
     enemytype(i)=etbomb
     tekrnd = RND(0)
     tekrnd = tekrnd MOD 130
     enemyx(i)=310
     enemyy(i)=20 + tekrnd
     enemyvx(i)=-3
     enemyvy(i)=0
     RETURN
  END IF
NEXT i
RETURN

AddEnemyPlane:
FOR i = 0 to enemycount-1
  IF enemytype(i)=0 THEN
     enemytype(i)=etplane
     tekrnd = RND(0)
     tekrnd = tekrnd MOD 110
     enemyx(i)=290
     enemyy(i)=30 + tekrnd
     enemyvy(i)=-2
     enemyvx(i)=0
     RETURN
  END IF
NEXT i
RETURN

AddPlaneFire:
FOR i = 0 to firecount-1
  IF firetype(i)=0 THEN
     firetype(i)=ftlaser
     efirex=enemyx(global_fired_idx)
     efirex=efirex-playerw
     firex(i)=efirex
     efirey=enemyy(global_fired_idx)
     efirey=efirey+playerh2
     firey(i)=efirey
     firevx(i)=-8
     firevy(i)=0
     firefriend(i)=0
     RETURN
  END IF
NEXT i
RETURN

AddTankFire:
FOR i = 0 to firecount-1
  IF firetype(i)=0 THEN
     firetype(i)=ftsuper
     firex(i)=enemyx(global_fired_idx)
     efirey=enemyy(global_fired_idx)
     efirey=efirey - 10
     firey(i)=efirey
     firevx(i)=-4
     firevy(i)=-2
     firefriend(i)=0
     RETURN
  END IF
NEXT i
RETURN

CalcGlobalRectForEnemy:
  global_left = enemyx(global_idx)
  global_top = enemyy(global_idx)
  IF enemytype(global_idx)=etbomb THEN
    global_left = global_left - enemybombd
    global_top = global_top - enemybombd
    global_right = enemyx(global_idx)
    global_bottom = enemyy(global_idx)
  END IF
  IF enemytype(global_idx)=ettank THEN
    global_right = global_left + 24
    global_bottom = global_top + 7
  END IF
  IF enemytype(global_idx)=etplane THEN
    global_right = global_left + playerw
    global_bottom = global_top + playerh
  END IF
RETURN

CalcGlobalRectForFire:
  global_left = firex(global_idx)
  global_top = firey(global_idx)
  IF firetype(global_idx)=ftlaser THEN
    global_right = global_left+laserw
    global_bottom = global_top
  END IF
  IF firetype(global_idx)=ftbomb THEN
    global_left = global_left - bombd
    global_top = global_top - bombd
    global_right = global_left + bombd
    global_bottom = global_top + bombd
  END IF
  IF firetype(global_idx)=ftsuper THEN
    global_left = global_left - superr
    global_top = global_top - superr
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
  IF global_result=1 THEN
    RETURN
  END IF

  global_x =global_r1x2
  global_y =global_r1y1
  GOSUB CalcIsGlobalXYRect2Intersect:
  IF global_result=1 THEN
    RETURN
  END IF

  global_x =global_r1x1
  global_y =global_r1y2
  GOSUB CalcIsGlobalXYRect2Intersect:
  IF global_result=1 THEN
    RETURN
  END IF

  global_x =global_r1x2
  global_y =global_r1y2
  GOSUB CalcIsGlobalXYRect2Intersect:
  IF global_result=1 THEN
    RETURN
  END IF

  global_x =global_r2x1
  global_y =global_r2y1
  GOSUB CalcIsGlobalXYRect1Intersect:
  IF global_result=1 THEN
    RETURN
  END IF

  global_x =global_r2x2
  global_y =global_r2y1
  GOSUB CalcIsGlobalXYRect1Intersect:
  IF global_result=1 THEN
    RETURN
  END IF

  global_x =global_r2x1
  global_y =global_r2y2
  GOSUB CalcIsGlobalXYRect1Intersect:
  IF global_result=1 THEN
    RETURN
  END IF

  global_x =global_r2x2
  global_y =global_r2y2
  GOSUB CalcIsGlobalXYRect1Intersect:
  IF global_result=1 THEN
    RETURN
  END IF

  global_result=0
RETURN

CalcIsGlobalXYRect2Intersect:
  global_result=0
  IF global_r2x1 <= global_x THEN
    IF global_x <= global_r2x2 THEN
      IF global_r2y1 <= global_y THEN
        IF global_y <= global_r2y2 THEN
          global_result=1
        END IF
      END IF
    END IF
  END IF
RETURN

CalcIsGlobalXYRect1Intersect:
  global_result=0
  IF global_r1x1 <= global_x THEN
    IF global_x <= global_r1x2 THEN
      IF global_r1y1 <= global_y THEN
        IF global_y <= global_r1y2 THEN
          global_result=1
        END IF
      END IF
    END IF
  END IF
RETURN
