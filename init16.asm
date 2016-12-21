;################################################################################
;#	Tí­tulo: Inicialización 16 bits (Modo Real)	  			 					#
;#																				#
;#	Versión:		1.1									Fecha: 	06/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			Actualmente no utilizo esta inicialización debido a que		#
;#					al salir de la inclusión del archivo binario los registros	#
;#					salen con cualquier valor y no pude solucionarlo.			#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Inicialización 16 bits (Modo Real) - Año: 2015   						#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 06/01/2016 | F.POSE | Original									#
;#																				#
;################################################################################

BITS 16
GLOBAL Entry

;################################################################################
;							Sección: Reset_vector
;################################################################################

SECTION .reset_vector
	
	Entry:
		cli
		jmp _init16_inicio
		ALIGN 16

;################################################################################
;							Sección: Init16
;################################################################################

SECTION .init16

BITS 16
_init16_inicio:
	%if DEBUG_MAGIC
	_UMAGIC
%endif
	incbin "init_catedra.bin"
	
	cli
	mov ax, ROM_LOCATION >> 4 ; Segmento ubicado al comienzo del bloque
	mov ds,ax
	mov es,ax
	
	%if DEBUG_MAGIC
	_UMAGIC
%endif
	call enable_A20
%if DEBUG_MAGIC
	_UMAGIC
%endif
	mov eax,valor_gdtr16
	shr eax,4
	and eax, 0xFF00
	mov ds,eax
	mov eax,valor_gdtr16
	and eax,0xff
	lgdt [eax]

;################################################################################
;	Paso a modo protegido
;################################################################################

cli
mov eax,cr0
or al,1
mov cr0,eax

jmp codsel16: dword _init32_start


;################################################################################
;	GDT provisoria para modo real ( 16 bits )
;################################################################################

GDT16:
db 0,0,0,0,0,0,0,0   ;dejar vacio un descriptor

;DESCRIPTOR DE CODIGO FLAT (toda la memoria)
codsel16 equ $-GDT16
dw 0xFFFF	;limite en uno
dw 0x0000	;parte baja de la base en cero
db 0x00		;base 16:23
db 10011000b   ;presente,DPL(x2),sist(cod/dato),tipo(x4)(execute only)
db 11001111b   ;granularidad(limite en mult de 4 pag), D/B, L,                 ;AVL(disponible), (16:19 del limite)
db 0x00		;base

;DESCRIPTOR IGUAL QUE EL ANTERIOR PERO DE DATO
datsel16 equ $-GDT16
dw 0xFFFF	;limite en uno
dw 0x0000	;parte baja de la base en cero
db 0x00		;base 16:23
db 10010010b   ;presente,DPL(x2),sist(cod/dato),tipo(x4)(read/write)
db 11001111b   ;granularidad(limite en mult de 4 pag), D/B, L,                 ;AVL(disponible), (16:19 del limite)
db 0x00		;base

valor_gdtr16:     
	dw $-GDT16
	dd GDT16

;################################################################################
;	Función: Habilitación de A20
;################################################################################

;--------------------------------------------------------------------------------------------------------
; GATE_A20:
; Controla la señal que maneja la compuerta del bit de direcciones A20. La señal de compuerta del bit A20
; toma una salida del procesador de teclado 8042.
; Se debe utilizar cuando se planea acceder en Modo Protegido a direcciones de memoria mas allá del
; 1er. Mbyte.
; El port 60h como entrada lee el scan code de la última tecla presionada, o liberada por el operador de
; la PC. Como salida tiene funciones muy específicas bit a bit: En particular el Bit 1 se utiliza para
; activar el Gate de A20 si se pone en 1 y desactivarlo si está en 0.
; Por otra parte el port 64h es el registro de comandos/estados según se escriba o lea respectivamente
; Llamar con :   AH = 0DDh, si se desea apagar esta se#al. (A20 siempre cero).
;                AL = 0DFh, si se desea disparar esta se#al. (x86 controla A20)
; Devuelve :     AL = 00, si hubo exito. El 8042 acepto el comando.
;                AL = 02, si fallo. El 8042 no acepto el comando.
; En BIOS nuevos aparece la INT 15h con ax 2400 disable, o 2401 enable
;--------------------------------------------------------------------------------------------------------

enable_A20:
        call    empty_8042
        mov     al,0xd1                ; command write
        out     0x64,al
        call    empty_8042
        mov     al,0xdf                ; A20 on
        out     0x60,al
        call    empty_8042
;	ret
empty_8042:
        ;call    delay
        in      al,0x64
        test    al,2
        jnz     empty_8042
        ret             
			
;/* ----------- Fin del archivo ----------- */
