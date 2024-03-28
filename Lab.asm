; Memory model
.MODEL SMALL
; Stack size
.STACK 100h


; CPU Arch
.386


; Data segment
.DATA

    ; FALSE
    FALSE equ 00h
    ; TRUE
    TRUE equ 0FFh

    ; EOL
    EOL equ 00h
    ; HOR. TAB
    HTAB equ 09h
    ; LF
    LF equ 0Ah
    ; VERT. TAB
    VTAB equ 0Bh
    ; CR
    CR equ 0Dh
    ; SPACE
    SPACE equ 20h
    ; EOF
    EOF equ 1Ah

    ; Maximum value
    MAX_VALUE equ 10000
    ; Minimum value
    MIN_VALUE equ -10000

    ; Maximum lines count
    MAX_LINE_COUNT equ 10000

    ; Line buffer size
    LINE_SIZE equ 32
    ; Key buffer size
    KEY_SIZE equ 16
    ; Value buffer size
    VALUE_SIZE equ 8

    ; Buffer to receive line
    dataLine db LINE_SIZE DUP(EOL),'$'

    ; Buffer for parsed key
    dataKey db KEY_SIZE DUP(EOL),'$'
    ; Buffer for parsed value
    dataValue db VALUE_SIZE DUP(EOL),'$'

    ; Parsed value sign
    dataValueSign db 0
    ; Parsed binary value
    dataValueBin dw 0

    ; Received lines count
    countLines dw 0

    ; Received keys count
    countKeys dw 0

    ; Keys
    arrayKeys db LINE_SIZE*KEY_SIZE DUP(EOL),'$'
    ; Sum of key values
    arraySum dw  LINE_SIZE DUP(0)
    ; Count values
    arrayCount dw LINE_SIZE DUP(0)
    ; Average values
    arrayAverage dw LINE_SIZE DUP(0)

; Code segment
.CODE

    ; Go to entry point
    jmp start


; Entry point
start:
    ; Segments setup
    mov ax, @data                   ; Get CS
    mov ds, ax                      ; Make DS point to CODE segment
    mov es, ax                      ; Make ES point to CODE segment
    mov ss, ax                      ; Make SS point to CODE segment

; Input loop
loop_read:
    ; Read line
    call line_read                  ; Do read line
    ; Check EOF
    cmp al, EOF                     ; EOF ?
    je loop_read_exit               ; Done processing input
    ; Update line count
    inc countLines                  ; Increment lines count
    ; Parse line
    call line_parse                 ; Parse <key> <value>
    ; Convert value
    call decimal_convert            ; Convert value from dec to bin
    ; Find key in table
    xor bx, bx                      ; BX <-- 0