    .section .rodata
msg:
    .ascii "I use NixOS btw\n"
    .equ msglen, . - msg

    .section .text
    .globl _start
_start:
    mov  x8, #64            // __NR_write
    mov  x0, #1             // fd = stdout
    adr  x1, msg            // buf
    mov  x2, #msglen        // count
    svc  #0

    mov  x8, #93            // __NR_exit
    mov  x0, #0             // status = 0
    svc  #0
