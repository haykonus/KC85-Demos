;------------------------------------------------------------------------------
; Titel:                GleEst für KC85/3+4
;
; Erstellt:             20.11.2024
; Letzte Änderung:      09.12.2024
;------------------------------------------------------------------------------ 

hi      function x,(x>>8)&255
lo      function x, x&255  

        cpu     z80

KC85_3  equ     3
KC85_4  equ     4
        
        ifndef  KC_TYPE
                KC_TYPE: set    KC85_4
        endif   
        
        ifndef  BASE
                BASE:    set    0200H   
        endif   
         
        org     BASE
        
        if KC_TYPE == KC85_3
        db      7Fh,7Fh, 'GLEEST3', 1
        elseif  KC_TYPE == KC85_4
        db      7Fh,7Fh, 'GLEEST4', 1
        endif
        
start:  
        call    cls
        call    initGleEst
        
;------------------------------------------------------------------------------
        
        ; Start GleEst

        ld      sp, stack
        ld      hl, 0001h       ; (stack) darf nicht 0 sein
        push    hl
        
        ld      hl, buffer1
   
        exx

        loop_ix:
        
                ; TIPP von Crawler
                bit     0,(ix+8)         ; Tastenstatusabfrage
                jp      nz, 0E000h       ; Reset
 
                ;call    0F003H          ; Programmverteiler PV1
                ;db      0Ch             ; KBDS Tastenstatusabfrage 
                ;jp      c,0E000h        ; Reset
                
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
                                ex      (sp),hl         ;hl = (sp)
                                
                                exx
                                
                                ld      a,b     
                                
                                exx                     ;hl = (sp)
                                
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
                                ;cp      0ffh            ; Y max  
                                                         
                                ;
                                ; Pixel schreiben
                                ;
                                
                                ;-------------------------------
                                ; ZX Spectrum 
                                ;-------------------------------                                

                                ; THE 'PIXEL ADDRESS' SUBROUTINE (22AAh)
                                ; This subroutine is called by the POINT subroutine and by the PLOT command routine. 
                                ; Is is entered with the co-ordinates of a pixel in the BC register pair and returns 
                                ; with HL holding the address of the display file byte which contains that pixel 
                                ; and A pointing to the position of the pixel within the byte.
                
                                ;call   c,22b0h         -> Spectrum ROM       in: co-ordinates of a pixel in the AC
                                
                                ;-------------------------------
                                ; KC85/3+4
                                ;-------------------------------                                
                                
                                ; getVRAMadr
                                ; in:  AC = Y,X 
                                ; KC85/3: out: HL = VRAM, DE = VRAM (Farbe) A = Bitpos (3-Bit binär)
                                ; KC85/4: out: HL = VRAM, A = Bitpos (3-Bit binär)
                                   
                                ;call    c,getVRAMadr  ; nur bei Abfrage von Y-max notwendig
                                call    getVRAMadr 
                                
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
                                
                                rrca    
                                rrca    
                                rrca
                                or      11110000b
                                
                                ld      c,a

                                ;
                                ; Farb-Attribut setzen
                                ;
                                
                                ;-------------------------------
                                ; ZX Spectrum 
                                ;-------------------------------
                                
                                ;ld     a,(bc)                  A = Farb-Attribut
                                
                                ; Paper-Attribute ZX-Spectrum
                                ;
                                ; 7  6  5  4  3   2  1  0       Bit
                                ;       G  R  B   G  R  B       Color   G=green, R=red, B=blue  
                                ; F  H  P2 P1 P0  I2 I1 I0      Function

                                ; Where:

                                ; F sets the attribute FLASH mode
                                ; H sets the attribute BRIGHTNESS mode
                                ; P2 to P0 is the PAPER colour
                                ; I2 to I0 is the INK colour

                                ;ld     (23695),a       ; ATTR_T = 5C8Fh ; aktuelle Farben temporaer
                                
                                
                                ; THE 'SET ATTRIBUTE BYTE' SUBROUTINE
                                ; The appropriate attribute byte is identified and fetched. 
                                ; The new value is formed by manipulating the old value, ATTR-T, MASK-T and
                                ; P-FLAG. Finally this new value is copied to the attribute area.
                                
                                ;call   0BDBh   -> Spectrum ROM
                                
                                ;-------------------------------
                                ; KC85/3+4
                                ;-------------------------------
                                
                                ; 7  6  5  4  3    2  1  0      Bit
                                ;    H  G  R  B    G  R  B      Farbe 
                                ; F  I3 I2 I1 I0   P2 P1 P0     Funktion        
                                
                                ; F=blinken
                                ; H=hell, G=grün, R=rot, B=blau
                                ; P2-P0 = Hintergrundfarbe 
                                ; I3-I0 = Vordergrundfarbe

                                call    setColor
                                
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
                        
                        ld      a,hi(buffer2_end)       ; 0Eh
                        cp      a,h                     ; 0Eh-0Fh -> CY, 
                                                        ; buffer2_len = 0E00h-0500h = 0900h  
							; 900h = C000h-B700h -> s. test Bit 6 im Original Code
                jp      nc,loop
                
        jp      loop_ix
        
;------------------------------------------------------------------------------

        org     BASE+0F8h-6

palette:

        ; F=blinken
        ; H=hell, G=grün, R=rot, B=blau
        ; P2-P0   = Hintergrundfarbe 
        ; I3/2-I0 = Vordergrundfarbe
        
        if 0 = 1
        ;----------------------------------------
        ; ZX Spectrum 
        ;----------------------------------------       
        ; 7  6  5  4  3   2  1  0       Bit
        ;       G  R  B   G  R  B       Farbe   
        ; F  H  P2 P1 P0  I2 I1 I0      Funktion
                                
        db      45h             ; HGB
                ;01 000 101
        
        db      44h             ; HG
                ;01 000 100
        
        db      06h             ; GR
                ;00 000 110
        
        db      42h             ; HR
                ;01 000 010

        db      03h             ; RB
                ;00 000 011

        db      01h             ; B
                ;00 000 001
        endif

        ;----------------------------------------
        ; KC85/3+4
        ;----------------------------------------
        ; 7  6  5  4  3    2  1  0      Bit
        ;    H  G  R  B    G  R  B      Farbe 
        ; F  I3 I2 I1 I0   P2 P1 P0     Funktion        

        db      00101000b       ; GB
        db      00100000b       ; G  
        db      00110000b       ; GR 
        db      00010000b       ; R  
        db      00011000b       ; RB 
        db      00001000b       ; B  

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
; KC85/3+4 Grafik-Routinen
;------------------------------------------------------------------------------

; KC85/5 Systemhandbuch S.127

; Ausgabe Port 84H bzw. (IX + 1)
; Bit 0 - Anzeige Bild 0 oder 1
; Bit 1 - Zugriff auf Pixel- oder Farbebene(Pixel = 0 oder Farbe = 1)
; Bit 2 - Zugriff auf Bild 0 oder 1
; Bit 3 - hohe Farbauflösung ein/aus(0 = hohe oder 1 = niedrige)

; Bit 4 -+
; Bit 5  +- Auswahl der RAM8-Ebene (4 Bit = 16 Ebenen)
; Bit 6  |
; Bit 7 -+
;
; Farben s. KC85/5 Systemhandbuch S.232-233
;------------------------------------------------------------------------------

VRAM_START      equ     08000h
        if KC_TYPE == KC85_3
VRAM_END        equ     0B1FFh
        elseif KC_TYPE == KC85_4
VRAM_END        equ     0A7FFh
        endif
;------------------------------------------------------------------------------
; KC85/3
; Löscht Pixel/Farb-RAM
;------------------------------------------------------------------------------

        if KC_TYPE == KC85_3
cls:
        ld      hl, VRAM_START
        xor     a                       ; alle Pixel aus
        ld      (hl), a 
        ld      de, VRAM_START+1
        ld      bc, VRAM_END-VRAM_START
        ldir
        ret
        
        endif
        
;------------------------------------------------------------------------------
; KC85/4
; Löscht Pixel/Farb-RAM0
;------------------------------------------------------------------------------

        if KC_TYPE == KC85_4
cls:
        ld      hl, VRAM_START
        xor     a                       ; alle Pixel aus
        ld      (hl), a 
        ld      de, VRAM_START+1
        ld      bc, VRAM_END-VRAM_START
        ldir
        
        ld      a, (IX+1)               ; streng nach Vorschrift ...
        or      a, 00000010b            ; Farbebene ein
        ld      (IX+1), a               ; streng nach Vorschrift ...
        out     (84h), a

        ld      hl, VRAM_START
        xor     a                       ; alle Farben aus
        ld      (hl), a
        ld      de, VRAM_START+1
        ld      bc, VRAM_END-VRAM_START
        ldir

        ld      a, (IX+1)               ; streng nach Vorschrift ...
        and     a, 11111101b            ; Pixelebene ein
        ld      (IX+1), a               ; streng nach Vorschrift ...    
        out     (84h), a  
        
        ret
        
        endif
        
;------------------------------------------------------------------------------
; KC85/3 -> (c) KaiOr, Forum www.robotrontechnik.de
; in:  AC = Y,X (Pixelzeile, Pixelspalte)
; out: HL = VRAM (Pixel) , DE = VRAM (Farbe) A = Bitpos (3 Bit binär)
;------------------------------------------------------------------------------

        if KC_TYPE == KC85_3
        
getVRAMadr:
        ld      h, a

        ld      a, c
        add     a, 32       ; Bild mittig
        jr      c, bsrght

        ld      l, h
        srl     h
        srl     h
        scf
        rr      h       
        rra
        srl     h
        rra
        ld      d, h
        scf
        rr      d
        set     3, d
        ld      e, a
        rr      e
        rr      l
        rra
        rr      l
        ld      l, a
        rl      h
        jp      bsend
bsrght: rra
        rra
        and      0eh
        ld      l, a
        ld      a, h
        rlca
        ld      b, a
        and     1
        or      0b0h
        ld      d, a
        ld      a, b
        rlca
        ld      e, a
        and     3
        or      50h
        ld      b, h
        ld      h, a
        ld      a, b
        and     30h
        or      l
        ld      l, a
        ld      a, e
        rlca
        rlca
        and     0c0h
        or      l
        ld      l,a
        rr      b
        rr      l
        rr      b
        rl      h
        rr      e
        rra
        ld      e,a
bsend:
        ld      a,c
        and     a, 00000111b       ; Bitpos (0-7)
        
        ret
        
        endif
        
;------------------------------------------------------------------------------
; KC85/4 -> (c) KaiOr, Forum www.robotrontechnik.de
; in:  AC = Y,X (Pixelzeile, Pixelspalte)
; out: HL = VRAM, A = Bitpos (3 Bit binär)
;------------------------------------------------------------------------------

        if KC_TYPE == KC85_4
        
getVRAMadr:

        ld      l, a
        
        ; Pixelspalte / 8 = Zeichenspalte
        
        ld      a, c
        rra
        rra
        rra
        and     1Fh             ;Bit 7-5 loeschen
        
        ; aus KC85/4 System-Handbuch S.112
        
        ; Adresse = 8000H + Zeichenspalte * 100H + Pixelzeile
        ; 0 =< Zeichenspalte =< 27H
        ; 0 =< Pixelzeile =< 0FFH
        
        or      80h             ;Adressbereich auf obere 8000H heben
        add     a, 4            ;Bild mittig
        ld      h, a
        ld      a, c
        and     00000111b       ; Bitpos (0-7)
        ret

;------------------------------------------------------------------------------
; in:  AC = Y,X (Pixelzeile, Pixelspalte)
; out: HL = VRAM, A = Bitpos (3 Bit binär)
;------------------------------------------------------------------------------

getVRAMadr_old:

        ld      b, a            
        ld      a, c
        and     a, 00000111b    ; Bitpos (0-7)
        push    af              ; Bitpos merken
        
        ; Pixelspalte / 8 = Zeichenspalte
        
        srl     c
        srl     c
        srl     c
        
        ; aus KC85/5 System-Handbuch S.231
        
        ; Adresse = 8000H + Zeichenspalte * 100H + Pixelzeile
        ; 0 =< Zeichenspalte =< 27H
        ; 0 =< Pixelzeile =< 0FFH
        
        ld      a, b                    ; a=Pixelzeile merken
        ld      b, c                    ; b=Zeichenspalte * 100H
        ld      c, 0
        ld      hl, VRAM_START+4*256    ; Start + Bild mittig
        add     hl, bc                  ; 8000H + Zeichenspalte * 100H
        ld      b, 0
        ld      c, a
        add     hl, bc                  ; (8000H + Zeichenspalte * 100H) + Pixelzeile
        pop     af      
        ret     
        
        endif

;------------------------------------------------------------------------------
; KC85/3
; in:  BC = Palette, DE = VRAM
; out: Farbe im VRAM
;------------------------------------------------------------------------------

        if KC_TYPE == KC85_3
        
setColor:

        ld      a, (bc)         ; Farb-Attribut aus Palette holen
        ld      (de), a         ; in Farbebene schreiben
        ret
        
        endif
        
;------------------------------------------------------------------------------
; KC85/4 
; in:  BC = Palette, HL = VRAM
; out: Farbe im VRAM
;------------------------------------------------------------------------------

        if KC_TYPE == KC85_4

setColor:

        ld      a, (IX+1)        
        or      a, 00000010b    ; Farbebene ein
        out     (84h), a

        ld      a, (bc)         ; Farb-Attribut aus Palette holen
        ld      (hl), a         ; in Farbebene schreiben
                
        ld      a, (IX+1)               
        and     a, 11111101b    ; Pixelebene ein              
        out     (84h), a
        
        ret
        
        endif
        
;----------------------------------------------------------------------------
; buffer2 wird mit Adresse von "dummy" und 55h initialisiert, damit beim 
; Start von GleEst keine undefinierten Schreibvorgänge im RAM erfolgen können.
;------------------------------------------------------------------------------

initGleEst:

        ld      bc, (buffer2_end+200h-buffer2)/3 ; noch um 200h weiter 
						 ; füllen mit dummy's, damit
						 ; Schreiben auf 0 verhindert
						 ; wird
	ld      hl, buffer2				
        ld      de, dummy
fb1:    ld      (hl), e
        inc     hl
        ld      (hl), d
        inc     hl
        ld      (hl), 55h
        inc     hl
        
        dec     bc
        ld      a, b
        or      c
        jr      nz, fb1
        
        ret

;------------------------------------------------------------------------------
end
                
        ; RAM für GleEst
        
dummy:  db      55h  
   
        align   100h     
buffer1:        
        ds      100h
buffer2:        
        ds      0900h
buffer2_end:  		; wird noch um 77h überschritten :-(
  
        ds      200h	; zur Sicherheit
stack:  
  
  


