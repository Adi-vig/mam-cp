
global memory_malloc


extern assert_not_null


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simple implementation of malloc.
;
; array of size 4096000 bytes 
;
; @param rdi
;   Number of bytes to allocate.
;
; @returns
;   Address of allocated memory.
;
memory_malloc:
    push rbp
    mov rbp, rsp

    ;rdi = number of bytes to allocate

  
    lea rax, malloc_memory  ;return rax
    mov rbx, [index]
    add rax, rbx

    add rbx,rdi
    mov [index], rbx
    pop rbp
    ret

section .data
    malloc_init: dq 0x0
    ; malloc_memory: dq 0x0
    ; malloc_memory: resb 4096000

    malloc_memory TIMES 4096000 db 0
    index : dq 0x0

    mmap_failed: db "mmap failed", 0xa, 0x0


