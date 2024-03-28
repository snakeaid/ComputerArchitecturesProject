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

; Loop stored keys
loop_stored_keys:
    ; Check keys
    cmp bx, countKeys               ; Has more keys ?
    jge loop_stored_keys_new        ; Done
    ; Compare keys
    lea si, dataKey                 ; SI <-- Current key
    lea di, arrayKeys               ; DI <-- Key from array
    mov cx, bx
    imul cx, KEY_SIZE
    add di, cx
    call string_compare             ; Do key comparison
    ; Check comparison result
    cmp al, TRUE                    ; Key exists ?
    je loop_stored_key_exists       ; Key already exists
    ; Key does not exist
    inc bx                          ; Next key
    jmp loop_stored_keys            ; Continue loop

; Loop stored key new
loop_stored_keys_new:
    ; Add new key
    lea si, dataKey                 ; SI <-- Current key
    lea di, arrayKeys               ; DI <-- Key from array
    mov cx, bx
    imul cx, KEY_SIZE
    add di, cx
    cld                             ; Clear dir flag
    mov cx, KEY_SIZE                ; Rep count
    rep                             ; Do rep
    movsb                           ; Move bytes from address at SI -> to address at DI
    ; Word offset fix
    shl bx, 01h                     ; BX <-- BX * 2
    ; Update key values sum
    lea di, arraySum                ; DI <-- Values sum from array
    mov ax, word ptr ds:[di + bx]   ; Get values sum
    add ax, dataValueBin            ; Add current value to sum
    mov word ptr ds:[di + bx], ax   ; Set values sum
    ; Update key values count
    lea di, arrayCount              ; DI <-- Values count from array
    mov ax, word ptr ds:[di + bx]   ; Get values count
    inc ax                          ; Increment values count
    mov word ptr ds:[di + bx], ax   ; Store values count
    ; Word offset fix restore
    shr bx, 01h                     ; BX <-- BX / 2
    ; Go to next key
    inc countKeys                   ; Increment keys counter
    jmp loop_stored_keys_exit       ; Done

; Loop stored key exists
loop_stored_key_exists:
    ; Word offset fix
    shl bx, 01h                     ; BX <-- BX * 2
    ; Update key values sum
    lea di, arraySum                ; DI <-- Values sum from array
    mov ax, word ptr ds:[di + bx]   ; Get values sum
    add ax, dataValueBin            ; Add current value to sum
    mov word ptr ds:[di + bx], ax   ; Set values sum
    ; Update key values count
    lea di, arrayCount              ; DI <-- Values count from array
    mov ax, word ptr ds:[di + bx]   ; Get values count
    inc ax                          ; Increment values count
    mov word ptr ds:[di + bx], ax   ; Store values count
    ; Word offset fix restore
    shr bx, 01h                     ; BX <-- BX / 2

; Loop stored keys exit
loop_stored_keys_exit:
    ; Get next line
    cmp countLines, MAX_LINE_COUNT  ; Max lines received ?
    jge loop_read_exit              ; Done
    jmp loop_read                   ; Next line

; Read loop done
loop_read_exit:
    ; Find key in table
    xor bx, bx                      ; BX <-- 0

; Loop calc average
loop_calc_average:
    ; Check keys
    cmp bx, countKeys               ; Has more keys ?
    jge loop_calc_average_end       ; Done
    ; Word offset fix
    shl bx, 01h                     ; BX <-- BX * 2
    ; Get key values sum
    lea di, arraySum                ; DI <-- Values sum from array
    mov ax, word ptr ds:[di + bx]   ; Get values sum
    mov dx, 0000h                   ; DX <-- 0
    ; Get key values count
    lea di, arrayCount              ; DI <-- Values count from array
    mov cx, word ptr ds:[di + bx]   ; Get values count
    idiv cx                         ; Divide values sum by values count
    ; Store key value average
    lea di, arrayAverage            ; DI <-- Average from array
    mov word ptr ds:[di + bx], ax   ; Store average value
    ; Word offset fix restore
    shr bx, 01h                     ; BX <-- BX / 2
    ; Next average calc
    inc bx                          ; Next key
    jmp loop_calc_average           ; Continue loop
    
; Loop calc average end
loop_calc_average_end:
    ; Sort
    call bubble_sort                ; Sort array
    ; Print keys
    xor cx, cx                      ; CX <-- 0