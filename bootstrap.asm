    BITS 16

jmp start

keyboard_interrupt:
    push ax
    push si

    mov si, text_string     ; Put string poisition into SI
    call print_string

    pop si
    pop ax


;     push di
;     push es
;     push ax

;     ; fill the screen with light grey
;     mov di, 320 * 200    
;     mov ax, 0xA000
;     mov es, ax
; .drawrepeat_isr:
;     dec di
;     mov byte [es:di], 0x07
;     cmp di, 0
;     jne .drawrepeat_isr

;     pop ax
;     pop es
;     pop di
    iret
    

start:
    ; install keyboard handler
    cli
    mov ax, 0
    mov es, ax
    mov word [es:(9 * 4)], keyboard_interrupt
    mov word [es:(9 * 4) + 2], ax
    sti

    ; set up general use
    mov ax, 07C0h           ; Set up 4K stack space after bootloader
    add ax, 288             ; (4096 + 512) / 16 bytes per paragraph
    mov ss, ax
    mov sp, 4096

    mov ax, 07C0h           ; Set data segment to where we're loaded
    mov ds, ax

    ; general code
    mov si, text_string     ; Put string poisition into SI
    call print_string


    jmp $                   ; infinite loop to stop

;     ; now we have some text, jump to VGA mode
;     mov ah, 0x0
;     mov al, 0x13
;     int 10h

;     ; now we're in VGA mode 320x200x8bpp
;     mov ax, 0xA000
;     mov es, ax

;     ; fill the screen with light grey
;     mov di, 320 * 200
; .drawrepeat:
;     dec di
;     ; mov di, dx
;     mov byte [es:di], 0x07
;     cmp di, 0
;     jne .drawrepeat

;     ; now draw a line
;     mov cx, 255; 0x000F
; .drawlines:
;     mov dx, 199
; .drawrepeat2:
;     dec dx
;     mov ax, dx ; y
;     mov bx, dx ; x
;     add bx, cx
;     sub bx, 60
;     call plot_pixel
;     cmp dx, 0
;     jne .drawrepeat2

;     dec cx
;     cmp cx, -1
;     jne .drawlines

;     jmp $                   ; infinite loop to stop

    text_string db 'This is our bootloader', 0
    position db 0, 0, 0, 0

print_string:
    mov ah, 0Eh             ; int 10h 'print char' function ID
.repeat:
    lodsb
    cmp al, 0
    je .done
    int 10h
    jmp .repeat

.done:
    ret

; ax = y, bx = x, cx = colour
plot_pixel:
    cmp ax, 200
    jge .done_plot_pixel
    cmp ax, 0
    jl .done_plot_pixel
    cmp bx, 320
    jge .done_plot_pixel
    cmp bx, 0
    jl .done_plot_pixel
    push dx
    mov dx, 320
    mul dx
    add bx, ax
    mov di, bx
    ; mov ax, 0xA000
    ; mov es, ax
    mov byte [es:di], cl
    pop dx
.done_plot_pixel:
    ret

    ; pad bootloader
    times 510 - ($ - $$) db 0
    dw 0xAA55
