global create_window
global try_get_event

extern XBlackPixel
extern XCheckWindowEvent
extern XClearWindow
extern XCreateGC
extern XCreateSimpleWindow
extern XDefaultRootWindow
extern XDefaultScreen
extern XFillRectangle
extern XFlush
extern XLookupKeysym
extern XMapWindow
extern XNextEvent
extern XSync
extern XOpenDisplay
extern XSelectInput
extern XSetForeground
extern XWhitePixel


; from utils asm
extern assert_not_null
; extern assert_null
extern render_begin_clear_window
extern draw_rectangle
extern render_end
extern print
; extern print_num



; Create and display an X Window.
;
create_window:
    push rbp
    mov rbp, rsp

    ; X11 window setup 

    mov rdi, 0x0
    call XOpenDisplay       ; Create a Display* ........ display pointer
                            ; create a display pointer and return to rax 
    mov [display], rax       ; move the newly created Display* ptr to display variale
    mov rdi, rax                
    lea rsi, [x_open_display_failed]
    call assert_not_null

    call XDefaultScreen
    mov [screen_number], rax        ; get the screen number

    ; return the default screen number referenced by the XOpenDisplay function. This macro or function should be used to retrieve the screen number in applications that will use only a single  screen

    mov rdi, [display]  
    mov rsi, [screen_number]    
    call XWhitePixel                ;  return the white pixel value for the specified screen.
    mov [white_colour], rax

    mov rdi, [display]
    mov rsi, [screen_number]
    call XBlackPixel        ; return the value of black pixel
    mov [black_colour], rax

    mov rdi, [display]
    call XDefaultRootWindow     
    mov [default_root_window], rax      ; get the default root/parent window

    mov rdi, [display]
    mov rsi, [default_root_window]
    mov rdx, 0x0
    mov rcx, 0x0
    mov r8, 0x320
    mov r9, 0x320
    mov rax, [black_colour]

    push 0x30
    ; push rax
    push rax
    push 0x0
    call XCreateSimpleWindow


;     Window XCreateSimpleWindow(display, parent, x, y, width, height, border_width,
;                               border, background)
        ; Display *display;
        ; Window parent;
        ; int x, y;
        ; unsigned int width, height;
        ; unsigned int border_width;
        ; unsigned long border;
        ; unsigned long background;
        ; display Specifies the connection to the X server.
        ; parent Specifies the parent window.
        ; 
        
        ; x
        ; y Specify the x and y coordinates, which are the top-left outside corner of the new
        ; window’s borders and are relative to the inside of the parent window’s borders.
        
        
        ; width
        ; height Specify the width and height, which are the created window’s inside dimensions
        ; and do not include the created window’s borders. The dimensions must be
        ; nonzero, or a BadValue error results.
        
        ; border_width Specifies the width of the created window’s border in pixels.
        
        ; border Specifies the border pixel value of the window.
        
        ; background Specifies the background pixel value of the window.








    mov [window], rax           ;returns the window ID of the created window
    add rsp, 0x18

    mov rdi, [display]
    mov rsi, [window]
    mov rdx, 0x20003
    call XSelectInput

    mov rdi, [display]
    mov rsi, [window]
    call XMapWindow

    mov rdi, [display]
    mov rsi, [window]
    mov rdx, 0x0
    mov rcx, 0x0
    call XCreateGC
    mov [gc], rax


    ; wait until window has appeared
wait_loop_start:
    mov rdi, [display]
    lea rsi, [event]
    call XNextEvent

    mov eax, [event]
    cmp rax, 0x13
    je wait_loop_end

    jmp wait_loop_start
wait_loop_end:
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Try and get an event
;
; @returns
;   Address of an event, or 0x0 if no event was available.
;
try_get_event:
    push rbp
    mov rbp, rsp

    ; see if we want have events
    mov rdi, [display]
    mov rsi, [window]
    mov rdx, 0x03
    lea rcx, [event]
    call XCheckWindowEvent

    cmp rax, 0x0
    je try_get_event_end

    ; we got an event so return pointer to event object
    lea rax, [event]

try_get_event_end:
    pop rbp
    ret

; Perform pre-render tasks
render_begin_clear_window:
    push rbp
    mov rbp, rsp

    ; clear window
    mov rdi, [display]
    mov rsi, [window]
    call XClearWindow

    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw a rectangle.
;
; @param rdi
;   X coord of rectangle
;
; @param rsi
;   Y coord of rectangle
;
; @param rdx
;   Width of rectangle
;
; @param rcx
;   Height of rectangle
;
draw_rectangle:
    push rbp
    mov rbp, rsp

    ; push args to stack so we can easily pop them into the correct registers
    push rcx
    push rdx
    push rsi
    push rdi

    ; set foreground color for drawing
    mov rdi, [display]
    mov rsi, [gc]
    mov rdx, [white_colour]
    call XSetForeground

    ; draw rectangle 
    mov rdi, [display]
    mov rsi, [window]
    mov rdx, [gc]
    pop rcx
    pop r8
    pop r9 ; note that the last arg is now at at the top of the stack height which was pusshed first (push rcx)
    call XFillRectangle
    add rsp, 0x8

    pop rbp
    ret

; XFillRectangle (display, d, gc, x, y, width, height)
; Display *display;
; Drawable d;
; GC gc;
; int x, y;
; unsigned int width, height;
; display Specifies the connection to the X server.
; d Specifies the drawable.
; gc Specifies the GC.
; x
; y Specify the x and y coordinates, which are relative to the origin of the drawable
; and specify the upper-left corner of the rectangle.
; width
; height Specify the width and height, which are the dimensions of the rectangle to be
; filled.






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform post-render tasks
;
render_end:
    push rbp
    mov rbp, rsp

    ; ensure all draw commands are flushed
    mov rdi, [display]
    call XFlush

    pop rbp
    ret

section .data
    display: dq 0x0
    screen_number: dq 0x0
    black_colour: dq 0x0
    white_colour: dq 0x0
    default_root_window: dq 0x0
    window: dq 0x0
    gc: dq 0x0
    event: resb 0xc0

section .rodata
    hello_world: db "hello world", 0xa, 0x0
    goodbye: db "goodbye", 0xa, 0x0
    sleep_for: db "sleep_for: ", 0x0
    x_open_display_failed: db "XOpenDisplay failed", 0xa, 0x0
    x_select_input_failed: db "XSelectInput failed", 0xa, 0x0
    x_set_foreground_failed: db "XSetForeground failed", 0xa, 0x0
