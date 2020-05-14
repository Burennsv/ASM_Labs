;15 Вставить в строке слово «number» перед словами, состоящими только из цифр.

.model small
.stack 100h
.data
    start_msg db "Enter a string",10,13,'$'
    word_number db " <number> "
    string  db 201
            db ?
            db 201 dup(?)
.code
 get_length proc 
    pop ax
    pop bx
    sub ax, bx
    push ax
    ret
 get_length endp
 
 left_shift_with_insert macro count, str, word 
        pop dx
        push di
        push si
        mov si, dx
        xor ax, ax
        mov al, byte ptr [str + 1]
        mov di, offset str + 2
        add di, ax
        inc di 
        shift_loop:
            dec di
            mov al, byte ptr ds:[di] ; direct
            mov byte ptr ds:[di+8], al ;direct
            cmp di, si
            je  _insert_word
            jmp shift_loop
        _insert_word:
            mov di, offset word
            xor cx, cx
            mov cx, 8
            _insert_word_loop:
                mov al, [di]
                mov [si], al
                inc di
                inc si
            loop _insert_word_loop
            jmp _exit_shift
         _exit_shift:
            pop si
            pop di          
  endm
            
            
_start:
    mov ax, @data
    mov ds, ax
    
_start_msg:
    mov dx, offset start_msg
    mov ah, 0x9
    int 0x21
    mov dx, offset string
    mov ah, 0x0A
    int 21h
   
_check_string_length:
   xor ah, ah
   xor si, si
   mov si, offset string + 1
   mov al, byte ptr[si]
   cmp al, 200
   jae _exit_without_output
   cmp al, 0
   je _exit_without_output
   jmp _replace_enter
    
_replace_enter:
    xor si, si
    mov si, offset string + 1
    xor ch, ch
    mov cl, [si]
    inc cx
    add si,cx
    mov al, '$'
    mov [si], al
    
_prepare_for_searching_words:
    mov di, offset string + 2
    xor ax, ax
    mov al, 32
    xor cx, cx
    mov cl, byte ptr[string + 1]
    inc cx
    jmp _find_word

_inc_dest_index:
    mov di, si
    inc di
    xor ax, ax
    mov ah, '$'
    mov al, [di]
    inc di
    pop cx
    cmp ah, al
    je _exit
    jmp _find_word    

_find_word:
    push di
    jmp _start_searching_word

_start_searching_word:
    mov ah, [di]
    inc di
    cmp al, ah
    je _check_is_number
    loop _start_searching_word
    jmp _check_is_number
        
       
_check_is_number_last:
    dec di
    mov si, di
    pop di
    push cx
    xor dx, dx
    mov dx, di
    dec di
    xor ax, ax
    cmp di, si
    je _inc_dest_index
    jmp _start_cheking_last
    
_start_cheking_last:
    cmp di, si
    je _out_founded_word
    inc di
    mov ah, "0"
    mov al, [di]
    cmp al, ah
    jl _exit
    mov ah, "9"
    cmp al, ah
    jg _exit
    jmp _start_cheking_last
       
_check_is_number:
    dec cx
    sub di, 2
    mov si, di
    pop di
    push cx
    xor dx, dx
    mov dx, di
    dec di
    xor ax, ax
    cmp di, si
    je _inc_dest_index
    jmp _start_cheking

_start_cheking:
    cmp di, si
    je _insert_word_number
    inc di
    mov ah, "0"
    mov al, [di]
    cmp al, ah
    jl _inc_dest_index
    mov ah, "9"
    cmp al, ah
    jg _inc_dest_index
    jmp _start_cheking
    
_insert_word_number:
    push dx
    left_shift_with_insert 8, string, word_number
    add di, 8
    add si, 8
    xor ax, ax
    mov al, byte ptr[string+1]
    add al, 8
    mov byte ptr[string+1], al
    jmp _inc_dest_index    
    
    
    
_out_founded_word:
    mov di, dx
    dec di
    xor dx, dx
    jmp _print_word
_print_word:
    inc di
    mov dl, [di]
    mov ah, 0x2
    int 0x21
    cmp si, di
    jne _print_word
    je _inc_dest_index
    
_exit_without_output:
    mov ah, 0x4c
    int 0x21
    
_exit:
    mov dl, 10;
    mov ah, 0x02;
    int 0x21
    mov dl, 13;
    mov ah, 0x02;
    int 0x21
    mov dx, offset string + 2
    mov ah, 0x09
    int 0x21
    mov ah, 0x4c
    int 0x21    
end _start