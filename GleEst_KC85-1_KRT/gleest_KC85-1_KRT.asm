;------------------------------------------------------------------------------
; Titel:                GleEst für Z9001 (KC85/1, KC87) KRT
;
; Erstellt:             20.11.2024
; Letzte Änderung:      21.12.2024
;------------------------------------------------------------------------------ 

        cpu     z80

hi      function x,(x>>8)&255
lo      function x, x&255

        ifndef  BASE
                BASE:   set     0300H   
        endif   
                org     BASE
                
        jp      start
        db      'GLEEST1 '
        db      0
               
start:          
        call    cls             ; Bildschirm löschen
        call    initGleEst
        
;------------------------------------------------------------------------------
        
        ; Start GleEst
        
        ld      hl, 0001h       ; (stack) darf nicht 0 sein
        push    hl
        
        ld      hl, buffer1
        
        exx

        loop_ix:
        
                ld      a, (0025h)      ; KEYBU abfragen
                cp      a, 0            ; 0 = nicht gedrückt
                jr      z, noKey        ; weiter
                
                call    cls
                call    gOff            ; Grafik aus
                jp      0F003h          ; BIOS -> WBOOT

        noKey:  ld      hl, buffer2
        
                loop:   
                        ld      bc,3F04h	; BH = 3F -> max. 64 Punkte / 256-Byte-Block
                                                ; BL = 04 -> HL auf Anfang von nächstem 
						;            256-Byte-Block setzen
                        
                        d_loop:
                                ;
                                ; Pixel löschen
                                ;
                                
                                ld      e,(hl)          ;BWS lo holen
                                inc     hl
                                
                                ld      d,(hl)          ;BWS hi holen
                                inc     hl
                                
                                ld      a,(hl)          ;BWS-Block holen
                                out     (GR_CTRL),a     ;BWS_Block setzen
                                inc     hl
                                                                      
                                ld      a,(de)          ;BWS-Byte holen (t)     
                                and     (hl)            ;mit BWS-Byte (t-1) kombinieren (Bits löschen)                           
                                ld      (de),a          ;BWS schreiben 
                        skip:            
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
                                cp      0C0h            ; Y max  
                                                           
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
                                ; KC85/1
                                ;-------------------------------                                
                                
                                ; getVRAMadr
                                ; in:   AC = Y,X 
                                ; out:  HL = VRAM, A = Bitpos (3-Bit binär)
                                        
                                jr      nc,x1           ; innerhalb 0-191 ?
                                call    c, getVRAMadr   ; ja
                                jr      x2
                        x1:                             
                                ld      hl, dummy       ; nein -> HL = Dummy-BWS
                                ld      a, 08h          ; Grafik ein (Dummy)
                                ld      (LAST_GR_CTRL),a
                        x2:     
                                ld      b,hi(sprite-1)          
                                cpl
                                ld      c,a             
                                ld      a,(bc)          ; BWS-Byte holen
                                or      (hl)            ; Hintergrund und Pixel         
                                ld      (hl),a          ; BWS-Byte neu schreiben
                                cpl
                        skip2:  
                                push    hl
                                
                                exx
                                
                                pop     de              
                   
                                ld      (hl),a          ; BWS-Byte merken
                                dec     hl
                                        
                                ld      a,(LAST_GR_CTRL); BWS-Block holen
                                ld      (hl),a          ; BWS-Block merken
                                dec     hl
                                
                                ld      (hl),d          ; BWS hi merken
                                dec     hl
                                
                                ld      (hl),e          ; BWS lo merken
                                inc     hl                      
                                inc     hl
                                inc     hl              ; wegen BWS-Block       
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
                                

                                ;----------------------------------------
                                ; KC85/1
                                ;----------------------------------------
                                ; 7  6  5  4  3  2  1  0      Bit
                                ;    B  G  R     B  G  R      Farbe
                                ; F  I2 I1 I0    P2 P1 P0     Funktion 

                                ; F=blinken
                                ; H=hell, G=grün, R=rot, B=blau
                                ; P2-P0   = Hintergrundfarbe 
                                ; I2-I0   = Vordergrundfarbe
                                
                                ld      a, h
                                cp      hi(dummy)
                                jr      z, dontplot     ; wenn Dummy-BWS, Farbe nicht schreiben
                                sub     4               ; Farb-RAM-Adresse bilden -> E8XX
                                ld      h, a
                                ld      a, (bc)         ; Farb-Attribut aus Palette holen
                                ld      (hl), a         ; in Farb-RAM schreiben          

                        dontplot:
                                pop     hl              
                                
                                exx
                                
                                inc     hl
                                                                                                                                        
                        dec     b
                        jp      nz, d_loop      
                        ;djnz    d_loop

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
                        
                        ld      a,hi(buffer2_end)-1
                        cp      a,h
                        
                jp      nc,loop
                
        jp      loop_ix
        
;------------------------------------------------------------------------------

        org     BASE+0F8h-6

palette:

        ; F=blinken
        ; H=hell, G=grün, R=rot, B=blau
        ; P2-P0   = Hintergrundfarbe 
        ; I2-I0   = Vordergrundfarbe
        
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
        ; KC85/1
        ;----------------------------------------
        ; 7  6  5  4  3  2  1  0      Bit
        ;    B  G  R     B  G  R      Farbe
        ; F  I2 I1 I0    P2 P1 P0     Funktion           
        
        db      01100000b       ; GB    
        db      00100000b       ; G
        db      00110000b       ; GR
        db      00010000b       ; R
        db      01010000b       ; RB    
        db      01000000b       ;
        
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
; KC85/1 Grafik-Routinen
;
; aus "grafp.asm" übernommen und angepasst
; https://hc-ddr.hucki.net/wiki/lib/exe/fetch.php/z9001/grafik-krt.zip
;
;------------------------------------------------------------------------------

GR_CTRL         equ     0B8h    ; Farbe + Grafik ein/aus
                                ; 7 6 5 4 3 2 1 0
                                ;         | | | |
                                ;         | --|--
                                ;         |   Zeichen-Zeile 
                                ;         Grafik ein/aus
                                
LAST_GR_CTRL    db      0                               
                                        
;------------------------------------------------------------------------------
; KC85/1
; Grafik einschalten
;------------------------------------------------------------------------------

gOn:   
        ld      a, 00001000b    ; Grafikmode einschalten und Bank 0 einblenden
        out     (GR_CTRL),a
        ret
                
;------------------------------------------------------------------------------
; KC85/1
; Grafik ausschalten
;------------------------------------------------------------------------------

gOff:
        xor     a               ; Grafikmode ausschalten
        out     (GR_CTRL),a
        ret

;------------------------------------------------------------------------------
; KC85/1
; Löscht Pixel/Farb-RAM
;------------------------------------------------------------------------------

cls:
        ld      b, 8
        ld      a, 00001000b    ; Grafikmode einschalten und Bank 0 einblenden
cls1:
        out     (GR_CTRL),a
        push    af
        push    bc
        ld      hl, 0EC00h
        ld      de, 0EC01h
        ld      bc, 960
        ld      (hl),0
        ldir
        pop     bc
        pop     af
        inc     a
        djnz    cls1

        ld      a, (0027h)      ; ATRIB aktuelles Farbattribut
        ld      hl, 0E800h
        ld      de, 0E801h
        ld      bc, 960
        ld      (hl),a
        ldir
        
        xor     a               ; Grafikmode ausschalten
        out     (GR_CTRL),a     
        ret
        
;------------------------------------------------------------------------------
; KC85/1
; in:  AC = Y,X (Pixelzeile, Pixelspalte)
; out: HL = VRAM (Pixel), A = Bitpos (3 Bit binär)
;------------------------------------------------------------------------------ 

getVRAMadr:
        ld      e, a    ; DE = Y
        ld      b, 0    ; BC = X

        ld      h, b    ; BC = BC + 32 -> Bild mittig
        ld      l, c
        ld      bc, 0020h
        add     hl, bc
        ld      b, h
        ld      c, l    
        
        ; Umrechnung BC (X), DE (Y) zu VRAM-Adr
        
        ld      a, c
        and     7               ; unteren 3 Bit maskieren
        push    af              ; Bitpos merken
        
        ld      d, c            ; de ist max 192, d.h. d ist immer 0    
                
        ; Umrechnung BC (D)-xpos Spalte , E-ypos Zeile zu g_memptr

        ld      a, 7            ; BWS-Bank = Zeile mod 8
        sub     e
        and     7
        or      00001000b
        out  (GR_CTRL),a        ; BWS-Bank einschalten
        ld   (LAST_GR_CTRL),a   ; ... und merken

        ; VRAM-Adr = letzte BWS-Zeile - 40*(Zeile/8) + (Spalte/8)
        ;          = letzte BWS-Zeile - 5*Zeile + (Spalte/8)

        ld      c, d
        push    bc
        ld      a, e
        and     11111000b
        ld      e,a
        ld      d, 0
        ld      h, d
        ld      l, e            ;HL := DE
        add     hl, hl          ;*2
        add     hl, hl          ;*4
        add     hl, de          ;*5
        ld      de, 0EC00h+40*(24-1)    ; Anf.Adr. unterste Zeile
        ex      de,hl
        xor     a
        sbc     hl,de           ;letzte BWS-Zeile - 5*Zeile
        pop     bc

        srl     b               ;bc/8
        rr      c
        srl     b
        rr      c
        srl     b
        rr      c

        add     hl, bc          ; Spaltenoffset addieren
        pop     af              ; A = Bitpos
        ret

;----------------------------------------------------------------------------
; buffer2 wird mit Adresse von "dummy", 08h und 55h initialisiert, damit beim 
; Laufen von GleEst keine undefinierten Schreibvorgänge im RAM erfolgen können.
;------------------------------------------------------------------------------
        
initGleEst:

        ld      bc, (buffer2_end - buffer2)/4
        ld      hl, buffer2
        ld      de, dummy
        
fb1:    ld      (hl), e         ; Dummy-BWS hi
        inc     hl
        ld      (hl), d         ; Dummy-BWS lo
        inc     hl
        ld      (hl), 08h       ; 08h = Grafik ein
        inc     hl
        ld      (hl), 55h       ; Dummy-Pixel
        inc     hl
        
        dec     bc
        ld      a, b
        or      c
        jr      nz, fb1 
        ret     
end     

;------------------------------------------------------------------------------

        ; RAM für GleEst
        
dummy:  db      55h 
 
        align   0100h
        
buffer1:        
        ds      0100h
buffer2:        	; 12 x 256 Bytes
        ds      0C00h   ; C00h
buffer2_end:  


        
        

        
        



