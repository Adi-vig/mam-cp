global linked_list_init
global linked_list_iterator
global linked_list_iterator_advance
global linked_list_iterator_remove
global linked_list_iterator_value
global linked_list_push_back

extern memory_malloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a new linked list.
;
; @returns
;   A handle to the linked list which can be passed to further linked list methods.
;


; entity is a structure
; x
; y
; width 
; height



linked_list_init:
    push rbp
    mov rbp, rsp

    mov rdi, 0x0        ;head node will have value rdi = 0 
    call allocate_node ; create the head node

    ; we return the head node as the handle

    pop rbp
    ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Insert a new value to the back of the linked list.
;
; @param rdi
;   Handle to linked list to insert into.
;
; @param rsi
;   Value to insert.
;
; @returns
;   Address if newly created node.
;
linked_list_push_back:
    push rbp
    mov rbp, rsp

    mov rbx, rdi
    ; ADRESS OF x of entity/struct = [rbx]



    ; find end of list
    linked_list_push_back_find_end:
        mov rcx, [rbx + 0x8]     ; get next pointer
        cmp rcx, 0x0 ; if null then we are at the last node
        je linked_list_push_back_do_insert

        add rbx, 16           
        jmp linked_list_push_back_find_end

    linked_list_push_back_do_insert:
        push rbx
            mov rdi, rsi
            call allocate_node  ; allocate new node
        pop rbx

        mov [rbx + 0x8], rax    ; set new node as next of last node
        mov rax, [rbx + 0x8]    ; set return value as address of new node

    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get an iterator to the start of the linked list. This is a handle that can ba passed to other iterator functions.
;
; @rdi
;   Handle to list to get iterator for.
;
; @returns
;   Iterator handle.
;
linked_list_iterator:
    push rbp
    mov rbp, rsp

    call linked_list_iterator_advance ; we can cheat here by just returning the address of the first node after the head

    pop rbp
    ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Remove a node from the linked list. 
;
; @param rdi
;   Handle to linked list to remove node from.
;
; @parma rsi
;   Iterator to remove
; 

linked_list_iterator_remove:
    push rbp
    mov rbp, rsp

    ; rdi has head node
    ; rsi has node to be removed


    linked_list_remove_find_begin:
        mov rax, [rdi + 8]
        cmp rax, 0x0            ; end of list
        je linked_list_remove_end

        cmp rax, rsi
        je linked_list_remove_find_end  ;next node is node to be deleted ---- found 

        mov rdi, rax
        jmp linked_list_remove_find_begin

    linked_list_remove_find_end:

        mov rbx, [rsi + 8] ; get next of node we are removing
        mov [rdi + 8], rbx ; set prev nodes next to next of removing node

    linked_list_remove_end: 
    
    pop rbp
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Advance an iterator.
;
; @param rdi
;   Handle to iterator to advance.
;
; @returns
;   Handle to advanced iterator.
;
linked_list_iterator_advance:
    push rbp
    mov rbp, rsp

    mov rax, [rdi + 0x8]

    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get the value from an iterator.
;
; @param rdi
;   Handle to iterator to get value for.
;
; @returns
;   Value stored in node iterator is referencing.
;
linked_list_iterator_value:
    push rbp
    mov rbp, rsp

    mov rax, [rdi]

    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate a new node and store a value in it.
;
; @param rdi
;   Value to store in node
;
; @returns
;   Address of allocated node.
;
allocate_node:
    push rbp
    mov rbp, rsp

    push rdi                ;value to be stored in node

    mov rdi, 16   
    call memory_malloc      ;allocate space for node

                            ;memory_malloc(rdi) 
                            ;returns pointer to allocated memory in heap section (dynamic allocation)
                            ;rax will hold the allocated memory address 


    pop rdi                 ; restore rdi the value to be stored in node


    mov rbx, 0x0
    mov [rax], rdi          ; store value in node
    mov [rax + 0x8], rbx    ; set next to be null

    pop rbp
    ret

