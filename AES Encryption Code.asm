include 'emu8086.inc'
org 100h

.data segment
    a DB 032H,088H,031H,0E0H
      DB 043H,05AH,031H,037H
      DB 0F6H,030H,098H,007H
      DB 0A8H,08DH,0A2H,034H
      
    key DB 0FFH,0FFH,0FFH,0FFH
        DB 0FFH,0FFH,0FFH,0FFH
        DB 0FFH,0FFH,0FFH,0FFH
        DB 0FFH,0FFH,0FFH,0FFH
    
    newkey  DB 00H,00H,00H,00H
            DB 00H,00H,00H,00H
            DB 00H,00H,00H,00H
            DB 00H,00H,00H,00H
    
    sbox DB 063H,07cH,077H,07bH,0f2H,06bH,06fH,0c5H,030H,001H,067H,02bH,0feH,0d7H,0abH,076H
         DB 0caH,082H,0c9H,07dH,0faH,059H,047H,0f0H,0adH,0d4H,0a2H,0afH,09cH,0a4H,072H,0c0H
         DB 0b7H,0fdH,093H,026H,036H,03fH,0f7H,0ccH,034H,0a5H,0e5H,0f1H,071H,0d8H,031H,015H
         DB 004H,0c7H,023H,0c3H,018H,096H,005H,09aH,007H,012H,080H,0e2H,0ebH,027H,0b2H,075H
         DB 009H,083H,02cH,01aH,01bH,06eH,05aH,0a0H,052H,03bH,0d6H,0b3H,029H,0e3H,02fH,084H
         DB 053H,0d1H,000H,0edH,020H,0fcH,0b1H,05bH,06aH,0cbH,0beH,039H,04aH,04cH,058H,0cfH
         DB 0d0H,0efH,0aaH,0fbH,043H,04dH,033H,085H,045H,0f9H,002H,07fH,050H,03cH,09fH,0a8H
         DB 051H,0a3H,040H,08fH,092H,09dH,038H,0f5H,0bcH,0b6H,0daH,021H,010H,0ffH,0f3H,0d2H
         DB 0cdH,00cH,013H,0ecH,05fH,097H,044H,017H,0c4H,0a7H,07eH,03dH,064H,05dH,019H,073H
         DB 060H,081H,04fH,0dcH,022H,02aH,090H,088H,046H,0eeH,0b8H,014H,0deH,05eH,00bH,0dbH
         DB 0e0H,032H,03aH,00aH,049H,006H,024H,05cH,0c2H,0d3H,0acH,062H,091H,095H,0e4H,079H
         DB 0e7H,0c8H,037H,06dH,08dH,0d5H,04eH,0a9H,06cH,056H,0f4H,0eaH,065H,07aH,0aeH,008H
         DB 0baH,078H,025H,02eH,01cH,0a6H,0b4H,0c6H,0e8H,0ddH,074H,01fH,04bH,0bdH,08bH,08aH
         DB 070H,03eH,0b5H,066H,048H,003H,0f6H,00eH,061H,035H,057H,0b9H,086H,0c1H,01dH,09eH
         DB 0e1H,0f8H,098H,011H,069H,0d9H,08eH,094H,09bH,01eH,087H,0e9H,0ceH,055H,028H,0dfH
         DB 08cH,0a1H,089H,00dH,0bfH,0e6H,042H,068H,041H,099H,02dH,00fH,0b0H,054H,0bbH,016H
    
    mat DB 2,3,1,1
        DB 1,2,3,1
        DB 1,1,2,3
        DB 3,1,1,2
    
    rcon DB 01H,02H,04H,08H,10H,20H,40H,80H,1BH,36H
         DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
         DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
         DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H    
         
    roundcount DW 0
.code segment
    MOV BH, 4  ;BH = 4                  
    MOV BL, 4  ;BL = 4                  
    LEA SI, a                    
    LEA DI, mat                  
    
    CALL Input ;CALL Procedure of Input
    
    
    CALL AddRoundKey                  

;;;;;;;;;;;;;;;;;;; Main Method to call all procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Loop1:    
    CALL KeySchedule    
    CALL SubBytes             
    CALL ShiftRows        
    CALL MixColumns
    CALL AddRoundKey
    ADD roundcount,1        ;roundcount++
    
    CMP roundcount,9        ;compare if roundcount = 9?
    JNE Loop1               ;Checks if roundcount = 9? if not jump to Loop1 again 
    
    CALL KeySchedule    
    CALL SubBytes             
    CALL ShiftRows            
    CALL AddRoundKey
    
    PRINTN
    PRINTN
    PRINT "Final Cipher Text:"
    PRINTN
    
    CALL Output
    
    PRINTN          

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END of Main Method ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Input takes input from user as a 16 pair ;;;;;;;;;;;;;;;;;;;;;;;;;;
Input PROC
    ;To preserve the values, we store them in stack segment
    PUSH AX              ;PUSH value of AX into Stack Segment
    PUSH BX              ;PUSH value of BX into Stack Segment
    PUSH CX              ;PUSH value of CX into Stack Segment
    PUSH SI              ;PUSH value of SI into Stack Segment
    
    MOV AH,1             ;AH = 1
    MOV CL,16            ;CL = 16
    XOR CH,CH            ;CH = 0
    XOR SI,SI            ;SI = 0
    PRINTN "Enter the values in hexa format (DON'T PRESS SPACE/ENTER)"
    PRINTN
    
    INPUT1:
     INT 21H
     CALL AdjustDigit    
     
     SAL AL,4
     MOV BL,AL           ;BL = AL
     
     INT 21H
     CALL AdjustDigit
     
     ADD AL,BL           ;AL = AL + BL
     MOV a[SI],AL        ;a[SI] = a[SI] + AL
     ADD SI,1            ;SI++
    LOOP INPUT1
    
    ;Restore values that where in stack segment
    POP SI
    POP CX
    POP BX
    POP AX
   
    RET
Input ENDP

AdjustDigit PROC
    CMP AL,065
    JL Digit
    SUB AL,055
    
    Digit:
     AND AL,0FH
    RET
AdjustDigit ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;; End of Input ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KeySchedule PROC
    ;To preserve the values, we store them in stack segment
    PUSH AX ;PUSH value of AX into Stack Segment   
    PUSH BX ;PUSH value of BX into Stack Segment
    PUSH CX ;PUSH value of CX into Stack Segment
    PUSH DI ;PUSH value of DI into Stack Segment
    PUSH SI ;PUSH value of SI into Stack Segment         
    
    ;;;;;;;;;;;;;;;;;;;;;;; 1st Step (Last Column Shift) ;;;;;;;;;;;;;;;;
    
    MOV AL,key[3]      ;AL = key[3]             
    MOV newkey[12],AL  ;newkey[12] = AL = key[3]  
    
    MOV AL,key[7]      ;AL = key[7]
    MOV newkey[0],AL   ;newkey[0] = AL = key[7]
        
    MOV AL,key[11]     ;AL = key[11]              
    MOV newkey[4],AL   ;newkey[4] = AL = key[11]
        
    MOV AL,key[15]     ;AL = key[15]              
    MOV newkey[8],AL   ;newkey[8] = AL = key[15]
    
    ;;;;;;;;;;;;;;;;;;;;;;; 2nd Step (Byte Sub.) ;;;;;;;;;;;;;;;;;;;;;;;
    
    MOV CL, BL     ;CL = 4
    XOR SI, SI     ;SI = 0

    KeySchedule_Loop0:                 
       MOV AL,newkey[SI]               
       
       CALL SubByte         ;CALL SubByte procedure which gives us the byte index in sbox
       
       MOV  AH,sbox[DI]     ;AH = sbox[DI]   ,Get the byte from sub matrix
       MOV  newkey[SI],AH   ;newkey[SI] = AH ,Array after substiution with the result  

       ADD SI, 4            ;SI = SI + 4                  
       SUB CL,1             ;CL--      
    JNZ KeySchedule_Loop0   ;Check if CL=0?
    
    ;;;;;;;;;;;;;;;;;;;;;;; 3rd Step (XOR) ;;;;;;;;;;;;;;;;;;;;;;;
    
    MOV DI, roundcount  ;DI = roundcount                
    XOR SI, SI          ;SI = 0
    MOV CL, BL          ;CL = BL         

    KeySchedule_Loop1:                        
            MOV AL, key[SI]     ;AL = key[SI]
            MOV AH, newkey[SI]  ;AH = newkey[SI]                    
            XOR AL,AH           
            
            MOV AH,rcon[DI]     ;AH = rcon[DI]
            XOR AL,AH           
                   
            MOV  newkey[SI],AL  ;array after the xor 

            ADD SI, 4           ;SI = SI + 4
            ADD DI, 10          ;DI = DI + 10        
            SUB CL,1            ;CL--         
    JNZ KeySchedule_Loop1              
    
    MOV CH,3                 ;CH = 3, the first column is done, so the outer loop is 3
    MOV SI,1                 ;SI = 1
    KeySchedule_Loop2:
            MOV CL, BL                   ;CL = BL
            KeySchedule_Loop3:                        
                MOV AL, key[SI]          ;AL = key[SI]
                MOV AH, newkey[SI-1]     ;AH = newkey[SI-1]                 
                XOR AL,AH                      
                       
                MOV  newkey[SI],AL       ;array after the xor
    
                ADD SI, 4                ;SI = SI + 4
                SUB CL,1                 ;CL--     
            JNZ KeySchedule_Loop3        ;Check if CL=0?
            
            SUB SI,15                    ;SI = SI - 15
            SUB CH,1                     ;CH--
    JNZ KeySchedule_Loop2                ;Check if CH=0?
    
    ;;;;;;;;;;;;;;;;;;;;;;; Finally Copy newkey into old key ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    MOV CL,16                  ;CL = 16
    XOR SI,SI                  ;SI = 0
    KeySchedule_Loop4:                        
         MOV AL, newkey[SI]    ;AL = newkey[SI]
         MOV key[SI],AL        ;key[SI] = AL = newkey[SI]                         
    
         INC SI                ;SI++
         SUB CL,1              ;CL--       
    JNZ KeySchedule_Loop4      ;Check if CL=0?
            
    ;Restore values that where in stack segment 
    POP SI
    POP DI
    POP CX
    POP BX
    POP AX
    RET
KeySchedule ENDP    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of KeySchedule ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;; SubBytes code gets corresponding value in sbox for each element ;;;;;;;;;;;;;;;;
SubBytes PROC
   ;To preserve the values, we store them in stack segment
   PUSH AX              ;PUSH value of AX into Stack Segment                        
   PUSH CX              ;PUSH value of CX into Stack Segment                        
   PUSH SI              ;PUSH value of SI into Stack Segment                        
   PUSH DI              ;PUSH value of DI into Stack Segment                        
       
   MOV CX, BX           ;CX = BX                 

   SubBytes_Loop1:                   
     MOV CL, BL         ;CL = BL              

     SubBytes_Loop2:                 
       MOV AL, [SI]     ;AL = [SI]      
       
       CALL SubByte     ;CALL SubByte gives us the byte index in sbox      
       
       MOV  AH,sbox[DI] ;AH = sbox[DI]      
       MOV  [SI],AH     ;[SI] = AH      

       INC SI           ;SI++      
       SUB CL,1         ;CL--      
     JNZ SubBytes_Loop2 ;Check if CL=0?         
                    
     Sub CH,1           ;CH--        
   JNZ SubBytes_Loop1   ;Check if CH=0?              
   
   ;Restore values that where in stack segment
   POP DI                     
   POP SI                     
   POP CX                     
   POP AX                     
    
   RET    
SubBytes ENDP
;Assume that input in AL and output in DI

;;;;;;;;;;;;;;;;;;;;;;;;;;; Helper Method for SubBytes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;; SubByte gives us the byte index in sbox ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubByte PROC  
    MOV AH,AL
    
    AND AL,00FH   ;Anding AL with 00FH to get the low byte
    AND AH,0F0H   ;Anding AL with 0F0H to get the high byte
    ROR AH,04     ;Rotating right to let the left bits move to the right
    
    SAL AH,4      ;Shift Arithmitic left is equavilent to AH= AH * 16
    ADD AL,AH     ;To get the required index, AL = AL+AH 
    XOR AH,AH     ;AH = 0 to copy only AL to DI 
    MOV DI,AX     ;DI = AX
    
    RET
SubByte ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of SubBytes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ShiftRows rotates 2nd row with 1 element & 3rd row with 2 elements & 4th row with 3 elements ;;;

ShiftRows PROC
    ;To preserve the values, we store them in stack segment
    PUSH AX              ;PUSH value of AX into Stack Segment                    
    
    ;2nd row shift
    MOV AL,a[4]            
    MOV AH,a[5]          ;a[4] = a[5]                 
    
    MOV a[4],AH          ;a[5] = a[6]
    MOV AH,a[6]
    
    MOV a[5],AH    
    MOV AH,a[7]          ;a[6] = a[7]
    
    MOV a[6],AH    
    MOV a[7],AL          ;a[7] = a[8]
    
    ;3rd row shift
    MOV AL,a[8]          ;AL = a[8]
    MOV AH,a[10]         ;AH = a[10]
    
    MOV a[8],AH          ;a[8] = AH = a[10]
    MOV a[10],AL         ;a[10] = AL = a[8]
    
    MOV AL,a[9]          ;AL = a[9]          
    MOV AH,a[11]         ;AH = a[11]
    
    MOV a[9],AH          ;a[9] = AH  = a[11]
    MOV a[11],AL         ;a[11] = AL = a[9]
    
    ;4th row shift
    MOV AL,a[15]         ;AL = a[15]
    MOV AH,a[14]         ;AH = a[14]
    
    MOV a[15],AH         ;a[15] = AH = a[14]
    MOV AH,a[13]         ;AH = a[13]
    
    MOV a[14],AH         ;a[14] = AH = a[13]
    MOV AH,a[12]         ;AH = a[12]
    
    MOV a[13],AH         ;a[13] = AH = a[12]
    MOV a[12],AL         ;a[12] = AL = a[15]
    
    ;Restore values that where in stack segment
    POP AX                         
    RET    
ShiftRows ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of ShiftRows ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; MixColumns multiplying each column with mat matrix ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MixColumns PROC
   ;To preserve the values, we store them in stack segment
   PUSH AX              ;PUSH value of AX into Stack Segment                        
   PUSH BX              ;PUSH value of BX into Stack Segment          
   PUSH CX              ;PUSH value of CX into Stack Segment          
   PUSH DX              ;PUSH value of DX into Stack Segment          
   PUSH SI              ;PUSH value of SI into Stack Segment          
   PUSH DI              ;PUSH value of DI into Stack Segment          
       
   MOV CX, BX           ;CX = BX           

   MixColumns_Loop1:                   
        MOV DH,BL                    ;DH = BL, middle loop counter
        MixColumns_Loop2:  
             MOV CL, BL               
             XOR AH,AH               ;AH = 0

             MixColumns_Loop3:                 
                   MOV AL, [SI]      ;AL = [SI]
                   MOV DL, [DI]      ;DL = [DI]
                   
                   CMP DL,1          ;checks if DL=1?
                   JE Cont
                   
                   CMP DL,2          ;checks if DL=2?
                   JE  Two           ;if DL=2, jump to TWO
                   JMP Three                  
                   
                   Two:
                   CALL MixColumn2   ;CALL MixColumn2 which adds 2 to the number
                   JMP  Cont   
                   
                   Three:
                   CALL MixColumn3   ;CALL MixColumn3 which adds 3 to the number
             
                   Cont:
                   XOR  AH,AL        
            
                   ADD SI, 4         ;SI = SI+4
                   INC DI            ;DI++
                   SUB CL,1          ;CL--
             JNZ MixColumns_Loop3    ;Checks if CL=0?       
             
             ;To preserve the values, we store them in stack segment
             PUSH AX              ;PUSH value of AX into Stack Segment
             SUB SI,16            ;SI = SI - 16
             SUB DH,1             ;DH--
        JNZ MixColumns_Loop2      ;Checks if DH=0?
        
        ;Move results from stack to array
        MOV CL, BL                  ;CL = BL = 4
        ADD SI,16                   ;SI = SI+16, to prevent entering this loop again we should subtract 16 from SI in the previous loop
                                     
        ResultLoop:                 ;Loop to restore the values that where in stack segment
        POP AX
        SUB SI,4                    ;SI = SI - 4
        MOV [SI],AH                 ;[SI] = [SI] + AH
        SUB CL,1                    ;CL--
        JNZ ResultLoop              ;Checks if CL=0?
        
        INC SI                      ;SI++
        SUB DI,16                   ;DI = DI + 16
        SUB CH,1                    ;CH--
   JNZ MixColumns_Loop1             ;Checks if CH=0? if so jump to outer loop
   
   ;Restore values that where in stack segment
   POP DI                         
   POP SI                         
   POP DX                         
   POP CX                         
   POP BX                         
   POP AX                         
    
   RET    
MixColumns ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Helper Methods for MixColumns ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MixColumn2 adds 2 to the number ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MixColumn2 PROC
    CMP AL, 0                  ;Compares AL with 0
    JL isNegative
    SAL AL,1
    JMP exit1
    isNegative:                ;if left most bit is 1
        SAL AL,1
        XOR AL,00011011B       ;Adds 00011011 to AL
    exit1:    
        RET
MixColumn2 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MixColumn3 adds 3 to the number ;;;;;;;;;;;;;;;;;;;; 
MixColumn3 PROC
    MOV     DL,AL              ;
    CALL    MixColumn2
    XOR     AL,DL              ;
    RET
MixColumn3 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of MixColumns ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; AddRoundKey adds/xors the round key column by column ;;;;;;;;;;;;;;;;;;;
AddRoundKey PROC
   ;To preserve the values, we store them in stack segment
   PUSH AX                  ;PUSH value of AX into Stack Segment         
   PUSH CX                  ;PUSH value of CX into Stack Segment         
   PUSH SI                  ;PUSH value of SI into Stack Segment         
   PUSH DI                  ;PUSH value of DI into Stack Segment         
       
   MOV CX, BX               ;CX = BX         
   XOR SI, SI               ;SI = 0

   AddRoundKey_Loop1:                   
     MOV CL, BL             ;CL = BL          

     AddRoundKey_Loop2:                 
           MOV AL,a[SI]     ;AL = a[SI]          
           MOV AH,key[SI]   ;AH = key[SI]
           XOR AL,AH        
           
           MOV  a[SI],AL    ;a[SI] = AL             
    
           ADD SI, 4        ;SI = SI + 4          
           SUB CL,1         ;CL--          
     JNZ AddRoundKey_Loop2  ;Checks if CL=0?           
     SUB SI,15              ;SI = SI - 15 
     SUB CH,1               ;CH--      
   JNZ AddRoundKey_Loop1    ;Checks if CH=0?           
   
   ;Restore values that where in stack segment
   POP DI                         
   POP SI                         
   POP CX                         
   POP AX                         
    
   RET
AddRoundKey ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of AddRoundKey ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Output prints the resultant array ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Output PROC
    ; this procedure will print the given 2D array
    ; input : SI=offset address of the 2D array
    ;       : BH=number of rows
    ;       : BL=number of columns 
    ; output : none

   ;To preserve the values, we store them in stack segment
   PUSH AX                        ;PUSH value of AX into Stack Segment
   PUSH CX                        ;PUSH value of CX into Stack Segment
   PUSH DX                        ;PUSH value of DX into Stack Segment
   PUSH SI                        ;PUSH value of SI into Stack Segment
   
   MOV CX, BX                     ;CX = BX

   @OUTER_LOOP:                   
     MOV CL, BL                   ;CL = BL

     @INNER_LOOP:                 
       MOV AH,2                   ;AH = 2
       MOV DL,20H                 ;DL = 20H
       INT 21H                    
                             
       MOV AL,[SI]                ;AX = [SI]
                            
       CALL OUTDEC                ;CALL OUTDEC procedure

       INC SI                     ;SI++
       SUB CL, 1                  ;CL--
     JNZ @INNER_LOOP              ;Checks if CL=0?
                           
     MOV AH,2                     ;AH = 2
     MOV DL,0DH                   ;DL = 0DH
     INT 21H                      

     MOV DL,0AH                   ;DL = 0AH
     INT 21H                      

     SUB CH,1                     ;CH--
   JNZ @OUTER_LOOP                ;Checks if CX=0?
   
   MOV AH,2                       ;AH = 2
   MOV DL,0AH                     ;DL = 20H
   INT 21H

   ;Restore values that where in stack segment
   POP SI                         
   POP DX                         
   POP CX                         
   POP AX                         

   RET
Output ENDP

OUTDEC PROC
   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK
    
   mov cx,2         ; print 2 hex digits ( 8 bits)
    .print_digit:
        rol al,4   ; move the currently left-most digit into the least significant 4 bits
        mov dl,al
        and dl,0xF  ; isolate the hex digit we want to print
        add dl,'0'  ; and convert it into a character..
        cmp dl,'9'  ; ...
        jbe .ok     ; ...
        add dl,7    ; ... (for 'A'..'F')
    .ok:            ; ...
        push ax    ; save EAX on the stack temporarily
        mov ah,2    ; INT 21H / AH=2: write character to std out
        int 0x21
        pop ax     ; restore EAX
        loop .print_digit
        
   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX
   ret                     ; return control to the calling procedure
OUTDEC ENDP                                                         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of Output ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; THE END ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;