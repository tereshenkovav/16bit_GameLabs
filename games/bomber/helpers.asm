SECTION .TEXT

global clear_screen7
clear_screen7:

  mov ax,0A000h
  mov es,ax
  mov di,0
  mov ax,0
  mov cx,4000
  rep stosw

retf
