

                cpu     z80

hi      function x,(x>>8)&255
lo      function x, x&255
                
                ;org     7ffch
                ;nop
                ;ld      sp, 7fe8h
                
                org     8000h
start

mask            db 7ah          ;ld  a,d        ;mask
vol_a           db 46h          ;ld  b,(hl)     ;vol A
vol_b           db 97h          ;sub a          ;vol B
vol_c           db 04h          ;inc b          ;vol C +
frq             db 00
                db 00           ;nop : nop      ;env frq
form            db 4ah          ;ld  c,d        ;env form

;               xor     a               ;ink 7, paper 0, bright 0
                call    229bh           ;set bordcr
                ld      (23693),a       ;set attr_p
                call    3435            ;cls

                add     hl,hl           ;
                ld      l,a             ;ld     hl,#a100
                exx

loop_ix         ld      hl,0b700h
loop
                halt

;--------------------------------------------------- music


                push    hl

                call 387fh              ;de = #ffbf  hl = #bf..  bc = #fffd
                                        ;            note_count  int_count
                ld      a,(bc)
                inc     a
                and     63
                ld      (bc),a
                jr      nz,next

                inc     (hl)
next
                and     3
                ld      b,a
                ld      a,(hl)
                and     00000100b
                add     a, lo(orn)
                ld      d,a

                ld      l,a
                ld      h, hi(orn)
                ld      a,(hl)
                rrca
                ld      (frq),a

                ld      a,d
                add     a,b
                ld      l,a

                ld      l,(hl)
                add     hl,hl
                ld      (mask-7),hl             ;orn_frq for chan A
                add     hl,hl
                ld      (mask-3),hl             ;orn_frq for chan C

                ld      hl,mask-7
                xor     a
out_ay_1
                ld      b,c
                out     (c),a
                ld      b,e
                outi
                inc     a
poiu            cp      14
                jr      nz,out_ay_1

                ld      a,13 
                ld      (poiu+1),a
xxx1:           
                pop     hl

        
;---------------------------------------------------
dots            ld      bc,3f06h                
d_loop
                ld      e,(hl)  ;:  
                inc     hl
                ld      d,(hl)  ;:  
                inc     hl
                ld      a,(de)
                and     (hl)
                ld      (de),a

                exx

proc            ld      a,L
                ld      e,(hl) ;:  
                inc     l
                ld      d,(hl) ;:  
                inc     l
                inc     l
                inc     l
                ld      c,(hl) ;:  
                inc     l
                ld      b,(hl)
                 ex     de,hl
                add     hl,bc
                 ex     de,hl
                srl     d
                rr      e
                ld      L,a
                ld      (hl),e
                inc     l
                ld      (hl),d
                inc     l
                push    de
                and     2
                jr      z,proc

                pop     bc
                ex      (sp),hl

                exx
                ld      a,b
                exx
                cp      10h
                jr      c,dontplot
                ld      bc,0fd40h
                add     hl,bc
                srl     h
                jr      nz,dontplot
                rr      l
                ld      c,L
                ld      a,d
                add     a,b
                srl     a
                jr      nz,dontplot
plot
                ld      a,e
                rra
                cp      0c0h
                
                ;Subroutine     zum     Berechnen einer 'PIXEL'-Adresse
                ;auf dem Bildschirm
                ;Aufruf von     POINT und PLOT mit Adresse des Punktes in
                ;BC. Bei RETURN enthaelt HL     die     Adresse des     Bytes im ent-
                ;sprechenden Bildschirmbereich und A die Bitposition des
                ;Punktes in     diesem Byte
                
                call    c,22b0h
                ld      b,hi(sprite-1)
                cpl
                ld      c,a
                ld      a,(bc)
                or      (hl)
                ld      (hl),a
                cpl

                push    hl
                exx
                pop     de
                ld      (hl),a ;: 
                dec hl
                ld      (hl),d ;: 
                dec hl
                ld      (hl),e ;: 
                inc     hl
                inc     hl
                ld      a,b
                exx

                rrca ;: 
                rrca ;: 
                rrca
                or      11110000b
                ld      c,a
                ld      a,(bc)
                ld      (23695),a
                
                ;Subroutine     zum     Setzen der Attribute
                ;The appropriate attribute byte is identified and fetched. The new value is formed by manipulating the old value, ATTR-T, MASK-T and
                ;P-FLAG. Finally this new value is copied to the attribute area 
                
                call    0bdbh   
dontplot
                pop     hl
                exx
                inc     hl

                djnz    d_loop

                add     hl,bc
                exx
random
                pop     de
                ld      b,10h
backw           sla     e
                rl      d
                 ld     a,d     ;;
                 and    0c0h    ;;
                jp      pe,forw
                inc     e
forw            djnz    backw
                ld      a,d
                push    de
                rra
                rr      b
                and     07h
                ld      (hl),b  ;:  
                inc     l
                ld      (hl),a  ;:  
                inc     l
                jr      nz,random
                exx
        
                bit     6,h
                jp      z,loop
                jp      loop_ix

orn     
;       db      #5e, #7e, #4f, #3e
;       db      #76, #5d, #4f, #3b

        db      6ah, 8eh, 59h, 47h
        db      86h, 6bh, 59h, 42h

palette
        db 45h,44h,6h,42h,03h,1h

        db 00000001b
        db 00000010b
        db 00000100b
        db 00001000b
        db 00010000b
        db 00100000b
        db 01000000b
        db 10000000b
sprite

end

        if 1=0
;-------------------------------------------------------------
        display "------------------------------"
        display "start:  ",/A,start," bytes"
        display "total:  ",/A,end-start," bytes"
        display "------------------------------"

        savebin "GleEst.bin",start,end-start
        ;savetap "GleEst.tap", start
        ;savetrd "GleEst.trd","gleest.C",32768,256
        
        endif

