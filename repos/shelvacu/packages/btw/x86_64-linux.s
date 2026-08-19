    .intel_syntax noprefix

    .section .rodata
msg:
    .ascii "I use NixOS btw\n"
    .equ msglen, . - msg

    .section .text
    .globl _start
_start:
    mov eax, 1                  /* __NR_write */
    mov edi, 1                  /* fd = stdout */
    lea rsi, [rip + msg]
    mov edx, msglen
    syscall

    mov eax, 60                 /* __NR_exit */
    xor edi, edi                /* status = 0 */
    syscall
