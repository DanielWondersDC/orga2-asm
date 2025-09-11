

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_CATEGORIA EQU 8
NODO_OFFSET_ARREGLO EQU 16
NODO_OFFSET_LONGITUD EQU 24
NODO_SIZE EQU 32
PACKED_NODO_OFFSET_NEXT EQU 0
PACKED_NODO_OFFSET_CATEGORIA EQU 8
PACKED_NODO_OFFSET_ARREGLO EQU 9
PACKED_NODO_OFFSET_LONGITUD EQU 17
PACKED_NODO_SIZE EQU 21
LISTA_OFFSET_HEAD EQU 0
LISTA_SIZE EQU 8
PACKED_LISTA_OFFSET_HEAD EQU 0
PACKED_LISTA_SIZE EQU 8

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;typedef struct nodo_s {
;    struct nodo_s* next;   //asmdef_offset:NODO_OFFSET_NEXT       (0) 8 bytes
;    uint8_t categoria;     //asmdef_offset:NODO_OFFSET_CATEGORIA  (8) 1 byte (9)
;                                                                //() 7 bytes de padding 
;    uint32_t* arreglo;     //asmdef_offset:NODO_OFFSET_ARREGLO    (16) 8 bytes
;    uint32_t longitud;     //asmdef_offset:NODO_OFFSET_LONGITUD   (24) 4 bytes
;                                                                //() 4 bytes de padding
;} nodo_t; //asmdef_size:NODO_SIZE
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[RSI]
cantidad_total_de_elementos:
    push rbp
    mov rbp, rsp

    xor eax, eax                ; eax va a acumular el total (return)
    
    mov r12, [rdi + LISTA_OFFSET_HEAD] ; r12 = puntero al primer nodo (head)

.ciclo:
    test r12, r12               ; ¿ya llegamos al final? (head == NULL)
    je .fin                     ; si es NULL, terminamos

    ; Sumar longitud del nodo actual:
    mov ebx, [r12 + NODO_OFFSET_LONGITUD] ; ebx = nodo->longitud
    add eax, ebx               ; eax += nodo->longitud

    ; Avanzar al siguiente nodo:
    mov r12, [r12 + NODO_OFFSET_NEXT]    ; r12 = nodo->next

    jmp .ciclo                 ; repetir

.fin:
    pop rbp
    ret



;typedef struct __attribute__((__packed__)) packed_nodo_s {
;    struct packed_nodo_s* next;   //asmdef_offset:PACKED_NODO_OFFSET_NEXT  (0) 8 bytes
;    uint8_t categoria;     //asmdef_offset:PACKED_NODO_OFFSET_CATEGORIA    (8) 1 byte (9)
;    uint32_t* arreglo;     //asmdef_offset:PACKED_NODO_OFFSET_ARREGLO      (9) 8 bytes 
;    uint32_t longitud;     //asmdef_offset:PACKED_NODO_OFFSET_LONGITUD     (17) 4 bytes (21)
;} packed_nodo_t; //asmdef_size:PACKED_NODO_SIZE    21 bytes
;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
;puntero a la lista enlazada -> RSI
cantidad_total_de_elementos_packed:

    push rbp
    mov rbp, rsp

    xor eax, eax                ; eax va a acumular el total (return)
    
    mov r12, [rdi + PACKED_LISTA_OFFSET_HEAD] ; r12 = puntero al primer nodo (head)

.ciclo:
    test r12, r12               ; ¿ya llegamos al final? (head == NULL)
    je .fin                     ; si es NULL, terminamos

    ; Sumar longitud del nodo actual:
    mov ebx, [r12 + PACKED_NODO_OFFSET_LONGITUD] ; ebx = nodo->longitud
    add eax, ebx               ; eax += nodo->longitud

    ; Avanzar al siguiente nodo:
    mov r12, [r12 + PACKED_NODO_OFFSET_NEXT]    ; r12 = nodo->next

    jmp .ciclo                 ; repetir

.fin:
    pop rbp
    ret


