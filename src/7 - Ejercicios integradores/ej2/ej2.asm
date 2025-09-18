extern malloc
extern free
section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

global optimizar
;void optimizar(mapa_t mapa, personaje_t* compartida, uint32_t *fun_hash)
; puntero al mapa -> rdi
; puntero a personaje a optimizar -> rsi
; puntero a una funcion fun que dado un struct de un pj te da su hash ->rdx
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = mapa_t           mapa
	; r/m64 = attackunit_t*    compartida
	; r/m64 = uint32_t*        fun_hash(attackunit_t*)
	push rbp
	mov rbp,rsp ; prologo
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	mov r12, rdi ; guardo el mapa en r12
	mov r13, rsi ; guardo el puntero del personaje a optimizar en r13
	mov r14, rdx ; guardo el puntero a la funcion que te da hash del pj

	xor r15,r15 ; i = 0

	xor rbx, rbx ; limpio rbx por las dudas
	mov rdi, r13 ; 
	call r14
	mov rbx, rax  ; guardo el hash de mi unidad en rbx

	.ciclo:
		cmp r15, 65025
		je .end

		xor r8,r8
		imul r8, r15, 8
		mov rdi, [r12 + r8 ] ; guardo en rdi los pj que me encuentro

		cmp rdi, r13
		je .finCiclo ; si me econtre con mi pj, no hago nada

		test rdi,rdi
		je .finCiclo

		call r14
		xor r8,r8
		mov r8, rax; guardo el hash del pj que estoy viendo en r8

		cmp r8, rbx
		je .mismoHash

		jmp .finCiclo

	.finCiclo:
		inc r15
		jmp .ciclo


	.mismoHash:

		xor r9,r9
		xor r11,r11

		imul r11, r15, 8
		mov r9, [r12 + r11] ; GUARDOel puntero al pj

		dec byte[r9 + ATTACKUNIT_REFERENCES] ; le resto uno a las refs del pj

		inc byte[r13 + ATTACKUNIT_REFERENCES] ; le sumo uno a las refs de mi pj

		xor r8,r8
		mov r8b, byte[r9 + ATTACKUNIT_REFERENCES]

		cmp r8, 0
		je .ultimaRef
		jg .sacarRef

	.ultimaRef:
		;r9 puntero al pj del mapa
		;r13 puntero a mi pj
		xor r11,r11
		imul r11, r15, 8

		mov [r12 + r11], r13; piso el puntero del mapa por el mio
		mov rdi, r9
		call free

		jmp .finCiclo
	
	.sacarRef:
		xor r11,r11
		imul r11, r15, 8
		mov [r12 + r11], r13; piso el puntero del mapa por el mio

		jmp .finCiclo



	.end:
		add rsp,8
		pop rbx
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp ; epilogo
		ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	; r/m64 = mapa_t           mapa
	; r/m64 = uint16_t*        fun_combustible(char*)
	ret

global modificarUnidad
modificarUnidad:
	; r/m64 = mapa_t           mapa
	; r/m8  = uint8_t          x
	; r/m8  = uint8_t          y
	; r/m64 = void*            fun_modificar(attackunit_t*)
	ret
