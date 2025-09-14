extern strcpy
extern malloc
extern free

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

ITEM_OFFSET_NOMBRE EQU 0
ITEM_OFFSET_ID EQU 12
ITEM_OFFSET_CANTIDAD EQU 16

POINTER_SIZE EQU 4
UINT32_SIZE EQU 8

; Marcar el ejercicio como hecho (`true`) o pendiente (`false`).

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_4_HECHO
EJERCICIO_4_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

global ejercicio1
ejercicio1:
	xor rax, rax; set the acum to 0

	add rax, rdi
	add rax, rsi
    add rax, rdx
    add rax, rcx
	add rax, r8

	ret

global ejercicio2
;void ejercicio2(item_t* un_item, uint32_t id, uint32_t cantidad, char nombre[]);
;puntero al struct -> rdi
;uint_32 id -> rsi
;uint_32 cantidad -> rdx
;nombre[] -> rcx
ejercicio2:
	push rbp
    mov rbp, rsp
	push rdi
	sub rsp, 8

	mov [rdi+ITEM_OFFSET_ID], esi
	mov [rdi+ITEM_OFFSET_CANTIDAD], edx
	add rdi, ITEM_OFFSET_NOMBRE
	mov rsi, rcx
	call strcpy

	add rsp,8
	pop rdi

	pop rbp 
	ret


global ejercicio3
;uint32_t ejercicio3(uint32_t* array, uint32_t size, uint32_t (*fun_ej_3)(uint32_t a, uint32_t b));
;puntero al array -> rdi
;uint_32 n -> esi
;puntero a la funcion fun -> rdx
;fun toma
ejercicio3:
;n = 0 -> 64
;n = 1 -> fun 
    push rbp
    mov rbp, rsp

	cmp esi, 0
	je .vacio
	
	mov rcx, rdi ; array
	mov r8, 0 ; sumatoria
	mov r9, 0 ; i

	.loop:
	push rsi ; n, largo del array
	push r8  ; sumatoria, resultado parcial
	push rcx ; puntero al array
	push r9  ; indice

	mov rdi, r8            ; cargo 1er param 
	mov rsi, [rcx + r9*4]  ; cargo segundo param, 

	call rdx

	pop r9 ; 
	pop rcx  ; 
	pop r8 ;
	pop rsi  


	add r8, rax
	mov rax, r8

	inc r9
	cmp r9, rsi
	je .end

	jmp .loop

	.vacio:
	mov rax, 64

	.end:
	pop rbp
	ret

global ejercicio4
ejercicio4:
	mov r12, rdi
	mov r13, rsi
	mov r14, rdx

	xor rdi, rdi
	mov eax, UINT32_SIZE
	mul esi
	mov edi, eax

	call malloc
	mov r15, rax
	
	xor rbx, rbx
	.loop:
	
	cmp rbx, r13
	je .end

	mov r8, [r12+rbx*POINTER_SIZE]
	mov r9d, [r8]
	mov rax, r14
	mul r9d
	mov [r15+rbx*UINT32_SIZE], eax
	
	mov rsi, r8 
	call free

	inc rbx
	jmp .loop

	.end:
	mov rax, r15
	ret
