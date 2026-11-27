/* x86_64 Windows ABI setjmp/longjmp for the freestanding UEFI build.
 *
 * The layout is mingw-w64's jmp_buf (_JUMP_BUFFER in <setjmp.h>):
 * Frame, Rbx, Rsp, Rbp, Rsi, Rdi, R12-R15, Rip, MxCsr, FpCsr, Spare,
 * then Xmm6-Xmm15.  The function must preserve the Windows ABI's
 * non-volatile integer and SSE registers; this is the same state a real
 * msvcrt/ucrt longjmp restores.
 */

.intel_syntax noprefix
.text

.p2align 4
.globl _setjmp
_setjmp:
    mov     [rcx + 0x00], rdx
    mov     [rcx + 0x08], rbx
    lea     rax, [rsp + 8]
    mov     [rcx + 0x10], rax
    mov     [rcx + 0x18], rbp
    mov     [rcx + 0x20], rsi
    mov     [rcx + 0x28], rdi
    mov     [rcx + 0x30], r12
    mov     [rcx + 0x38], r13
    mov     [rcx + 0x40], r14
    mov     [rcx + 0x48], r15
    mov     rax, [rsp]
    mov     [rcx + 0x50], rax
    stmxcsr [rcx + 0x58]
    fnstcw  [rcx + 0x5c]
    mov     word ptr [rcx + 0x5e], 0
    movdqu  [rcx + 0x60], xmm6
    movdqu  [rcx + 0x70], xmm7
    movdqu  [rcx + 0x80], xmm8
    movdqu  [rcx + 0x90], xmm9
    movdqu  [rcx + 0xa0], xmm10
    movdqu  [rcx + 0xb0], xmm11
    movdqu  [rcx + 0xc0], xmm12
    movdqu  [rcx + 0xd0], xmm13
    movdqu  [rcx + 0xe0], xmm14
    movdqu  [rcx + 0xf0], xmm15
    xor     eax, eax
    ret

.p2align 4
.globl longjmp
longjmp:
    mov     eax, edx
    test    eax, eax
    jne     .Lnonzero
    mov     eax, 1
.Lnonzero:
    ldmxcsr [rcx + 0x58]
    fldcw   [rcx + 0x5c]
    movdqu  xmm6,  [rcx + 0x60]
    movdqu  xmm7,  [rcx + 0x70]
    movdqu  xmm8,  [rcx + 0x80]
    movdqu  xmm9,  [rcx + 0x90]
    movdqu  xmm10, [rcx + 0xa0]
    movdqu  xmm11, [rcx + 0xb0]
    movdqu  xmm12, [rcx + 0xc0]
    movdqu  xmm13, [rcx + 0xd0]
    movdqu  xmm14, [rcx + 0xe0]
    movdqu  xmm15, [rcx + 0xf0]
    mov     rbx, [rcx + 0x08]
    mov     rbp, [rcx + 0x18]
    mov     rsi, [rcx + 0x20]
    mov     rdi, [rcx + 0x28]
    mov     r12, [rcx + 0x30]
    mov     r13, [rcx + 0x38]
    mov     r14, [rcx + 0x40]
    mov     r15, [rcx + 0x48]
    mov     rsp, [rcx + 0x10]
    jmp     qword ptr [rcx + 0x50]
