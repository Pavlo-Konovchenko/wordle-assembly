*-----------------------------------------------------------
* Title      : Wordle
* Written by : Pavlo Konovchenko (c00312835)
* Description: A simple Wordle game.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.L #$8000, SP 
    MOVE.W #0, D5
    LEA GAME_CAPTION, A1
    BSR PRINT_STR
    
    JMP GAME_START
    
GAME_START:

* Put program code here
; print welcome message
    LEA ENTER_MESSAGE1, A1
    BSR PRINT_STR_NONL
    
    MOVE.W #6, D1
    SUB.W D5, D1
    MOVE.B #3, D0
    TRAP #15
    
    LEA ENTER_MESSAGE2, A1
    BSR PRINT_STR
    
; take input
    LEA INPUT, A1
    MOVE.B #2, D0
    TRAP #15
    BSR CHECK_LENGTH ; check if we received a word that is exactly 5 letters
    CMP.W #5, D2
    BNE INVALID_INPUT ; if we didn't, let the user know and let them try again without decreasing the tries
    BRA VALID_INPUT ; if we did, move on
INVALID_INPUT:
    LEA INVALID_MESSAGE, A1
    BSR PRINT_STR
    JMP GAME_START
    
VALID_INPUT:
; initialize variables to the registers
    LEA INPUT, A0
    LEA EXACT, A2
    LEA PARTIAL, A3
    
; initialize counter for the outer loop
    MOVE.W #0, D3
   
OUTER_LOOP:
; creating a pointer to the input (only to the letter)
    MOVE.B (A0), D0

; initializing counter for the inner loop
    MOVE.W #0, D4
    LEA SECRET_WORD, A1
    
INNER_LOOP:
; taking only the letter from SECRET_WORD
    MOVE.B (A1), D1
; comparing SECRET_WORD letter to INPUT letter
    CMP.B D1, D0
    BNE NO_MATCH ; branching to NO_MATCH if there's no match
    
; since we didn't branch, means the letters are the same, so we check if they are in the same place
    CMP.W D4, D3
; if they are not, branch to yellow
    BNE YELLOW_MATCH
    
GREEN_MATCH:
    MOVE.B #1, (A2) ; adding a 1 to EXACT to indicate that one of the letters is right
    BRA NO_MATCH
    
YELLOW_MATCH:
    MOVE.B #1, (A3) ; adding a 1 to PARTIAL to indicate that one of the letters is right but wrong place
    
NO_MATCH:
    ADDQ.L #1, A1 ; move on to the next letter in the SECRET_WORD
    ADDQ.W #1, D4 ; increase its counter
    CMP.W #5, D4 ; if we haven't checked all the letters yet, go back to INNER_LOOP
    BNE INNER_LOOP
    
; if we have checked the input letter against all SECRET_WORD letters
    ADDQ.L #1, A0 ; go to the next character in INPUT
    ADDQ.L #1, A2 ; go to the next character in EXACT
    ADDQ.L #1, A3 ; go to the next character in PARTIAL
    ADDQ.W #1, D3 ; increase the counter of the outer loop
    CMP.W #5, D3 ; if we haven't checked all the input characters yet, go back to OUTER_LOOP
    BNE OUTER_LOOP
    
    ADDQ.W #1, D5
    
; check if all letters are correct
    LEA     EXACT, A2
    MOVE.W  #0, D3

CHECK_WIN:
    MOVE.B (A2), D1 ; move EXACT first symbol to D1
    CMP.B #1, D1
    BNE CHECK_LOSE ; if any slot is not 1, skip to normal print
    ADDQ.L #1, A2
    ADDQ.W #1, D3
    CMP.W #5, D3
    BNE CHECK_WIN

; if we get here all 5 were 1 = win!
    LEA WIN_MESSAGE, A1
    BSR PRINT_STR
    
    JMP GAME_END
    
CHECK_LOSE:
    CMP.W #6, D5 ; check if we ran out of tries
    BNE AFTER_LOOP ; if we didn't continue as normal
    
    LEA LOSE_MESSAGE, A1 ; if we did, print the lose message and reveal the secret word
    BSR PRINT_STR
    
    LEA SECRET_WORD, A1
    BSR PRINT_STR
    
    JMP GAME_END
    
AFTER_LOOP:
    LEA EXACT, A2 ; restart both EXACT and PARTIAL, so we can go through them again
    LEA PARTIAL, A3
    MOVE.W #0, D3
    
PRINT_LOOP:
    MOVE.B (A2), D1 ; if there is a 1 in EXACT, means it's a green match
    CMP.B #1, D1
    BEQ PRINT_GREEN
    
    MOVE.B (A3), D1 ; if there wasn't a 1 in EXACT, but a 1 in PARTIAL means it's yellow match
    CMP.B #1, D1
    BEQ PRINT_YELLOW
    
    MOVE.B #'X', D1 ; if both were 0 means that there was no match at all
    BRA PRINT_CHAR
    
PRINT_GREEN:
    MOVE.B #'V', D1
    BRA PRINT_CHAR
    
PRINT_YELLOW:
    MOVE.B #'-', D1

PRINT_CHAR:    
    MOVE.B #6, D0
    TRAP #15
    
    ADDQ.L #1, A2
    ADDQ.L #1, A3
    ADDQ.W #1, D3
    CMP.W #5, D3
    BNE PRINT_LOOP
    
; draw a new line before outputting 'Enter a word' again
    LEA NEWLINE, A1
    BSR PRINT_STR
    
; clear EXACT and PARTIAL back to 0
    BSR CLEAR_ARRAYS
    JMP GAME_START


GAME_END:
    SIMHALT             ; halt simulator
    
; subroutines
PRINT_STR: ; shortcut to print stuff using task 13
    MOVE.L D0, -(SP)
    MOVE.B #13, D0
    TRAP #15
    MOVE.L (SP)+, D0
    RTS
PRINT_STR_NONL: ; shortcut to print stuff using task 14
    MOVE.L D0, -(SP)
    MOVE.B #14, D0
    TRAP #15
    MOVE.L (SP)+, D0
    RTS
    
CLEAR_ARRAYS: ; clears the EXACT and PARTIAL arrays for the next iteration
    MOVEM.L D3/A2/A3, -(SP) ; preserve values in the slots we are about to use
    LEA EXACT, A2
    LEA PARTIAL, A3
    MOVE.W #0, D3
CLEAR_LOOP:
    MOVE.B #0, (A2)
    MOVE.B #0, (A3)
    ADDQ.L #1, A2
    ADDQ.L #1, A3
    ADDQ.W #1, D3
    CMP.W #5, D3
    BNE CLEAR_LOOP
    MOVEM.L (SP)+, D3/A2/A3
    RTS
    
CHECK_LENGTH:
    MOVEM.L D0/A0, -(SP) ; preserving what's in D0 and A0
    LEA INPUT, A0 ; putting INPUT into A0
    MOVE.W #0, D2 ; putting counter into D2
COUNT_LOOP:
    MOVE.B (A0)+, D0 ; putting the current letter from INPUT into D0
    CMP.B #0, D0
    BEQ COUNT_DONE ; if there is nothing there we are done
    CMP.B #$0D, D0
    BEQ COUNT_DONE ; making sure there is nothing there by checking for carriage return
    ADDQ.W #1, D2 ; if the previous two checks were passed, increase the counter
    BRA COUNT_LOOP ; loop
COUNT_DONE:
    MOVEM.L (SP)+, D0/A0 ; when we are done, return the values from the stack to their positions
    RTS
    

* Put variables and constants here
GAME_CAPTION  DC.B '==================================', $0D, $0A
              DC.B '             WORDLE               ', $0D, $0A
              DC.B '==================================', $0D, $0A, 0
SECRET_WORD DC.B 'apple', 0
ENTER_MESSAGE1 DC.B 'Enter a word (You have ', 0
ENTER_MESSAGE2 DC.B ' tries left): ', 0
INPUT DS.B 20
INVALID_MESSAGE DC.B 'You must enter a 5 letter word. Try again.', 0 
EXACT DS.B 5
PARTIAL DS.B 5
NEWLINE DC.B $0D, $0A, 0
WIN_MESSAGE DC.B 'You guessed the secret word.', $0D, 0
LOSE_MESSAGE DC.B 'You are out of tries. The word was: ', $0D, 0
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
