assume cs:code ds:data
data segment    
    foodx   db  1               ; x-coord of food
    foody   db  15              ; y-coord of food
    
    snakex  db  20  dup(?)      ; array of x coords of snake
    snakey  db  20  dup(?)      ; array of y coords of snake
    
    tailx   db  ?               ; x-coord of tail of snake
    taily   db  ?               ; y-coord of tail of snake
    
    taildel db  0               ; flag that checks if the tail is to be deleted or not ()
    
    len     dw  2               ; len of snake
    
    score_msg   db  'Score: 00$'                            ; Score message
    gover_msg   db  'Game Over$'                            ; Game Over message
    new_msg     db  'Do you want to play once again(Y/N)$'  ; Play again message

    dirc        db  1           ; Direction of motion of head
data ends
code segment                    
start:    
    MOV AX,data
    MOV ds, AX 
     
    GOTOXY  MACRO   col, row
        PUSH    AX
        PUSH    BX
        PUSH    DX
        MOV     AH, 02h
        MOV     DH, row
        MOV     DL, col
        MOV     BH, 0
        INT     10h
        POP     DX
        POP     BX
        POP     AX
    ENDM         
    
    MOV     len,    2           ; Initialize length of snake to 2
    
    MOV SI, offset snakex       ; snake inital positions (15, 15) (15, 16)
    MOV AL, 15
    MOV [SI], AL
    INC SI
    MOV [SI], AL
    
    MOV SI, offset snakey
    MOV [SI], AL
    INC SI      
    INC AL
    MOV [SI], AL 

    MOV AH, 00H                 ; initializes the display to video mode
    MOV AL, 03H                 ; with ascii/text 80x25
    INT 10H         
    
    call make_border
    call print_score               
    call print_food
    call update_snake  
    
    here:
    call check_direc
    call update_snake 
    call print_food
    
    MOV DX, 10                  ; change the speed of snake
    delay:
    
    MOV CX, 0FFFFH              ; delay to slow the motion of snake
    del: loop del
    
    DEC DX
    jnz delay
    
    jmp here 
          
          
    check_self proc             ; iterates through the length of the snake array and checks whether
        MOV AL, snakex          ; the snake is biting itself
        MOV AH, snakey
        
        MOV SI, offset snakex
        MOV DI, offset snakey
        
        INC SI
        INC DI
        
        MOV CX, len
        DEC CX
        chk_x:
            cmp AL, [SI]
            jz chk_y
            jmp cont        
            
                    
        chk_y: 
            cmp AH, [DI] 
            jz bridge           ; bridges the gap between this statement and game over (long jump)
            jmp cont
        
        
        cont:
            INC SI
            INC DI
            loop chk_x
        ret
    check_self endp     

    
    print_score proc            ; Prints scoreboard on the top right corner(70, 0)
        MOV AX, len
        DEC AX
        DEC AX                  ; the score is same as length - 2
        MOV BL, 10              ; the two digits are separated
        DIV BL
        
        add al, 30h             ; They are replaced in the score_msg 00 locations
        MOV SI, offset score_msg
        ADD SI, 7
        MOV [SI], AL
        add ah, 30h     
        MOV SI, offset score_msg
        ADD SI, 8
        MOV [SI], AH
        
        GOTOXY 70, 0
        mov dx,offset score_msg
        mov ah,9
        int 21h   
    
    print_score endp            


    check_border proc           ; Checks whether the snake touches the border
        MOV AL, snakex
        CMP AL, 0
        jz bridge 
        CMP AL, 79
        jz bridge
        MOV AL, snakey
        CMP AL, 1
        jz bridge
        CMP AL, 24
        jz bridge
        RET
    check_border endp
    
    bridge:                     ; bridges the gap for a long jump
    jmp G_over
    
    make_border proc            ; draws the border
        MOV SI, 00H
        MOV DI, 00H
        MOV DL, 79   
        top_border:             ; draws the top border
            GOTOXY DL, 1
            MOV AH, 09H
            MOV AL, 220
            MOV BH, 00H
            MOV BL, 0FH
            MOV CX, 01H
            INT 10H
            DEC DL
            jnz top_border
        
        MOV DL, 79
        bot_border:             ; draws the bottom border
            GOTOXY DL, 24
            MOV AH, 09H
            MOV AL, 220
            MOV BH, 00H
            MOV BL, 0FH
            MOV CX, 01H
            INT 10H
            DEC DL
            jnz bot_border
        
        MOV DL, 24              
        lef_border:             ; draws the left border
            GOTOXY 0, DL
            MOV AH, 09H
            MOV AL, 222
            MOV BH, 00H
            MOV BL, 0FH
            MOV CX, 01H
            INT 10H
            DEC DL
            jnz lef_border
            
        MOV DL, 24    
        rgt_border:             ; draws the right border
            GOTOXY 79, DL
            MOV AH, 09H
            MOV AL, 221
            MOV BH, 00H
            MOV BL, 0FH
            MOV CX, 01H
            INT 10H
            DEC DL
            jnz rgt_border  
        RET      
    make_border endp 

    
    check_direc proc            ; direction change using asdw keys
        MOV AH, 6               ; checks the buffer for keystroke
        MOV DL, 255
        INT 21H 

        cmp AL, 61H             ; compares to a for left
        jz direc_l 
        
        cmp AL, 73H             ; compares to s for down
        jz direc_d
        
        cmp AL, 64H             ; compares to d for right
        jz direc_r
        
        cmp AL, 77H             ; compares to w for up
        jz direc_u
        
        jmp retrn
        
        direc_l:
            cmp dirc, 2         ; checks if the entered direction is opposite, like you cant go right while going left
            jz retrn
            MOV dirc, 4         ; else updates the direction to left
            jmp retrn
        direc_d:
            cmp dirc, 1          
            jz retrn
            MOV dirc, 3         ; else updates the direction to down
            jmp retrn
        direc_r:  
            cmp dirc, 4
            jz retrn
            MOV dirc, 2         ; else updates the direction to right
            jmp retrn
        direc_u:
            cmp dirc, 3
            jz retrn
            MOV dirc, 1         ; else updates the direction to up
            jmp retrn

        retrn:
        RET
    check_direc endp
    

    update_snake proc           ; updates the snake array of x coords and y coords according to the direction 
        MOV SI, offset snakex
        ADD SI, len    
        DEC SI
        MOV AL, [SI]
        MOV tailx, AL
        
        MOV SI, offset snakey
        ADD SI, len    
        DEC SI
        MOV AL, [SI]
        MOV taily, AL
        
        MOV DX, len

        DEC DX
        l2:                         ; loops from last element to first updating each one to the previous element
            MOV SI, offset snakex
            ADD SI, DX    
            DEC SI
            MOV AL, [SI]
            INC SI
            MOV [SI], AL
            
            MOV SI, offset snakey
            ADD SI, DX    
            DEC SI
            MOV AL, [SI]
            INC SI
            MOV [SI], AL
            
            DEC DX
            jnz l2
        
        CMP dirc, 4             ; checks the direction of motion to update the head
        JZ left
        CMP dirc, 3
        JZ down
        CMP dirc, 2
        JZ right
        CMP dirc, 1
        JZ up
                                ; direction in which the head will shift to
        left:                   ; left
            MOV AL, snakex
            DEC AL    
            MOV snakex, AL
            JMP upd
        down:                   ; down
            MOV AL, snakey
            INC AL
            MOV snakey, AL
            JMP upd    
            
        right:                  ; right
            MOV AL, snakex
            INC AL    
            MOV snakex, AL
            JMP upd    
            
        up:                     ;up
            MOV AL, snakey
            DEC AL    
            MOV snakey, AL
            JMP upd    

        upd:                        ; update the snake and check if it is eating the food or bititng itself
           call check_border        ; or biting the border.
           call check_self
           MOV AL, foodx
           cmp AL, snakex
           jz chky
           jmp prt
           
        chky:
            MOV AL, foody
            cmp AL, snakey
            jz inclen               
            jmp prt
            
        inclen:                     ; increase length and update parameters if it is eating the food
            MOV AX, len 
            INC AX
            MOV len, AX
            MOV AL, tailx           
            MOV BX, len
            DEC BX
            
            MOV SI, offset snakex   ; tail updated
            ADD SI, BX
            MOV [SI], AL
            
            MOV AL, taily
            
            MOV SI, offset snakey
            ADD SI, BX
            MOV [SI], AL

            MOV taildel, 1          ; taildel parameter set to 1 such that tail is not deleted in this case
                          
            ; Randomizing the food generation

            MOV AH, 00h             ; Create a Random number using the system time.
            INT 1AH                 ; CX:DX will contain the number of clock ticks since midnight.           
            
            xor  cx, dx             ; CX xor DX will result in a random number
            and cx, 00111111b       ; reduced the size of the number for division
            mov  ax, cx 
            MOV BL, 4EH             ; number divided with 78 so as the mod will have number between 0 to 77  (x coord)    
            div BL     
            INC AH                  ; removing border to get number between 1 and 78
            mov foodx, AH
            
            MOV AH, 00h  
            INT 1AH 

            xor  cx, dx        
            and cx, 00111111b
            mov  ax, cx 
            MOV BL, 016H            ; number divided with 78 so as the mod will have number between 0 to 21  (y coord)
            div BL     
            INC AH
            INC AH                  ; removing border to get number between 2 to 23
            mov foody, AH       
            
        prt:                        ; calls the print snake function      
           call print_snake
           RET
    update_snake endp
            
          
    print_food proc             ; prints the food according to foodx and foody
        LEA SI, foodx
        LEA DI, foody
        GOTOXY [SI], [DI]      
        GOTOXY foodx, foody      
        MOV AH, 09H
        MOV AL, 220
        MOV BH, 00H
        MOV BL, 0CH
        MOV CX, 01H
        INT 10H
        RET    
    print_food endp
    
    
    print_snake proc            ; prints the snake according to the x and y coords in the snake array
        MOV DX, len
        LEA SI, snakex
        LEA DI, snakey
        l1:                     ; loops through the array and prints at the coords
            GOTOXY [SI], [DI] 
            MOV AH, 09H
            MOV AL, 002
            MOV BH, 00H
            MOV BL, 0AH
            MOV CX, 01H
            INT 10H
            INC SI
            INC DI
            DEC DX
            jnz l1  
        
        cmp taildel, 1          ; removes tail if taildel == 0 
        jz tailrem              ; else keeps the tail
    
        GOTOXY tailx, taily     ; remove tail
        MOV AH, 09H 
        MOV AL, 0FFH
        MOV BH, 00H
        MOV BL, 0AH
        MOV CX, 01H
        INT 10H
        
        jmp retval    
        
        tailrem:
        mov taildel, 0 
        call print_score        ; once tail is removed new score is printed and new food is printed
        call print_food 
        
        retval:
        
        RET 
    print_snake endp
    
    restart:
        jmp start               ; long jump helper for restart

    G_over:                     ; Game over screen 
        MOV AH, 00H             ; Resets the screen for Game over output
        MOV AL, 03H             
        INT 10H       
        
        GOTOXY 34, 10           ; prints Game over
        mov dx, offset gover_msg
    	mov ah, 9
    	int 21h   
    	        
    	GOTOXY 34, 11           ; prints Score
        mov dx, offset score_msg
    	mov ah, 9
    	int 21h 
    	
    	GOTOXY 20, 12           ; prints do you want to play again message
        mov dx, offset new_msg
    	mov ah, 9
    	int 21H    
    	

        char_chk:
    	mov ah, 7               ; takes input single char
    	int 21H
    	
    	cmp al, 89              ; compares input with 'Y'
    	jz restart
        jmp char_chk

code ends 
end start