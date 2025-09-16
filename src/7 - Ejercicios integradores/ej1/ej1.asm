extern malloc

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
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
;bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);
; puntero al array de punteros a structs (inventario) -> rdi
; puntero al array con indices ordenados -> rsi
; tamanio de ambos arrays -> dx
; comparador (puntero a una funcion)
;((esta funcion devuelve true si el el segundo elemento es mejor que el primero)) -> rcx
es_indice_ordenado:
	push rbp
	mov rbp,rsp ; prologo
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	xor r12, r12 ; i = 0 (indice recorredor del arreglo)

	mov r13, rcx; guardo el puntero la funcion comparadora
	mov r14, rdi ; guardo en r14 el puntero al inventario
	mov r15, rsi ; guardo en r15 el puntero al arreglo de indices
	mov bx, dx ; guardo el tamanio en bx

	
	cmp bx, 1 ; si el inv es de tamanio 1 voy al fin
	je .end

	sub bx, 1 ; tamanio = tamqnio -1 (porque agarro array[n +1])

	.ciclo: ; voy ciclando a traves del array con indices
		cmp bx, r12w
		je .end

		xor r8,r8
		xor r9,r9 ; limpio la parte alta
		mov r8w, word[r15 + r12 * 2] ; guardo el indice en r8
		mov r9w, word[r15 + (r12 + 1) * 2] ; guardo el siguiente en r9
		; ahora sabiendo los 2 indices voy a buscar los datos al inventario

		mov rdi, [r14 + r8 * 8]; agarro los strucs del inventario y los meto en params
		mov rsi, [r14 + r9 * 8]

		call r13 ; llamo al comparador
		
		test rax, rax ; miro si el res es false = ekemento no ordenado bien
		je .badEnd

		inc r12; i++
		jmp .ciclo




	.badEnd:
		mov rax, 0
		jmp .end



	.end:
		add rsp,8
		pop rbx
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp ; epilogo
		ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
;item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);
; puntero al inventario(array de structs) -> rdi
; puntero al array de indices(array de int16) -> rsi
; tamanio de los arrays -> dx
indice_a_inventario:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	xor r14, r14 ; limpio por si tiene algo en la parte alta

	mov r12, rdi ; guardo el pointer al inventario en r12
	mov r13, rsi ; guardo el pointer al array de indices en r13
	mov r14w, dx ; guardo el tmanio en r14

	xor rax,rax
	mov rax, 8 ; limpio y meto 8 en el rax para multiplicar por la cantidad de elementos
	mul r14w ; largo de mi nuevo array(n* 8bytes(pointer size))
	mov rdi, rax ; llevo el size al rdi para el malloc

	call malloc 
	mov r15, rax; guardo el pointer al heap en r15

	xor rbx,rbx ; i=0

	.ciclo:
		cmp bx, r14w
		je .end 

		xor r8,r8; limpio por las dudas
		mov r8w, word[r13 + rbx * 2] ; guardo el indice en r8

		mov r9, [r12 + r8 * 8] ; agarro el pointer en el array de pointers

		mov [r15 + rbx * 8], r9 ; guardo el pointer en mi nuevo array en malloc

		inc rbx
		jmp .ciclo




	.end:
		mov rax, r15 ; guardo el pointer al nuevo array en rax

		add rsp,8
		pop rbx
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp ; epilogo
		ret