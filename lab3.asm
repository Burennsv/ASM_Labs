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
 
        mov si, 0;      èíäåêñ ýëåìåíòà ìàññèâà
        mov di, dx;     àäðåñ òåêóùåãî ýëåìåíòà ìàññèâà
        mov cx, arraySize
        @@ForI:
                _print bracket1
                mov ax, si
                call    PrintAX
                _print bracket2
                _input numberBuffer;    ââîä ýëåìåíòà ìàññèâà
                _print Enter1
 
                push si
                lea si, numberBuffer+1
                call Str2Num
                pop si
 
                jnc @@NoError;          ïðîâåðêà íà îøèáêó
                jmp @@ForI;             åñëè åñòü îøèáêà ââîäà - ïîâòîðèòü ââîä
                @@NoError:
                ;                       ñîõðàíåíèå ââåä¸ííîãî ÷èñëà â ìàññèâå
                inc si;                 ïåðåõîä ê ñëåäóþùåìó ýëåìåíòó
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
 
        jcxz @@Exit1 ;åñëè ìàññèâ ïóñòîé - çàâåðøèòü
 
        mov si, 1  ;èíäåêñ ýëåìåíòà ìàññèâà
        mov di, dx ;àäðåñ òåêóùåãî ýëåìåíòà ìàññèâà
        @@ForI2:
                mov ax, [di]
                call PrintAX
                mov ah, 02h
                mov dl, ' '
                int 21h
                ;ïåðåõîä ê ñëåäóþùåìó ýëåìåíòó
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
 
; ax - ÷èñëî äëÿ îòîáðàæåíèÿ
PrintAX proc
        push ax
        push bx
        push cx
        push dx
        push di
 
        mov cx, 10
        xor di, di;     di - êîëè÷åñòâî öèôð â ÷èñëå
 
        ; åñëè ÷èñëî â ax îòðèöàòåëüíîå, òî ïå÷àêì ìèíóñ è äåëàåì ÷èñëî â ax ïîëîæèòåëüíûì
        or ax, ax;      åñëè < 0, òî â SF çàíîñèòñÿ 1
        jns @@Conv;     ïðîâåðÿåò SF
        push ax
        mov dx, '-'
        mov ah, 2;      ôóíêöèÿ âûâîäà ñèìâîëà íà ýêðàí
        int 21h
        pop ax
 
        neg ax
 
@@Conv:
        xor dx, dx
        div cx;         â dl èä¸ò îñòàòîê îò äåëåíèÿ íà 10
        add dl, '0';    ïåðåâîä â ñèìâîëüíûé ôîðìàò
        inc di
        push dx;        ñêëàäûâàåì â ñòåê
        or ax, ax
        jnz @@Conv
        ; âûâîäèì èç ñòåêà íà ýêðàí
@@Show:
        pop dx;         dl = î÷åðåäíîé âûâîäèìûé ñèìâîë
        mov ah, 2;      ah - ôóíêöèÿ âûâîäà ñèìâîëà íà ýêðàí
        int 21h
        dec di;         ïîâòîðÿåì ïîêà di != 0
        jnz @@Show
 
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
PrintAX endp

; si - äåéñòâèòåëüíàÿ äëèíà ââåä¸ííîé ñòðîêè ñ ÷èñëîì 
; di - àäðåñ ÷èñëà
; âûõîäíîå ÷èñëî çàíîñèòñÿ â di
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
        jcxz @@Error;   åñëè ïîñëå '-' íè÷åãî íå èäåò ëèáî åñëè íåò âîîáùå íè÷åãî
 
        mov bx, 10
        xor ax, ax
 
@@Loop:
        mul bx;         óìíîæàåì ax íà 10 (ñòàðøåå ñëîâî çàíîñèòñÿ â dx)
        mov [di], ax;   èãíîðèðóåì ñòàðøåå ñëîâî
        cmp dx, 0;      ïðîâåðÿåì ðåçóëüòàò íà ïåðåïîëíåíèå
        jnz @@Error
 
        mov al, [si];   ïðåîáðàçóåì ñëåäóþùèé ñèìâîë â ÷èñëî
        cmp al, '0'
        jb @@Error
        cmp al, '9'
        ja @@Error
        sub al, '0'
        xor ah, ah
        add ax, [di]
        jc @@Error;     åñëè ñóììà áîëüøå 65535
        inc si
        loop @@Loop
 
        pop si
        push si
        or ax, ax
        js @@Error;     ïðîâåðÿåì SF (åñëè åñòü çíàê)
        cmp [si+1], byte ptr '-'
        jne @@Positive
        neg ax
        or ax, ax
        jns  @@Error
@@Positive:
        mov  [di], ax
        clc;            î÷èñòêà ôëàãà ïåðåíîñà         
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
 
;cx - êîëè÷åñòâî ýëåìåíòîâ â ìàññèâå
;dx - àäðåñ ìàññèâà ñëîâ
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
;  si - àäðåñ ëåâîé ãðàíèöû ìàññèâà
;  di - àäðåñ ïðàâîé ãðàíèöû ìàññèâà
; (âîçìîæíàÿ ïðîáëåìà ñ äåêðåìåíòîì di)
_HoarSort   proc                   
        push ax             
        push bx
        push cx
        push dx
        push si
        push di
        
        cmp si, di   
        jae @@StopHoarSort;     åñëè >= 
        push di
        push si
        ;                       int middle = (left + right) / 2 - äåëèì íà 2, ò.ê. â ñëîâå 2 áàéòà;
        mov dx, di    
        mov cx, si
        shr si, 1
        shr di, 1
        sub di, si;             íàõîäèì ïîðÿäêîâûé íîìåð ïîñëåäíåãî ýëåìåíòà ìàññèâà (äëèíà âûäåëåííîé ÷àñòè ìàññèâà)
        shr di, 1;              äåëèì åù¸ ðàç, ÷òîáû íàéòè êîíêðåòíóþ ñåðåäèíó âûäåëåííîé ÷àñòè ìàññèâà
        add si, di;             äîáèðàåìñÿ äî ïîðÿäêîâîãî íîìðà ñðåäíåãî ýëåìåíòà âûäåëåííîé ÷àñòè 
        shl si, 1 ; * 2
        mov ax, [bx+si];        ñîõðàíÿåì ðåàëüíîãî ñìåùåíèå ñðåäíåãî ýëåìåíòà âûäåëåííîé ÷àñòè
        mov si, cx;             ëåâàÿ ãðàíèöà
        mov di, dx;             ïðàâàÿ ãðàíèöà
        @@DoWhile:     
                sub si, 2;      îòíèìàåì, ÷òîáû èçáåæàòü ëèøíåãî äîáàâëåíèÿ
                @@WhileLeft:;   èùåì ïåðâûé ýëåìåíò, êîòîðûé áóäåò áîëüøå ñðåäíåãî
                        add si, 2;äîáàâëÿåì ñìåùåíèå
                        mov cx, [bx+si]; 
                        cmp ax, cx 
                        jg @@WhileLeft; ïðîäîëæàåì öèêë, ïîêà ax > cx
            
                add di, 2 
                @@WhileRight:;  èùåì ïåðâûé ýëåìåíò, êîòîðûé áóäåò ìåíüøå ñðåäíåãî
                        sub di, 2
                        mov cx, [bx+di]
                        cmp ax, [bx+di]
                        jl @@WhileRight; ïðîäîëæàåì öèêë ïîêà ax < cx
                                   
                cmp si, di;     åñëè íå íàøëè íóæíûõ ýëåìåíòîâ, çíà÷èò ýòîò ó÷àñòîê îòñîðòèðîâàí
                ja  @@BreakDoWhile
                            
                mov cx, [bx+si];ìåíÿåì ìåñòàìè íàéäåííûå ýëåìåíòû
                mov dx, [bx+di]
                mov [bx+si], dx
                mov [bx+di], cx  
                  
                add  si, 2
                cmp  di, 0
                je   Mark1                 
                sub  di, 2   
                               
                Mark1:    
                cmp  si, di
                jbe  @@DoWhile; åñëè ãðàíèöû ïåðåìàõíóò äðóã çà äðóãà, òî ïðåêðàùàåì ñîðòèðîâêó (åñëè íèæå èëè ðàâíî)
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
