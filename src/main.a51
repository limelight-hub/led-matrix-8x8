      org   0000h
      jmp   Start
      org   03h
      ljmp  chgMode
      org   13h
      ljmp  chgSpeed
      
;;;register value
;r0 : mode
;r1 : vi tri bat dau tren byte quet mang bam xung
;r2 : 5 level tang r1
;r3, r4 : cai dat trong cac mode
;r5, r6 cai dat trong ham scan
;r7: vi tri bat dau tren byte quet led
Start:	
      mov IE, #10000101b ;cho phep ngat i1 i0
      setb IT0;ngat canh int0
      setb IT1
      mov R0, #0
      mov R1, #0
      mov R2, #25
      mov R7, #0
      mov TMOD, #11h ;timer1 mode 1 tm0 mode1
      mov TH0, #15h
      mov TL0, #0A0h;5536
Loop:
      CJNE R0, #0, next1 
      call mode0
      jmp Loop
      
      next1:  CJNE R0, #1, next2 
      call mode1
      jmp Loop
      
      next2: CJNE R0, #2, next3 
      call mode2
      jmp Loop
      
      next3:  CJNE R0, #3, next4 
      call mode3
      jmp Loop
      
      next4: CJNE R0, #4, next5 
      call mode4
      jmp Loop
      
      next5: CJNE R0, #5, next6 
      call mode5
      jmp Loop
      
      next6: CJNE R0, #6, next7 
      call mode6
      jmp Loop
      
      next7: CJNE R0, #7, next8 
      call mode7
      jmp Loop
      
      next8: CJNE R0, #8, next9 
      call mode8
      jmp Loop
      
      next9: call mode9
      jmp Loop
      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      
Delay:
      mov TH0, #15h
      mov TL0, #0A0h
      setb TR0 
      hereDelay: JNB TF0, hereDelay
      clr TR0
      clr TF0
      ret
scanDelay:
      mov TH1, #0fch;144hz
      mov TL1, #0e4h
      setb TR1 
      hereScan: JNB TF1, hereScan
      clr TR1
      clr TF1
      ret

ResetLed:
      mov P1, #0h
      mov P2, #0ffh
      call Delay
      mov R3, #1
      mov R4, #1
      mov R5, #1
      mov A, #0
      mov B, #0
      setb TF0
      setb TF1
      ret
DelayButton:
      mov P1, #0h
      mov P2, #0ffh
      clr TR0
      clr TF0
      MOV TH0, #00H 
      MOV TL0, #04CH  ; 
      SETB TR0       
   Delay_Debounce:
      JNB TF0,Delay_Debounce 
      CLR TR0         
      CLR TF0     
      ret
      ; check trang thai int0
chgSpeed:;thay doi so lan quet 1 byte led
      call DelayButton
      jb P3.3, endISR1
      call ResetLed
      mov A, R2
      subb A, #10
      CJNE A, #-5, nextSpeed
      mov A, #35
      nextSpeed:
      mov R2, A   
      mov R3, #1
      endISR1:
      mov A, #0
      reti
chgMode:
      call DelayButton
      jb P3.2, endISR0
      ;chuyen hieu ung
      call ResetLed
      mov A, R0
      add A, #1
      CJNE R0, #9, setR0
      mov A, #0
      setR0:
      mov R0, A
      endISR0:
      mov A, #0
      reti
SCAN:	
      mov R5, #8
      mov R6, #07fh
      loopScan:
      mov A, R6
      RL A
      mov R6, A
      call MATCH ; Nh?y t?i h�m MATCH d? hi?n th? pt[i]
      INC DPTR ; tang con tr? DPTR l�n 1 
      DJNZ R5, loopScan
      ret
MATCH:
      MOV A, R7; vi tri bat dau ma led
      MOVC A,@A+DPTR ;
      MOV P1, A ; Xu?t gi� tr? ra Port2 d? hi?n th? ra LED 7 �o?n
      mov P2, R6
      call ScanDelay
      mov P2, #0ffh
      mov P1, #00h
      nop
      RET 
      
ScanCol:
      mov A, R6
      RL A
      mov R6, A
      call MATCH1 ; Nh?y t?i h�m MATCH d? hi?n th? pt[i]
      ret
MATCH1:
      MOV A, R7; chi so gia tri timer
      MOVC A,@A+DPTR ;
      MOV P1, A ; Xu?t gi� tr? ra Port2 d? hi?n th? ra LED 7 �o?n
      mov P2, R6
      call highPulse
      mov P2, #0ffh
      mov P1, #00h
      call LowPulse
      RET 
setTimerValue:
      MOV A, R1; chi so gia tri timer0 trong mang gia tri
      MOVC A,@A+DPTR ;
      MOV TH0, A 
      mov A, R1
      add A, #36
      MOVC A,@A+DPTR ;
      MOV TL0, A 
      RET 
highPulse:
      mov dptr, #TH0HighPulse
      call setTimerValue
      setb TR0 
      hereHP: JNB TF0, hereHP
      clr TR0
      clr TF0
      ret
LowPulse:
      mov dptr, #TH0LowPulse
      call SetTimerValue
      setb TR0 
      hereLP: JNB TF0, hereLP
      clr TR0
      clr TF0
      ret
;;;;;;;;;;;;;;;;;;
mode9:;
      mov R7, #00h
      mov R4, #12
      mov r1, 0h
      mov B, #8
      E9a:
      mov A, R2
      mov R3, A
      loopChar9a:
      call fireWork
      DJNZ R3, loopChar9a
      mov A, R7
      add A, #8
      mov R7, A
      DJNZ R4, E9a
      ;ret
mode9b:
      mov R4, B;so lan tang chi so phan tu mang nap timer
      CJNE R4, #0, next9b
      jmp end9b
      next9b:
      mov R1, #24
      E9b:
      mov A, R2 ;so lan lap quet 1 byte led
      mov R3, A ;
      loopChar9b:
      mov R7, #00h 
      call fireWork1     ;bam xung  
      DJNZ R3, loopChar9b
      mov A, R1 ;
      add A, #1
      mov R1, A
      DJNZ R4, E9b
      end9b:
      ret
mode8:
      mov B, #8
      E8:
      mov R1, #00h ;chi so mang Timer
      mov R4, #31 ;so lan tang gia tri timer
      E81:
      ;mov R7, #00h;chi so mang codeMartix
      mov A, R2 ;so lan lap quet 1 byte led
      mov R3, A ;
      loopChar8:
      mov A, B
      mov R7, A
      call Nhom17  ;bam xung  
      DJNZ R3, loopChar8
      mov A, R1 ;
      add A, #1
      mov R1, A
      DJNZ R4, E81
      mov A, B
      subb A, #8
      mov B, A
      CJNE A, #-8, E8
      ret  
mode7:
      mov R4, #31 ;so lan tang chi so phan tu mang nap timer
      mov R1, #0h
      E7:
      mov A, R2 ;so lan lap quet 1 byte led
      mov R3, A ;
      loopChar7:
      mov R7, #00h 
      call Pine     ;bam xung  
      DJNZ R3, loopChar7
      mov A, R1 ;
      add A, #1
      mov R1, A
      DJNZ R4, E7
      ret
mode6:
      mov R7, #00h
      mov R4, #9
      E6:
      mov A, R2
      mov R3, A
      loopChar6:
      call Bird
      DJNZ R3, loopChar6
      mov A, R7
      add A, #8
      mov R7, A
      DJNZ R4, E6
      ret
;;;;;;
mode5:
      mov R7, #00h
      mov R4, #12
      E5:
      mov A, R2
      mov R3, A
      loopChar5:
      call Ball
      DJNZ R3, loopChar5
      mov A, R7
      add A, #8
      mov R7, A
      DJNZ R4, E5
      ret	

mode4:;nchong chong
      mov R7, #00h
      mov R4, #3
      E4:
      mov A, R2
      mov R3, A
      loopChar4:
      call PinWheel
      DJNZ R3, loopChar4
      mov A, R7
      add A, #8
      mov R7, A
      DJNZ R4, E4
      ret     
mode3:;Trai tim      
      mov R7, #00h
      mov R4, #2
      E3:
      mov A, R2
      mov R3, A
      loopChar3:
      call sHeart
      DJNZ R3, loopChar3
      mov A, R7
      add A, #8
      mov R7, A
      DJNZ R4, E3
      ret
 ;;;;;;
mode2:; chay chu I <3 UIT 
      mov R7, #00h
      mov R4, #32
      E2:
      mov A, R2
      mov R3, A
      loopChar2:
      call IuUIT
      DJNZ R3, loopChar2
      mov A, R7
      inc A
      mov R7, A
      DJNZ R4, E2
      ret
mode1:; chu CE 
      mov R7, #00h
      call CE
      ret

mode0:;nhap nhay
      ;full matrix
      mov R7, #00h
      mov R4, #2
      E0:
      mov A, R2
      mov R3, A
      loopChar0:
      call FullMatrix
      DJNZ R3, loopChar0
      mov A, R7
      add A, #8
      mov R7, A
      DJNZ R4, E0
      ret
 
      
  FullMatrix:	
      MOV DPTR,#codeFullMatrix ;
      LCALL SCAN ;    
      ret    
  sHeart:	
      MOV DPTR,#codesHeart
      LCALL SCAN    
      ret
  mHeart:
      mov dptr, #codemHeart
      LCALL SCAN 
      ret
  IuUIT:
      mov dptr, #codeIuUIT 
      LCALL SCAN
      ret
  
  ZoomOut:
      mov dptr, #codeZoomOut 
      LCALL SCAN
      ret
  CE:
      mov dptr, #codeCE
      LCALL SCAN
      ret
  FireWork:
      mov dptr, #codeFireWork
      LCALL SCAN
      ret
  Bird:
      mov dptr, #codeBird 
      LCALL SCAN
      ret
  Ball:
      mov dptr, #codeBall
      LCALL SCAN
      ret
  PinWheel:
      mov dptr, #codePinWheel
      LCALL SCAN
      ret
   Nhom17:	
      mov R5, #8
      mov R6, #07fh
      loopNhom17:
      mov dptr, #codeNhom17
      lcall ScanCol
      INC R7
      mov A, R7
      MOVC A, @A+dptr; tang con tr? DPTR l�n 1 
      DJNZ R5, loopNhom17
      ret
  Star:	
      mov R5, #8
      mov R6, #07fh
      loopStar:
      mov dptr, #codeStar
      lcall ScanCol
      INC R7
      mov A, R7
      MOVC A, @A+dptr; tang con tr? DPTR l�n 1 
      DJNZ R5, loopStar
      ret
  Pine:	
      mov R5, #8
      mov R6, #07fh
      loopPine:
      mov dptr, #codePine
      lcall ScanCol
      INC R7
      mov A, R7
      MOVC A, @A+dptr; tang con tr? DPTR l�n 1 
      DJNZ R5, loopPine
      ret
  fireWork1:	
      mov R5, #8
      mov R6, #07fh
      loopfirework1:
      mov dptr, #codefirework1
      lcall ScanCol
      INC R7
      mov A, R7
      MOVC A, @A+dptr; tang con tr? DPTR l�n 1 
      DJNZ R5, loopfirework1
      ret
ORG 300H ; Nh�n noi luu gi� tr? m?ng
codeFullMatrix:
db 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
codePinWheel:
db 030h, 07ah, 01bh, 07fh, 0feh, 0d8h, 05eh, 0ch
db 018h, 0ch, 06ch, 0f9h, 09fh, 036h, 030h, 018h
db 0ch, 066h, 0f6h, 09ch, 039h, 06fh, 066h, 030h

codesHeart: db 00h, 08h, 1ch, 38h, 1ch, 08h, 00h, 00h
codemHeart: db 0ch, 1eh, 3eh, 7ch, 3eh, 1eh, 0ch, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
;db 00h, 0ch, 12h, 22h, 44h, 22h, 12h, 0ch

codeCE:     db 03fh, 021h, 021h, 021h, 084h, 094h, 094h, 0fch

codeZoomOut:
db 00h, 00h, 00h, 18h, 18h, 00h, 00h, 00h
db 00h, 00h, 3ch, 24h, 24h, 3ch, 00h, 00h
db 00h, 7eh, 42h, 42h, 42h, 42h, 7eh, 00h
db 0ffh, 81h, 81h, 81h, 81h, 81h, 81h, 0ffh

codeIuUIT:
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 42h
db 7eh, 42h, 00h, 0ch, 1eh, 3eh, 7ch, 3eh
db 1eh, 0ch, 00h, 3eh, 40h, 40h, 3eh, 00h
db 42h, 7eh, 42h, 00h, 02h, 02h, 7eh, 02h
db 02h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

codeNhom17:
db 000h, 084h, 0feh, 080h, 02h, 0f2h, 00ah, 06h
db 00h, 07ch, 0feh, 082h, 092h, 092h, 074h, 00h

codePine:
db 00h, 020h, 034h, 03eh, 0ffh, 03eh, 034h, 020h ; c�y th�ng


codeBird: ;9row
db 08h, 04h, 08h, 18h, 08h, 04h, 04h, 08h
db 04h, 04h, 08h, 18h, 08h, 04h, 04h, 04h
db 04h, 08h, 18h, 30h, 18h, 0ch, 04h, 02h
db 02h, 0ch, 18h, 30h, 18h, 0ch, 04h, 02h
db 10h, 08h, 0ch, 18h, 0ch, 0ch, 08h, 10h
db 30h, 18h, 0ch, 04h, 0ch, 0ch, 18h, 30h
db 70h, 18h, 0ch, 04h, 0ch, 0ch, 38h, 70h
db 30h, 18h, 0ch, 04h, 0ch, 0ch, 18h, 30h
db 10h, 08h, 0ch, 18h, 0ch, 0ch, 08h, 10h

codeBall:
db 00h, 00h, 006h, 089h, 089h, 006h, 00h, 00h
db 00h, 00h, 006h, 089h, 089h, 006h, 00h, 00h
db 00h, 00h, 00ch, 092h, 092h, 00ch, 00h, 00h
db 00h, 00h, 00ch, 092h, 092h, 00ch, 00h, 00h
db 00h, 00h, 098h, 0a4h, 0a4h, 098h, 00h, 00h
db 00h, 00h, 0b0h, 0c8h, 0c8h, 0b0h, 00h, 00h
db 00h, 0a0h, 0d0h, 0d0h, 0d0h, 0d0h, 0a0h, 00h
db 00h, 00h, 0b0h, 0c8h, 0c8h, 0b0h, 00h, 00h
db 00h, 00h, 098h, 0a4h, 0a4h, 098h, 00h, 00h
db 00h, 00h, 098h, 0a4h, 0a4h, 098h, 00h, 00h
db 00h, 00h, 00ch, 092h, 092h, 00ch, 00h, 00h
db 00h, 00h, 00ch, 092h, 092h, 00ch, 00h, 00h

codeFireWork:
db 00h, 00h, 00h, 00h, 0c0h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 0c0h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 060h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 060h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 030h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 030h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 018h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 018h, 00h, 00h, 00h
db 00h, 00h, 00h, 04h, 0eh, 04h, 00h, 00h
db 00h, 012h, 0ah, 0dh, 032h, 0dh, 0ah, 012h
db 024h, 012h, 00h, 00h, 060h, 00h, 00h, 012h
codeFireWork1:
db 024h, 00h, 00h, 00h, 040h, 00h, 00h, 012h

codeStar:
db 00h, 042h, 00h, 08h, 00h, 080h, 08h, 00h
db 084h, 00h, 01h, 020h, 00h, 011h, 00h, 080h
db 01h, 00h, 020h, 04h, 080h, 00h, 08h, 00h
db 080h, 08h, 080h, 08h, 01h, 020h, 00h, 04h
db 00h, 020h, 04h, 080h, 08h, 00h, 021h, 08h
db 09h, 040h, 01h, 08h, 080h, 00h, 010h, 00h

TH0HighPulse:
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FDh, 0FDh, 0FDh, 0FDh, 0FDh, 0FCh 
   db 0FCh, 0FDh, 0FDh, 0FDh, 0FDh, 0FDh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh 
TL0HighPulse:
   db 0FFh, 0C8h, 0A4h, 076h, 048h, 01Ah, 0ECh, 0BDh, 08Fh, 061h, 033h, 005h, 0D7h, 0A9h, 07Bh, 04Dh, 01Fh, 0F1h
   db 0F1h, 01Fh, 04Dh, 07Bh, 0A9h, 0D7h, 005h, 033h, 061h, 08Fh, 0BDh, 0ECh, 01Ah, 048h, 076h, 0A4h, 0C8h, 0FFh
TH0LowPulse:
   db 0FCh, 0FDh, 0FDh, 0FDh, 0FDh, 0FDh, 0FDh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   
   db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FDh, 0FDh, 0FDh, 0FDh, 0FDh, 0FDh, 0FCh	 
TL0LowPulse:
   db 0E3h, 010h, 03Fh, 06Dh, 09Bh, 0C9h, 0F7h, 025h, 053h, 082h, 0B0h, 0DEh, 00Ch, 03Ah, 068h, 096h, 0C4h, 0F2h
   db 0F2h, 0C4h, 096h, 068h, 03Ah, 00Ch, 0DEh, 0B0h, 082h, 053h, 025h, 0F7h, 0C9h, 09Bh, 06Dh, 03Fh, 010h, 0E3h





;====================================================================
      END