printIntAX:
    ; Сохраняем переданное число в стек
    push ax

; Заполняем пробелом буфер
    mov cx,5
    mov di,buf
    mov al,0
    rep stosb

; Смещаемся в конец буфера
    mov di,buf
    add di,5

; Выставляем значения из параметров и деление на 10
    pop ax
    mov cx,10

; Циклом деления на заданную базу, переводим в систему счисления
sloop:
    mov dx,0
    div cx
    add dl,'0'
    mov [di],dl
    dec di

    cmp ax,0
    jne sloop

    mov ah,09h
    mov dx, buf
    int 21h

ret

buf db '      $'

printCounter:
	mov ah,09h

	mov dx, pos_counter
	int 21h

	mov dx, color_green
	int 21h

	mov ax,[counter]
	call printIntAX

	ret

printFired:
	mov ah,09h

	mov dx, pos_fired
	int 21h

	mov dx, color_green
	int 21h

	mov ax,[fired]
	call printIntAX

	ret

printCaptions:
; Белый цвет
	mov ah,09h
	mov dx, color_white
	int 21h

; Надписи
	mov dx, msg_counter
	int 21h
	mov dx, msg_fired
	int 21h
	mov dx, msg_controls
	int 21h

; Стартер ракеты
	mov dx, rocket_starter
	int 21h

	ret

readKeyAndScanToAX:
	mov ah,1
	int 16h
	jz nokey
	mov ax,0
	int 16h
	ret
nokey:
	mov ax,0
	ret

readTimerToAX:
	mov ah,0
	int 1Ah
	mov ax,dx
	ret

waitTimerEqualBX:
	mov ah,0
timercicle:
	int 1Ah
	cmp bx,dx
	je timercicle
	ret

drawRocket1:
	mov ah,09h

	mov dx, color_red
	int 21h

	mov dh, [rockety1]
	mov dl, [rocketx1]
	mov bh, 0
	mov ah, 2
	int 10h

	mov ah,02h
	mov dl,'\'
	int 21h

	ret

drawRocket2:
	mov ah,09h

	mov dx, color_red
	int 21h

	mov dh, [rockety2]
	mov dl, [rocketx2]
	mov bh, 0
	mov ah, 2
	int 10h

	mov ah,02h
	mov dl,'|'
	int 21h

	ret

drawRocket3:
	mov ah,09h

	mov dx, color_red
	int 21h

	mov dh, [rockety3]
	mov dl, [rocketx3]
	mov bh, 0
	mov ah, 2
	int 10h

	mov ah,02h
	mov dl,'/'
	int 21h

	ret

clearRocket1:
	mov ah,09h

	mov dh, [rockety1]
	mov dl, [rocketx1]
	mov bh, 0
	mov ah, 2
	int 10h

	mov ah,02h
	mov dl,' '
	int 21h

	ret

clearRocket2:
	mov ah,09h

	mov dh, [rockety2]
	mov dl, [rocketx2]
	mov bh, 0
	mov ah, 2
	int 10h

	mov ah,02h
	mov dl,' '
	int 21h

	ret

clearRocket3:
	mov ah,09h

	mov dh, [rockety3]
	mov dl, [rocketx3]
	mov bh, 0
	mov ah, 2
	int 10h

	mov ah,02h
	mov dl,' '
	int 21h

	ret

resetEnemys:
	mov di,enemydata
	mov cx,ENEMYCOUNT
cicle_reset_enemy:
	mov al,NOENEMY
	stosb
	mov al,0
	stosb
	stosb
	stosb
	stosb
	loop cicle_reset_enemy
	ret

addEnemy:
	mov si,enemydata
	mov cx,ENEMYCOUNT
cicle_add_enemy:
	mov di,si
	lodsb
	cmp al,NOENEMY
	jne next_add_enemy

	mov al,SPRITECOUNT
	call genRndByAL
        xor bx,bx
	mov bl,al ; save sprite index
	stosb

	mov al,0 ; X
	stosb

	mov al,ENEMYDELTA
	call genRndByAL
	add al,ENEMYSTART
	stosb

	mov al,1 ; DX
	stosb
	mov al,[enemyspritew+bx] ; W
	stosb

	ret
next_add_enemy:
	add si,4
	loop cicle_add_enemy
	ret

updateEnemy:
	mov si,enemydata
	mov cx,ENEMYCOUNT
cicle_update_enemy:
	lodsb
	cmp al,NOENEMY
	je next_update_enemy

	mov di,si
	lodsb ; X
	add al,1
	stosb

	cmp al,71
	jne update_enemy_ok

	dec di
	dec di
	mov al, NOENEMY
	stosb

update_enemy_ok:

	sub si,1
next_update_enemy:
	add si,4
	loop cicle_update_enemy
	ret

drawEnemy:
	mov ah,09h

	mov dx, color_green
	int 21h

	mov si,enemydata
	mov cx,ENEMYCOUNT
cicle_draw_enemy:
        xor ax,ax
	lodsb
	cmp al,NOENEMY
	je next_draw_enemy

	push ax ; index of sprite
	lodsb
	mov dl,al ; X
	lodsb
	mov dh,al ; Y
	lodsb    ; DX
	lodsb    ; W

	mov bh, 0
	mov ah, 2
	int 10h

	pop ax
	mov bx, enemyspritebase
	add bx,ax
	add bx,ax
	mov dx,[bx]
	mov ah,09h
	int 21h

	sub si,4
next_draw_enemy:
	add si,4
	loop cicle_draw_enemy
	ret

clearOldEnemyCell:
	mov si,enemydata
	mov cx,ENEMYCOUNT
cicle_old_enemy:
        xor ax,ax
	lodsb
	cmp al,NOENEMY
	je next_old_enemy

	lodsb
	mov dl,al ; X
	lodsb
	mov dh,al ; Y
	lodsb    ; DX
	lodsb    ; W
	
	mov bh, 0
	mov ah, 2
	int 10h

	; Полная очистка по зоне
	push cx
	xor cx,cx
	mov cl,al
	mov ah,02h
	mov dl,' '
cicle_clear_zone:
	int 21h
	loop cicle_clear_zone
	pop cx

	sub si,4
next_old_enemy:
	add si,4
	loop cicle_old_enemy
	ret

testAndKillEnemyAtBLBH:
	mov si,enemydata
	mov cx,ENEMYCOUNT
cicle_test_enemy:
	mov di,si
	lodsb
	cmp al,NOENEMY
	je next_test_enemy

	lodsb ; X
	mov dl,al
	lodsb ; Y
	mov dh,al
	lodsb ; dx
	lodsb ; W

	cmp bh,dh ; Сравнение по Y
	jne test_enemy_ok

	cmp bl,dl ; Сравнение по X левого края
	jl test_enemy_ok

	add dl,al ; X + W
	cmp bl,dl ; Сравнение по X правого края
	jg test_enemy_ok

	sub dl,al ; X

; Очистка на экране

	mov bh, 0
	mov ah, 2
	int 10h

	; Полная очистка по зоне
	push cx
	xor cx,cx
	mov cl,al
	mov ah,02h
	mov dl,' '
cicle_clear_zone1:
	int 21h
	loop cicle_clear_zone1
	pop cx

; Очистка в массиве
	mov al, NOENEMY
	stosb
	mov ax,1; killed
        ret

test_enemy_ok:

	sub si,4
next_test_enemy:
	add si,4
	loop cicle_test_enemy
	mov ax,0 ; no killed
	ret

rndseed dw 0

Randomize:
  call readTimerToAX
  mov [rndseed],ax
  ret

genRndByAL:
  push ax
  push cx

  mov ax,[rndseed]
  mov cl,7
  shl ax,cl
  xor ax,[rndseed]
  mov [rndseed],ax

  mov cl,9
  shr ax,cl
  xor ax,[rndseed]
  mov [rndseed],ax

  mov cl,8
  shl ax,cl
  xor ax,[rndseed]
  mov [rndseed],ax

  pop cx
 ; Здесь делим не ax, а только младший байт его, иначе переполнимся
  mov ah,0

  pop dx
  mov dh,0
  div dl
  mov al,ah

  ret
