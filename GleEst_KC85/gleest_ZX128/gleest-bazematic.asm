                device  zxspectrum128

                org     #7ffc
                nop
                ld      sp, #7fe8

start

mask            db #7a          ;ld  a,d        ;mask
vol_a           db #46          ;ld  b,(hl)     ;vol A
vol_b           db #97          ;sub a          ;vol B
vol_c           db #04          ;inc b          ;vol C +
frq             db #00,00       ;nop : nop      ;env frq
form            db #4a          ;ld  c,d        ;env form

;               xor     a               ;ink 7, paper 0, bright 0
                call    #229b           ;set bordcr
                ld      (23693),a       ;set attr_p
                call    3435            ;cls

                add     hl,hl           ;
                ld      l,a             ;ld     hl,#a100
                exx

loop_ix         ld      hl,#b700
loop
                halt

;--------------------------------------------------- music
                push    hl

                call #387f              ;de = #ffbf  hl = #bf..  bc = #fffd
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
                and     %00000100
                ;add    a,low orn               ; LOW = x&255
                add     a, orn&255
                ld      d,a

                ld      l,a
                ;ld     h,high orn              ; HIGH (x>>8)&255
                ld      h,(orn>>8)&255
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

        ld a,13
        ld (poiu+1),a
                pop     hl
;---------------------------------------------------
dots            ld      bc,#3f06
d_loop
                ld      e,(hl)  :  inc  hl
                ld      d,(hl)  :  inc  hl
                ld      a,(de)
                and     (hl)
                ld      (de),a

                exx

proc               ld   a,L
                ld      e,(hl) :  inc   l
                ld      d,(hl) :  inc   l
                inc     l
                inc     l
                ld      c,(hl) :  inc   l
                ld      b,(hl)
                 ex     de,hl
                add     hl,bc
                 ex     de,hl
                srl     d
                rr      e
                   ld   L,a
                ld      (hl),e
                inc     l
                ld      (hl),d
                inc     l
                  push  de
                and     2
                jr      z,proc

                pop     bc
                ex      (sp),hl

                exx
                ld      a,b
                exx
                cp      #10
                jr      c,dontplot
                ld      bc,#fd40
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
                cp      #c0
                call    c,#22b0
                ld      b, ((sprite-1)>>8)&255          ; HIGH = (x>>8)&255
                cpl
                ld      c,a
                ld      a,(bc)
                or      (hl)
                ld      (hl),a
                cpl

                push    hl
                exx
                pop     de
                ld      (hl),a : dec hl
                ld      (hl),d : dec hl
                ld      (hl),e : inc hl,hl
                ld      a,b
                exx

                rrca :  rrca :  rrca
                or      %11110000
                ld      c,a
                ld      a,(bc)
                ld      (23695),a
                call    #0bdb
dontplot
                pop     hl
                exx
                inc     hl

                djnz    d_loop

                add     hl,bc
                exx
random
                pop     de
                ld      b,#10
backw           sla     e
                rl      d
                 ld     a,d     ;;
                 and    #c0     ;;
                jp      pe,forw
                inc     e
forw            djnz    backw
                ld      a,d
                push    de
                rra
                rr      b
                and     #07
                ld      (hl),b  :  inc  l
                ld      (hl),a  :  inc  l
                jr      nz,random
                exx
        
                bit     6,h
                jp      z,loop
                jp      loop_ix

orn
;       db      #5e, #7e, #4f, #3e
;       db      #76, #5d, #4f, #3b

        db      #6a, #8e, #59, #47
        db      #86, #6b, #59, #42

palette
        db #45,#44,#6,#42,#03,#1

        db %00000001
        db %00000010
        db %00000100
        db %00001000
        db %00010000
        db %00100000
        db %01000000
        db %10000000
sprite

end
