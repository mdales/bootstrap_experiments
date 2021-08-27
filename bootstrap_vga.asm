BITS 16
ORG 0x7c00

TIMER_IVT_OFFSET equ 8*4             ; Base address of keyboard interrupt (IRQ) in IVT
KBD_IVT_OFFSET equ 9*4             ; Base address of keyboard interrupt (IRQ) in IVT

start:
    ; Set up memory map
    mov ax, 0x0
    mov ds, ax

    mov ss, ax
    mov sp, 0x7c00

    ; Set up interrupt handlers
    cli
    mov word [KBD_IVT_OFFSET], keyboard_isr
    mov [KBD_IVT_OFFSET + 2], ax
    mov word [TIMER_IVT_OFFSET], timer_isr
    mov [TIMER_IVT_OFFSET + 2], ax
    sti

    ; go into vga mode
    mov ah, 0x0
    mov al, 0x13
    int 10h

    ; now we're in VGA mode 320x200x8
    mov ax, 0xA000
    mov es, ax

    call clear_screen

.main_loop:

    mov dl, [last_key]
    
    mov bx, [state]
    mov ax, [state + 2]
    mov byte cl, [state + 4]

    cmp dl, 0x11
    jne .main_post_w
    cmp ax, 0
    je .main_loop_end
    dec ax
    jmp .main_loop_end
.main_post_w:

    cmp dl, 0x1E
    jne .main_post_a
    cmp bx, 0
    je .main_loop_end
    dec bx
    jmp .main_loop_end
.main_post_a:

    cmp dl, 0x1F
    jne .main_post_s
    cmp ax, 199
    je .main_loop_end
    inc ax
    jmp .main_loop_end
.main_post_s:

    cmp dl, 0x20
    jne .main_post_d
    cmp bx, 319
    je .main_loop_end
    inc bx
    jmp .main_loop_end
.main_post_d:

    cmp dl, 0x1
    jne .main_loop_end
    call clear_screen

.main_loop_end:
    inc cl

    call draw_cursor

    mov [state], bx
    mov [state + 2], ax
    mov byte [state + 4], cl

    hlt
    jmp .main_loop


clear_screen:
    push di

    ; fill the screen with light grey
    mov di, 320 * 200
.drawrepeat:
    dec di
    mov byte [es:di], 0x07
    cmp di, 0
    jne .drawrepeat

    pop di
    ret

draw_cursor:
    cmp ax, 200
    jge .done_draw_cursor
    cmp ax, 0
    jl .done_draw_cursor
    cmp bx, 320
    jge .done_draw_cursor
    cmp bx, 0
    jl .done_draw_cursor

    push ax
    push bx
    push dx
    push di

    mov dx, 320
    mul dx
    add bx, ax
    mov di, bx
    mov byte [es:di], cl

    pop di
    pop dx
    pop bx
    pop ax
.done_draw_cursor:
    ret


    last_key db 0, 0, 0, 0
    state db 0, 0, 0, 0, 0, 0



keyboard_isr:
    push ax
    push bx
    
    in al, 0x60  ; even if you don't care, you need to clear the character
    
    cmp al, 0x11                    ; w scan code
    jne .post_w
    jmp .store

.post_w:
    cmp al, 0x1E                    ; a scan code
    jne .post_e
    jmp .store

.post_e:
    cmp al, 0x1F                    ; s scan code
    jne .post_s
    jmp .store

.post_s:
    cmp al, 0x20                    ; d scan code
    jne .post_d
    jmp .store

.post_d:
    cmp al, 0x01                    ; escape scan code
    jne .done_kisr
    jmp .store

.store:
    mov byte [last_key], al 
.done_kisr:
    mov al, 0x20
    out 0x20, al                    ; Send EOI to Master PIC
    
    pop bx
    pop ax
    iret

timer_isr:
    push ax
    mov al, 0x20
    out 0x20, al                   ; Send EOI to Master PIC
    pop ax
    iret

times 510 - ($-$$) db 0                                   ; Boot signature
dw 0xAA55
