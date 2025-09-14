extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	ret

; char* strClone(char* a)
strClone:
    push rbp
    mov rbp, rsp

    ; rdi = src
    mov rsi, rdi        ; guardar src en rsi
    call strLen         ; strLen espera el string en rsi
                        ; rax ← longitud sin '\0'

    inc rax             ; incluir espacio para '\0'
    mov rdi, rax        ; malloc espera tamaño en rdi
    call malloc         ; rax ← puntero a memoria nueva

    ; ahora: rsi = src, rax = dst
    mov rdx, rax        ; guardamos dst en rdx
    xor rcx, rcx        ; índice = 0

.copy_loop:
    mov bl, [rsi + rcx]     ; leer byte del string original
    mov [rdx + rcx], bl     ; escribir en la copia
    cmp bl, 0               ; ¿fin de string?
    je .done
    inc rcx
    jmp .copy_loop

.done:
    mov rax, rdx            ; devolver copia

    pop rbp
    ret

; void strDelete(char* a)
strDelete:
    push rbp
    mov rbp, rsp

    ; rdi ya contiene el puntero a liberar
    call free

    pop rbp
    ret
	
; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
;puntero al string -> RSI
strLen:
    push rbp
    mov rbp, rsp

    xor rcx, rcx         ; contador = 0

.ciclo:
    mov r11b, [rdi + rcx]  ; leer str[contador]
    cmp r11b, 0            ; ¿fin del string?
    je .fin

    inc rcx
    jmp .ciclo

.fin:
    mov rax, rcx         ; devolver longitud
    pop rbp
    ret

