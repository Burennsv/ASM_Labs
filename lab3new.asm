.model small
.stack 100h
.data
        flag                    db      0
        bracket1                db      'array[', '$'
        bracket2                db      ']=', '$'
        Enter1                    db     0Dh, 0Ah, '$'
        arraySize               equ     16
        array                   dw      arraySize dup (0)
 
        numberBuffer            db      7, 0, 7 dup(0)


        result                  db      0dh, 0ah, "Array median: $"
        emptyArrayError         db      0dh, 0ah, "Error: array is empty.$"
        errorNumberMessage      db      "Error: incorrect number.", 0dh, 0ah, '$'
 
.code
;=========================================
_end macro
        mov ah, 4ch
        int 21h
endm    
;=========================================
_print      macro str  
        ;push ax
        lea dx, str
        mov ah, 09h
        int 21h
        ;pop ax 
endm 
;=========================================
_input      macro str
      lea dx, str
      mov ah, 0ah
      int 21h 
endm 
;=========================================
;_error macro errorMessage
;        _print errorMessage
;endm
;========================================= 
main    proc       
        mov     ax,     @data
        mov     ds,     ax      
        
        mov     cx,     arraySize
        lea     dx,     [array]
        call    InputArray
        call    HoarSort
        call    ShowArray
        _print Enter1  
        call _findMedian   
        
        mov     ax, 4ch
        int     21h
main    endp
;=========================================  
InputArray      proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di
 
        mov si, 0;      индекс элемента массива
        mov di, dx;     адрес текущего элемента массива
        mov cx, arraySize
        @@ForI:
                _print bracket1
                mov ax, si
                call    PrintAX
                _print bracket2
                _input numberBuffer;    ввод элемента массива
                _print Enter1
 
                push si
                lea si, numberBuffer+1
                call Str2Num
                pop si
 
                jnc @@NoError;          проверка на ошибку
                jmp @@ForI;             если есть ошибка ввода - повторить ввод
                @@NoError:
                ;                       сохранение введённого числа в массиве
                inc si;                 переход к следующему элементу
                add di, 2
        loop    @@ForI
@@Exit:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
InputArray      endp
;======================
_invert         macro 
        neg ax
        shr ax, 1
        neg ax 
        mov flag, 1
endm 
;======================
_findMedian     proc 
        mov si, 14
        mov ax, array[si]
        mov flag, 0 
        cmp ax, 0 
        jnle @@next1
        _invert
        @@next1:
        cmp flag, 1
        je @@justMov1
        shr ax, 1
        @@justMov1:
        mov flag, 0 
        mov bx, ax
        mov ax, array[si + 2]
        cmp ax, 0
        jnle @@next2
        _invert
        @@next2: 
        cmp flag, 1
        je @@justMov2
        shr ax, 1
        @@justMov2:
        add ax, bx
        push ax
        _print result
        pop ax
        call PrintAX 
        _end               
_findMedian     endp
;====================== 
ShowArray       proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di
 
        jcxz @@Exit1 ;если массив пустой - завершить
 
        mov si, 1  ;индекс элемента массива
        mov di, dx ;адрес текущего элемента массива
        @@ForI2:
                mov ax, [di]
                call PrintAX
                mov ah, 02h
                mov dl, ' '
                int 21h
                ;переход к следующему элементу
                inc si
                add di, 2
        loop    @@ForI2
@@Exit1:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
ShowArray       endp
 
; ax - число для отображения
PrintAX proc
        push ax
        push bx
        push cx
        push dx
        push di
 
        mov cx, 10
        xor di, di;     di - количество цифр в числе
 
        ; если число в ax отрицательное, то печакм минус и делаем число в ax положительным
        or ax, ax;      если < 0, то в SF заносится 1
        jns @@Conv;     проверяет SF
        push ax
        mov dx, '-'
        mov ah, 2;      функция вывода символа на экран
        int 21h
        pop ax
 
        neg ax
 
@@Conv:
        xor dx, dx
        div cx;         в dl идёт остаток от деления на 10
        add dl, '0';    перевод в символьный формат
        inc di
        push dx;        складываем в стек
        or ax, ax
        jnz @@Conv
        ; выводим из стека на экран
@@Show:
        pop dx;         dl = очередной выводимый символ
        mov ah, 2;      ah - функция вывода символа на экран
        int 21h
        dec di;         повторяем пока di != 0
        jnz @@Show
 
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
PrintAX endp

; si - действительная длина введённой строки с числом 
; di - адрес числа
; выходное число заносится в di
Str2Num proc
        push ax
        push bx
        push cx
        push dx
        push ds
        push es
        push si
 
        push ds
        pop es
 
        mov cl, ds:[si]
        xor ch, ch
 
        inc si
 
        cmp [si], byte ptr '-'
        jne @@IsPositive
        inc si
        dec cx
@@IsPositive:
        jcxz @@Error;   если после '-' ничего не идет либо если нет вообще ничего
 
        mov bx, 10
        xor ax, ax
 
@@Loop:
        mul bx;         умножаем ax на 10 (старшее слово заносится в dx)
        mov [di], ax;   игнорируем старшее слово
        cmp dx, 0;      проверяем результат на переполнение
        jnz @@Error
 
        mov al, [si];   преобразуем следующий символ в число
        cmp al, '0'
        jb @@Error
        cmp al, '9'
        ja @@Error
        sub al, '0'
        xor ah, ah
        add ax, [di]
        jc @@Error;     если сумма больше 65535
        inc si
        loop @@Loop
 
        pop si
        push si
        or ax, ax
        js @@Error;     проверяем SF (если есть знак)
        cmp [si+1], byte ptr '-'
        jne @@Positive
        neg ax
        or ax, ax
        jns  @@Error
@@Positive:
        mov  [di], ax
        clc;            очистка флага переноса         
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax
        ret
@@Error:
        _print errorNumberMessage
        xor ax, ax
        mov [di], ax
        stc
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax
        ret
Str2Num endp
 
;cx - количество элементов в массиве
;dx - адрес массива слов
HoarSort       proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        mov bx, dx
        mov si, 0
        mov di, cx
        dec di
        shl di, 1
        call _HoarSort
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
HoarSort       endp
;  si - адрес левой границы массива
;  di - адрес правой границы массива
; (возможная проблема с декрементом di)
_HoarSort   proc                   
        push ax             
        push bx
        push cx
        push dx
        push si
        push di
        
        cmp si, di   
        jae @@StopHoarSort;     если >= 
        push di
        push si
        ;                       int middle = (left + right) / 2 - делим на 2, т.к. в слове 2 байта;
        mov dx, di    
        mov cx, si
        shr si, 1
        shr di, 1
        sub di, si;             находим порядковый номер последнего элемента массива (длина выделенной части массива)
        shr di, 1;              делим ещё раз, чтобы найти конкретную середину выделенной части массива
        add si, di;             добираемся до порядкового номра среднего элемента выделенной части 
        shl si, 1 ; * 2
        mov ax, [bx+si];        сохраняем реального смещение среднего элемента выделенной части
        mov si, cx;             левая граница
        mov di, dx;             правая граница
        @@DoWhile:     
                sub si, 2;      отнимаем, чтобы избежать лишнего добавления
                @@WhileLeft:;   ищем первый элемент, который будет больше среднего
                        add si, 2;добавляем смещение
                        mov cx, [bx+si]; 
                        cmp ax, cx 
                        jg @@WhileLeft; продолжаем цикл, пока ax > cx
            
                add di, 2 
                @@WhileRight:;  ищем первый элемент, который будет меньше среднего
                        sub di, 2
                        mov cx, [bx+di]
                        cmp ax, [bx+di]
                        jl @@WhileRight; продолжаем цикл пока ax < cx
                                   
                cmp si, di;     если не нашли нужных элементов, значит этот участок отсортирован
                ja  @@BreakDoWhile
                            
                mov cx, [bx+si];меняем местами найденные элементы
                mov dx, [bx+di]
                mov [bx+si], dx
                mov [bx+di], cx  
                  
                add  si, 2
                cmp  di, 0
                je   Mark1                 
                sub  di, 2   
                               
                Mark1:    
                cmp  si, di
                jbe  @@DoWhile; если границы перемахнут друг за друга, то прекращаем сортировку (если ниже или равно)
        @@BreakDoWhile:                     
        mov cx, si
        pop si
        call  _HoarSort                          
        mov si, cx
        pop di
        call  _HoarSort
                                
@@StopHoarSort:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
_HoarSort   endp                    
end     main