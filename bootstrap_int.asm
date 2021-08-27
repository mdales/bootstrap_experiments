BITS 16
ORG 0x7c00

TIMER_IVT_OFFSET equ 8*4             ; Base address of keyboard interrupt (IRQ) in IVT
KBD_IVT_OFFSET equ 9*4             ; Base address of keyboard interrupt (IRQ) in IVT

start:
    mov ax, 0x0
    mov ds, ax

    mov ss, ax
    mov sp, 0x7c00

    cli
    mov word [KBD_IVT_OFFSET], keyboard_isr
    mov [KBD_IVT_OFFSET + 2], ax
    mov word [TIMER_IVT_OFFSET], timer_isr
    mov [TIMER_IVT_OFFSET + 2], ax
    sti

    mov si, text_string_a     ; Put string poisition into SI
    call print_string
.main:
    hlt
    jmp .main

keyboard_isr:
    push si
    push ax

    in al, 0x60  ; even if you don't care, you need to clear the character

    mov si, text_string_b     ; Put string poisition into SI
    call print_string

    mov al, 0x20
    out 0x20, al                   ; Send EOI to Master PIC

    pop ax
    pop si
    iret

timer_isr:
    push si
    push ax
    push cx

    mov word cx, [counter]
    cmp cx, 0
    jne .timer_done
    mov cx, 10

    mov si, text_string_c     ; Put string poisition into SI
    call print_string

.timer_done:
    dec cx
    mov word [counter], cx

    mov al, 0x20
    out 0x20, al                   ; Send EOI to Master PIC

    pop cx
    pop ax
    pop si
    iret

print_string:
    push ax
    mov ah, 0Eh             ; int 10h 'print char' function ID
.repeat:
    lodsb
    cmp al, 0
    je .done
    int 10h
    jmp .repeat
.done:
    pop ax
    ret
    
    text_string_a db 'This is our bootloader ', 0
    text_string_b db 'This is our keyboard ', 0
    text_string_c db 'This is our timer ', 0
    counter db 0, 0, 0, 0
    
    ; pad bootloader
    times 510 - ($ - $$) db 0
    dw 0xAA55
