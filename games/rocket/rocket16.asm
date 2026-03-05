[CPU 8086]
org 100h
section .text

	call Randomize

; Очистка экрана
	mov ah,09h
	mov dx, clear_screen
	int 21h

; Яркий цвет
	mov dx, bold_text
	int 21h

; Построение базы спрайтов
	mov di,enemyspritebase
	mov ax,enemysprite1
	stosw
	mov ax,enemysprite2
	stosw
	mov ax,enemysprite3
	stosw
	mov ax,enemysprite4
	stosw
	mov ax,enemysprite5
	stosw
	mov ax,enemysprite6
	stosw

	call printCaptions
	call printCounter
	call printFired

	call resetEnemys
	call addEnemy
	call drawEnemy

maincicle:
        call readTimerToAX
	mov [frame],ax

; Обработка ракет
	cmp word [fired1],0
	je nextrocket2

	dec byte [rocketm1]
	cmp byte [rocketm1],0
	jne nextrocket2

	call clearRocket1
	dec byte [rocketx1]
	dec byte [rockety1]
	cmp byte [rockety1],FINISHPOSY
	je delete_rocket1

	mov byte bl,[rocketx1]
	mov byte bh,[rockety1]
	call testAndKillEnemyAtBLBH
	add [counter],ax
	cmp ax,1
	je delete_rocket1

        call drawRocket1
        mov byte [rocketm1],ROCKETDELAY
	jmp nextrocket2

delete_rocket1:
        mov word [fired1],0

nextrocket2:
	cmp word [fired2],0
	je nextrocket3

	dec byte [rocketm2]
	cmp byte [rocketm2],0
	jne nextrocket3

	call clearRocket2
	dec byte [rockety2]
	cmp byte [rockety2],FINISHPOSY
	je delete_rocket2

	mov byte bl,[rocketx2]
	mov byte bh,[rockety2]
	call testAndKillEnemyAtBLBH
	add [counter],ax
	cmp ax,1
	je delete_rocket2

        call drawRocket2
        mov byte [rocketm2],ROCKETDELAY
	jmp nextrocket3

delete_rocket2:
        mov word [fired2],0

nextrocket3:
	cmp word [fired3],0
	je nextrocket4

	dec byte [rocketm3]
	cmp byte [rocketm3],0
	jne nextrocket4

	call clearRocket3
	inc byte [rocketx3]
	dec byte [rockety3]
	cmp byte [rockety3],FINISHPOSY
	je delete_rocket3

	mov byte bl,[rocketx3]
	mov byte bh,[rockety3]
	call testAndKillEnemyAtBLBH
	add [counter],ax
	cmp ax,1
	je delete_rocket3

        call drawRocket3
        mov byte [rocketm3],ROCKETDELAY
	jmp nextrocket4

delete_rocket3:
        mov word [fired3],0

nextrocket4:

; Обработка врагов
	dec byte [enemymove]
	cmp byte [enemymove],0
	jne no_move_enemy

	mov byte [enemymove],ENEMYMOVEDELAY
	call clearOldEnemyCell
	call updateEnemy
	call drawEnemy

no_move_enemy:

	dec byte [enemycreate]
	cmp byte [enemycreate],0
	jne no_create_enemy

	mov byte [enemycreate],ENEMYCREATEDELAY
	call addEnemy
	call drawEnemy
no_create_enemy:

	; Всегда печатает счетчик в цикле
	call printCounter

; Обработка клавиш
	call readKeyAndScanToAX
	cmp ah,SCAN_ESCAPE
	je fin

	cmp ah,SCAN_ESCAPE
	je fin

	cmp ah,SCAN_LEFT
	jne next_key1

	cmp word [fired1],1
	je fin_keys

	inc word [fired]
	mov word [fired1],1
	mov byte [rocketx1],STARTPOSX1
	mov byte [rockety1],STARTPOSY
	mov byte [rocketm1],ROCKETDELAY
	call drawRocket1
	call printFired

	jmp fin_keys

next_key1:
	cmp ah,SCAN_UP
	jne next_key2

	cmp word [fired2],1
	je fin_keys

	inc word [fired]
	mov word [fired2],1
	mov byte [rocketx2],STARTPOSX2
	mov byte [rockety2],STARTPOSY
	mov byte [rocketm2],ROCKETDELAY
	call drawRocket2
	call printFired

	jmp fin_keys

next_key2:
	cmp ah,SCAN_RIGHT
	jne fin_keys

	cmp word [fired3],1
	je fin_keys

	inc word [fired]
	mov word [fired3],1
	mov byte [rocketx3],STARTPOSX3
	mov byte [rockety3],STARTPOSY
	mov byte [rocketm3],ROCKETDELAY
	call drawRocket3
	call printFired

fin_keys:

        ; Скрытие курсора
	mov dh, 25
	mov dl, 0
	mov bh, 0
	mov ah, 2
	int 10h

	mov bx,[frame]
	call waitTimerEqualBX
	jmp maincicle

fin:
; Возврат к нормальному цвету
	mov ah,09h
	mov dx, reset_color
	int 21h

    	ret

%include "proc.asm"

section .data
	msg_counter db 27,'[2;20HCounter:$'
	msg_fired db 27,'[2;40HFired:$'
        msg_controls db 27,'[25;10HUse Left, Up and Right keys to fire rocket and hit enemy flyers$'

	rocket_starter db 27,'[23;38H\|/$'

	clear_screen db 27, '[2J$'
	bold_text db 27, '[1m$'
	color_white db 27, '[37m$'
	color_green db 27, '[32m$'
	color_red db 27, '[31m$'
	reset_color db 27, '[0m$'

        pos_counter db 27,'[2;30H$'
        pos_fired db 27,'[2;46H$'

        counter dw 0
	fired dw 0
	frame dw 0
	fired1 dw 0
	fired2 dw 0
	fired3 dw 0
	rocketx1 db 0
	rockety1 db 0
	rocketx2 db 0
	rockety2 db 0
	rocketx3 db 0
	rockety3 db 0
	rocketm1 db 0
	rocketm2 db 0
	rocketm3 db 0

	enemymove db ENEMYMOVEDELAY
	enemycreate db ENEMYCREATEDELAY

	; SPRITEIDX, X,Y,DX,W
	enemydata db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
        enemydata1 db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
        enemydata2 db 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0
	enemyspritew db 3,3,5,5,7,7
	enemyspritebase dw 0,0,0,0,0,0
	enemysprite1 db '\_/$'
	enemysprite2 db '<=>$'
	enemysprite3 db '/\_/\$'
	enemysprite4 db '<-=->$'
	enemysprite5 db '\__^__/$'
	enemysprite6 db '<>---<>$'

	SCAN_LEFT equ 75
	SCAN_RIGHT equ 77
	SCAN_UP equ 72
	SCAN_ESCAPE equ 1
	STARTPOSY EQU 21
	FINISHPOSY EQU 2
	STARTPOSX1 EQU 36
	STARTPOSX2 EQU 38
	STARTPOSX3 EQU 40
	ROCKETDELAY EQU 4

	ENEMYMOVEDELAY EQU 3
        ENEMYCREATEDELAY EQU 80
	ENEMYSTART EQU 3
	ENEMYDELTA EQU 15
	SPRITECOUNT EQU 6
	ENEMYCOUNT EQU 12
	NOENEMY EQU 64
