global start

MAGIC_NUMBER equ 0x1BADB002
FLAGS        equ 0x0
CHECKSUM     equ -MAGIC_NUMBER

section .text:
align 4
    dd MAGIC_NUMBER
    dd FLAGS
    dd CHECKSUM

start:
    mov ebx, 0xb8000
    mov ecx, 80 * 25

    ; clear screen
    mov edx, 0x0020  ; space character
clear_loop:
    mov [ebx + ecx], edx
    dec ecx
    cmp ecx, -1
    jnz clear_loop

    mov eax, (4 << 8 | 0x41)
    mov [ebx], eax

.loop:
    jmp .loop