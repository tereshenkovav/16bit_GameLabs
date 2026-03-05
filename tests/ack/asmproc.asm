.sect .text
.align 2
.define _testasmproc
_testasmproc:
   movb ah,02
   movb dl,'A'
   int 0x21

   movb ah,02
   movb dl,'S'
   int 0x21

   movb ah,02
   movb dl,'M'
   int 0x21

   ret
