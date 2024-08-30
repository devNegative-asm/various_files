sys_exit: equ 60
sys_fork: equ 57
sys_waitid: equ 247
WEXITED: equ 4
P_PID: equ 1
extern _start


section .data

forkResults:
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0
dd 0

siginfo: ; probably overkill in terms of space, but whatever
dq 0
dq 0
dq 0
dq 0
dq 0
dq 0
dq 0
dq 0

section .text


join: ;join with pid = forkResults[r14], r15 = max(exitCode, r15)

    mov esi, [forkResults + r14 * 4]
    cmp esi, 0
    jne .cont
    inc r14
    ret

.cont:
    mov eax, sys_waitid
    mov edi, P_PID
    lea rdx, [siginfo]
    mov r8, 0
    mov r10, WEXITED
    syscall
    mov esi, [siginfo + 8]; assume __ARCH_HAS_SWAPPED_SIGINFO is false
    cmp r15, rsi
    cmovl r15, rsi
    inc r14
    ret

fork:
    mov eax, sys_fork
    syscall
    mov [forkResults + rdi * 4], eax
    inc edi
    ret

_start:

    mov rdi, 0

    call fork
    call fork
    call fork
    call fork
    call fork
    call fork
    call fork
    call fork
    call fork

    mov r11, 3_906_250 / 2; loop counter. split up 1bn among 512 threads
    mov edi, 0 ; maximum value

.loop:
    ;generate 256 random bits, & with 256 more random bits, & out 25 bits to get to 231, then popcnt

    rdrand rax
    rdrand rbx
    rdrand rcx
    rdrand rdx

    rdrand r10
    rdrand rsi
    rdrand r8
    rdrand r9

    and r10, rax
    and rbx, rsi
    and rcx, r8
    and rdx, r9
    shl rbx, 25 ; remove 25 bits

    popcnt rcx, rcx
    popcnt r10, r10
    popcnt rdx, rdx
    popcnt rbx, rbx

    add r10, rdx
    add rcx, rbx
    add r10, rcx

    cmp r10, rdi
    cmovg rdi, r10

    dec r11
    jnz .loop

    ;if we are a parent process, wait for children to exit. collect their exit codes, then MAX() the results

    mov r14, 0
    mov r15, rdi
    call join
    call join
    call join
    call join
    call join
    call join
    call join
    call join
    call join
    mov rdi, r15

    mov rax, sys_exit
    syscall
