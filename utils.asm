
global assert_not_null

global exit
global get_time
global print

global sleep_ms



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file contains various utilities.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print a string to STDOUT.
;
; @param rdi
;   Address of null terminated string to print.
;
; @returns
;   Number of bytes output.
;
print:
    push rbp
    mov rbp, rsp

    mov r10, rdi ; save off string address
    mov r9, rdi ; iterator register for string
    movzx rax, byte [r9] ; load first byte
    mov rcx, 0x0 ; accumulator for string length

count_null_start:
    cmp rax, 0x0 ; are we at the null byte?
    je count_null_end

    inc rcx ; increment accumulator
    inc r9 ; move to next byte
    movzx rax, byte [r9] ; load byte
    jmp count_null_start 

count_null_end:
    ; syscall to write string to stdout
    mov rax, 0x1
    mov rdi, 0x1;
    mov rsi, r10
    mov rdx, rcx
    syscall

    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Assert the input is not null.
;
; @param rdi
;   Value to check is not null.
;
; @param rsi
;   Pointer to error message string.
;
assert_not_null:
    push rbp
    mov rbp, rsp

    cmp rdi, 0x0
    jne assert_not_null_end

    mov rdi, rsi
    call print

    mov rdi, 0x1
    call exit

assert_not_null_end:

    pop rbp
    ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Exit the program.
;
; @param rdi
;   Exit code.
;
exit:
    mov rax, 60
    syscall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sleep the current process for the supplied number of milliseconds.
;
; @param rdi
;   Number of milliseconds to sleep for.
;
sleep_ms:
    push rbp
    mov rbp, rsp

    imul rdi, rdi, 1000000 ; convert supplied ms to ns
    xor rax, rax 
    ; recreate struct timepec on the stack
    push rdi ; tv_nsec
    push rax ; tv_sec

    ; nanosleep syscall
    mov rax, 0x23
    mov rdi, rsp
    mov rsi, 0x0
    syscall

    add rsp, 16

    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get the time since epoch in milliseconds.
;
; @returns
;   Milliseconds since epoch.
;
get_time:
    push rbp
    mov rbp, rsp

    ; create empty timeval struct on the stack
    push 0x0 ; tv_usec
    push 0x0 ; tv_sec

    ; gettimeofday syscall
    mov rax, 0x60
    mov rdi, rsp
    mov rsi, 0x0
    syscall

    pop rax ; seconds
    pop rbx ; microseconds

    imul rax, rax, 1000000 ; convert seconds to microseconds
    add rax, rbx ; add microseconds
    mov rdx, 0x0
    mov rbx, 1000
    div rbx ; convert to milliseconds

    ; result storerd in rax to be returned as time in milliseconds

    pop rbp
    ret
