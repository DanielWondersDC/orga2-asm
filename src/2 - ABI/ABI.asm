extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[?], x2[?], x3[?], x4[?], x5[?], x6[?], x7[?], x8[?]
; x1 -> RDI
; x2 -> RSI
; x3 -> RDX
; x4 -> RCX
; x5 -> R8
; x6 -> R9
; x7 -> STACK [RBP + 16]
; x8 -> STACK [RBP + 24]
; (son datos de 32bits, 4 bytes)

alternate_sum_8:
	;prologo
  push RBP
  mov RBP, rsp

  push R9   ;x6 [rbp -8]
  push R8  ;x5 [rbp -16]
  push RCX  ;x4 [rbp -24]
  push RDX ;x3  [rbp -32] guardo los 6 ultimos parametros en el stack
  ;mov [RBP+16], [RBP-20]  ;x7 [rbp -40]      estos dos no hace falta guardarlos pues ay esstan en el stack
  ;mov [RBP+24], [RBP-24]  ;x8 [rbp -48]

  call restar_c  ; x1 - x2 -> RAX

  mov RDI, RAX
  pop RSI ; guardo el resultado en el rdi para pasarlo como parametro

  call sumar_c ; (x1-x2) + x3 -> RAX

  mov RDI, RAX
  pop RSI

  call restar_c ; ((x1-x2) + x3 ) - x4-> RAX

  mov RDI, RAX
  pop RSI

  call sumar_c ; (((x1-x2) + x3 ) - x4)  + x5-> RAX

  mov RDI, RAX
  pop RSI

  call restar_c ; ((((x1-x2) + x3 ) - x4)  + x5) - x6-> RAX

  mov RDI, RAX
  mov RsI, [rbp + 16]              ; saco del stack los otros 2 parametros de entrada 

  call sumar_c ;

  mov RDI, RAX
  mov RsI, [rbp + 24]

  call restar_c

 ; queda el resultado en RAX, no hay que hacern nada en cuanto a eso


	;epilogo
  pop RBP
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[?], x1[?], f1[?]
;DESTINATION int -> RDI
;x1 int-> RSI
;f1 float-> XMM0
product_2_f:

  cvtss2sd xmm0, xmm0 ; f1 float -> Double 

  cvtsi2ss xmm1 ,RSI; x1 int -> float
  cvtss2sd xmm1, xmm1 ; x1 float -> double

  mulsd xmm0, xmm1

  cvttsd2si eax, xmm0     ; eax = (int)(f1 * x1)
  mov [rdi], eax  

	ret



;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[?], f1[?], x2[?], f2[?], x3[?], f3[?], x4[?], f4[?]
;	, x5[?], f5[?], x6[?], f6[?], x7[?], f7[?], x8[?], f8[?],
;	, x9[?], f9[?]
; destination int -> RDI
; x1 int -> RSI
; f1 loat -> XMM0
; x2 int -> RDX
; f2 loat -> XMM1
; x3 int -> RCX
; f3 loat -> XMM2
; x4 int -> R8
; f4 loat -> XMM3
; x5 int -> R9
; f5 loat -> XMM4
; x6 int -> [RBP + 16]
; f6 loat -> XMM5
; x7 int -> [RBP + 24]
; f7 loat -> XMM6
; x8 int -> [RBP + 32]
; f8 loat -> XMM7
; x9 int -> [RBP + 40]
; f9 float -> [rbp + 48]
global product_9_f
product_9_f:
    push rbp
    mov rbp, rsp

    ; Convert float params (f1–f8) to double
    cvtss2sd xmm0, xmm0        ; xmm0 = (double)f1
    cvtss2sd xmm1, xmm1        ; xmm1 = (double)f2
    cvtss2sd xmm2, xmm2        ; xmm2 = (double)f3
    cvtss2sd xmm3, xmm3        ; xmm3 = (double)f4
    cvtss2sd xmm4, xmm4        ; xmm4 = (double)f5
    cvtss2sd xmm5, xmm5        ; xmm5 = (double)f6
    cvtss2sd xmm6, xmm6        ; xmm6 = (double)f7
    cvtss2sd xmm7, xmm7        ; xmm7 = (double)f8
    cvtss2sd xmm9, [RBP +48]

    ; Multiply all floats: xmm0 = f1 * f2 * ... * f8
    mulsd xmm0, xmm1
    mulsd xmm0, xmm2
    mulsd xmm0, xmm3
    mulsd xmm0, xmm4
    mulsd xmm0, xmm5
    mulsd xmm0, xmm6
    mulsd xmm0, xmm7
    mulsd xmm0, xmm9

    ; x1 (RSI)
    cvtsi2sd xmm8, rsi
    mulsd xmm0, xmm8

    ; x2 (RDX)
    cvtsi2sd xmm8, rdx
    mulsd xmm0, xmm8

    ; x3 (RCX)
    cvtsi2sd xmm8, rcx
    mulsd xmm0, xmm8

    ; x4 (R8)
    cvtsi2sd xmm8, r8
    mulsd xmm0, xmm8

    ; x5 (R9)
    cvtsi2sd xmm8, r9
    mulsd xmm0, xmm8

    ; x6 (stack: [rbp + 16])
    mov eax, dword [rbp + 16]
    cvtsi2sd xmm8, eax
    mulsd xmm0, xmm8

    ; x7 (stack: [rbp + 24])
    mov eax, dword [rbp + 24]
    cvtsi2sd xmm8, eax
    mulsd xmm0, xmm8

    ; x8 (stack: [rbp + 32])
    mov eax, dword [rbp + 32]
    cvtsi2sd xmm8, eax
    mulsd xmm0, xmm8

    ; x9 (stack: [rbp + 40])
    mov eax, dword [rbp + 40]
    cvtsi2sd xmm8, eax
    mulsd xmm0, xmm8

    ; Save final result to [rdi]
    movsd qword [rdi], xmm0

    pop rbp
    ret

