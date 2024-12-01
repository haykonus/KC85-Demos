;------------------------------------------------------------------------------
; Titel:                GleEst für KC85/4
;
; Erstellt:             29.11.2024
; Letzte Änderung:      01.12.2024
;------------------------------------------------------------------------------ 

        cpu     z80

hi      function x,(x>>8)&255
lo      function x, x&255


        ifndef  BASE
                BASE:   set     0200H   
        endif   
                org     BASE
        
        db      1
        db      7Fh,7Fh
        db      'GLEEST'
        db      1
        
        call    cls
        
;------------------------------------------------------------------------------
        
        ; Start GleEst
start:  
        DI
        ;ld      sp, stack
        ld      hl, buffer1
        
        exx

        loop_ix:

                ld      hl,buffer2
                loop:   
                        ;ld     bc,10FFh        ; nur wenige Punkte (für Test)
                        ld      bc,3F06h        ; BH = Abstand Punkte, BL = Anzahl Punkte 
                        
                        d_loop:
                                ;
                                ; Pixel löschen
                                ;
                                
                                ld      e,(hl)          ;BWS lo holen
                                inc     hl
                                
                                ld      d,(hl)          ;BWS hi holen
                                inc     hl
                                                                                   
                                ld      a,(de)          ;BWS-Byte holen (t)     
                                and     (hl)            ;mit BWS-Byte (t-1) kombinieren (Bits löschen)                                               
                                ld      (de),a          ;BWS schreiben 
                                
                                exx                     
                                
                                proc:   ld      a,L
                                
                                        ld      e,(hl)   
                                        inc     l
                                        
                                        ld      d,(hl) 
                                        inc     l
                                        
                                        inc     l
                                        inc     l
                                        
                                        ld      c,(hl)  
                                        inc     l
                                        
                                        ld      b,(hl)
                                        ex      de,hl
                                        add     hl,bc
                                        ex      de,hl
                                        srl     d
                                        rr      e
                                        ld      L,a
                                        
                                        ld      (hl),e
                                        inc     l
                                        
                                        ld      (hl),d
                                        inc     l
                                        
                                        push    de
                                        and     2       
                                        
                                jr      z, proc

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
                                
                        plot:
                                ld      a,e
                                rra
                                cp      0ffh            ; Y max  
                                
                                ld      b,a
                                
                                ;
                                ; Pixel schreiben
                                ;
                                
                                ; XPY_to_VRAM
                                ; in:  BC = Y,X 
                                ; out: HL = VRAM, A = Bitpos (3-Bit binär)
                                
                                call    XPY_to_VRAM             

                                ld      b,hi(sprite-1)          
                                cpl
                                ld      c,a             
                                ld      a,(bc)          ; BWS-Byte holen
                                or      (hl)            ; Hintergrund und Pixel 
                                ld      (hl),a          ; BWS-Byte neu schreiben
                                cpl
                                
                                push    hl
                                
                                exx
                                
                                pop     de                         
                   
                                ld      (hl),a          ; BWS-Byte merken
                                dec     hl
                                                                        
                                ld      (hl),d          ; BWS hi merken
                                dec     hl
                                
                                ld      (hl),e          ; BWS lo merken
                                inc     hl                      
                                inc     hl              
                                ld      a,b
                                
                                exx
        
                        dontplot:
                                pop     hl              
                                
                                exx
                                
                                inc     hl              

                        djnz    d_loop

                        add     hl,bc   
                        
                        exx                     
                        
                        random:
                                pop     de
                                ld      b,10h
                                
                                backw:  sla     e
                                        rl      d
                                        ld      a,d
                                        and     0c0h    
                                        jp      pe,forw
                                        inc     e
                                        
                        forw:   djnz    backw
                        
                                ld      a,d
                                push    de
                                rra
                                rr      b
                                and     07h
                                ld      (hl),b   
                                inc     l
                                ld      (hl),a  
                                inc     l
                        jr      nz,random
                        
                        exx                             
                        
                        ld      a,hi(buffer2_end)
                        cp      a,h
                        
                jp      nz,loop
                
        jp      loop_ix
        
;------------------------------------------------------------------------------

        org     BASE+0F8h

        db      00000001b
        db      00000010b
        db      00000100b
        db      00001000b
        db      00010000b
        db      00100000b
        db      01000000b
        db      10000000b
sprite:

        
;------------------------------------------------------------------------------
; KC85/4 Grafik-Routinen
;------------------------------------------------------------------------------

VRAM_START      equ     08000h
VRAM_END        equ     0A7FFh

;------------------------------------------------------------------------------
; Löscht Pixel-RAM0
;------------------------------------------------------------------------------

cls:
        ld      hl, VRAM_START
        xor     a
        ld      (hl), a
        ld      de, VRAM_START+1
        ld      bc, VRAM_END-VRAM_START
        ldir
        ret
        
;------------------------------------------------------------------------------
; in:  BC = Y,X (Pixelzeile, Pixelspalte)
; out: HL = VRAM, A = Bitpos (3 Bit binär)
;------------------------------------------------------------------------------

XPY_to_VRAM:

        ld      a, c
        and     a, 00000111b    ; Bitpos (0-7)
        push    af              ; Bitpos merken
        
        ; Pixelspalte / 8 = Zeichenspalte
        
        srl     c
        srl     c
        srl     c
        
        ; aus KC85/4 System-Handbuch S.112
        
        ; Adresse = 8000H + Zeichenspalte * 100H + Pixelzeile
        ; 0 =< Zeichenspalte =< 27H
        ; 0 =< Pixelzeile =< 0FFH
        
        ld      a, b            ; a=Pixelzeile merken
        ld      b, c            ; b=Zeichenspalte * 100H
        ld      c, 0
        ld      hl, VRAM_START
        add     hl, bc          ; 8000H + Zeichenspalte * 100H
        ld      b, 0
        ld      c, a
        add     hl, bc          ; (8000H + Zeichenspalte * 100H) + Pixelzeile
        pop     af      
        ret
        
end

;------------------------------------------------------------------------------

        ; RAM für GleEst
        
        align   100h
        
buffer1:        
        ds      100h
buffer2:        
        ds      900h
buffer2_end:    
        ds      20h
stack:  
        
        



