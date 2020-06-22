.model small
.stack 100h  
.data 
buffer db ?
file_name db 50 dup("$")   
error_open_file db "open file error",0Ah,0Dh,"$"  
error_read_file db "read file error",0Ah,0Dh,"$"
program_start_message db "start...",0Ah,0Dh,"$"    
string_length dw 0h                     
not_empty_strings dw 0h    
buffercur db ? 
empty_strings_mes db " non empty string(s) in file",0Ah,0Dh,"$"
empty_cmd_mes db "command line is an empty",0Ah,0Dh,"$"

.code          
convert proc
    pusha   
    push 24h
    mov bx,0Ah      

convert_loop:
    xor dx,dx              
    div bx 
    push dx
    xor dx,dx
    cmp ax,0h
    je _end 
    jmp convert_loop   
         
_end:
    mov ah,2h                     
        
number_write:
    pop dx
    cmp dx,24h   
    je _end_
    add dx,30h 
    int 21h             
    jmp number_write   
        
_end_:            
    popa
    ret  
convert endp 
    
start:  
    mov ax,@data
    mov ds,ax   
    lea dx,program_start_message
    mov ah,9h
    int 21h        
    mov di,80h      ;
    mov cl,es:[di]   ;
    cmp cl,1h        ; проверка на наличие командной строки
    jle empty_cmd     ;          
    mov cx,-1h          
    mov di,81h         ; становимся на начало командной строки
    mov al,' '
    repe scasb            ; пропускаем все пробелы(если они есть) и становимся на первый символ командной строки
    dec di         
    mov bx,0h   
    
get_file_name:
    cmp es:[di],0Dh   ; если прочитали до конца командную строку,то переходим
    je set_string_end
    mov al,es:[di]           ;
    mov file_name[bx],al    ;  получаем имя файла по символу,наращиваем индексы
    inc bx                  ;   считываем по символу название файла (ходим по циклу)
    inc di                   ;
    jmp get_file_name
    
set_string_end:
    mov file_name[bx],0h   ;добавляем 0 в конце названия файла(так принято,читай методу)
    mov ah,3Dh
    mov al,0h              ;
    lea dx,file_name        ; открываем существующий файл
    int 21h                 ;
    jc print_open_file_error ;ошибка открытия файла  
    mov bx,ax       

read_file:
    push ax           ;
    xor ax,ax         ;
    mov al,buffer     ;  запоминаем предыдущий символ
    mov buffercur,al  ;
    pop ax            ;
    mov cx,1h
    lea dx,buffer      ;считываем по одному байту из файла и заносим в буфер 
    mov ah,3Fh
    int 21h
    jc print_read_file_error  ;ошибка чтения файла   
                             
    cmp buffer,0Ah       ;если это ньюлайн,то переходим и проверяем,если предыдущий символ тоже ньюлайн,то это строка
    je cont              ;
    cmp buffer,0Dh         ;если коретка,то проверяем длину строки,нулевая она или нет
    jne increase_string_length  ; если нет,то просто наращиваем длину строки
    je check_empty         ;
    
increase_string_length:   ;переходит сюда если это обычный символ
    cmp ax,0h            ;если конец файла,то переходим сразу на закрытие файла
    je continue
    inc string_length
    jmp continue

check_empty:
    cmp string_length,0h     ;проверяем пустая строка или нет
    je empty 
    mov string_length,0h
    inc not_empty_strings
    jmp continue 
    
empty: 
    mov string_length,0h   ;обнуляем длину строки
    jmp continue
    cont:
    cmp buffercur, 0Ah   ;проверка на два ньюлайна подряд
    je check_empty
continue:
     cmp ax,0h
    jne read_file       ;если конец файла,то закрываем файл,иначе переходим к дальнейшему чтению
    mov ah,3Eh
    int 21h
    cmp string_length,0h   ;проверка на последнюю строку
    je print 
    inc not_empty_strings
    print:
    jmp print_not_empty_strings_message
    
print_open_file_error:
    lea dx,error_open_file
    mov ah,9h
    int 21h
    jmp exit   
    
print_read_file_error:
    lea dx,error_read_file
    mov ah,9h
    int 21h 
    mov ah,3Eh
    int 21h
    jmp exit   

empty_cmd: 
    lea dx,empty_cmd_mes
    mov ah,9h
    int 21h 
    jmp exit

print_not_empty_strings_message:   
    mov ax,not_empty_strings
    call convert 
    lea dx,empty_strings_mes
    mov ah,9h
    int 21h  

exit:    
    mov ax,4C00h
    int 21h    
    end start