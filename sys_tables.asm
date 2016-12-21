;################################################################################
;#	TÃ­tulo: Tablas del sistema								 					#
;#																				#
;#	Versión:		1.1									Fecha: 	04/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Tablas del sistema del trabajo práctico - Año: 2015						#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 04/01/2016 | F.POSE | Original									#
;#		1.1 | 04/01/2016 | F.POSE | Agregué la IDT								#
;#		1.2 | 18/01/2016 | F.POSE | Agregué descriptores de nivel 3 (usuario)	#
;#		1.3 | 26/01/2016 | F.POSE | Agregué INT80 a la IDT						#
;#		2.0 | 30/01/2016 | F.POSE | sys_tables.asm completo (No modificar)		#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################

;--------------------------------------------------------------------------------
; Globales
;--------------------------------------------------------------------------------

GLOBAL valor_gdtr
GLOBAL codsel
GLOBAL datsel
GLOBAL valor_idtr

;--------------------------------------------------------------------------------
; GDT
;--------------------------------------------------------------------------------

SECTION .sys_tables

GDT:
	db 0,0,0,0,0,0,0,0   ;dejar vacio un descriptor

;DESCRIPTOR DE CODIGO FLAT NIVEL 0(toda la memoria)
codsel equ $-GDT
	dw 0xFFFF		;limite en uno
	dw 0x0000		;parte baja de la base en cero
	db 0x00			;base 16:23
	db 10011000b    ;presente,DPL(x2),sist(cod/dato),tipo(x4)(execute only)
	db 11001111b    ;granularidad(limite en mult de 4 pag), D/B, L, ;AVL(disponible), (16:19 del limite)
	db 0x00		    ;base

;DESCRIPTOR DE DATOS FLAT NIVEL 0 (toda la memoria)
datsel equ $-GDT
	dw 0xFFFF		;limite en uno
	dw 0x0000		;parte baja de la base en cero
	db 0x00			;base 16:23
	db 10010010b  	;presente,DPL(x2),sist(cod/dato),tipo(x4)(read/write)
	db 11001111b  	;granularidad(limite en mult de 4 pag), D/B, L, ;AVL(disponible), (16:19 del limite)
	db 0x00			;base

; DESCRIPTOR DE CODIGO FLAT NIVEL 3 (toda la memoria)
codselUser equ $-GDT            
	dw 0xFFFF		;limite en uno
	dw 0x0000		;parte baja de la base en cero
	db 0x00			;base 16:23
	db 11111010b	;presente,DPL(x2),sist(cod/dato),tipo(x4)(execute only)
	db 11001111b	;granularidad(limite en mult de 4 pag), D/B, L, ;AVL(disponible), (16:19 del limite)
	db 0x00			;base

;DESCRIPTOR DE DATOS FLAT NIVEL 3 (toda la memoria)
datselUser equ $-GDT
	dw 0xFFFF		;limite en uno
	dw 0x0000		;parte baja de la base en cero
	db 0x00			;base 16:23
	db 11110010b	;presente,DPL(x2),sist(cod/dato),tipo(x4)(read/write)
	db 11001111b	;granularidad(limite en mult de 4 pag), D/B, L, ;AVL(disponible), (16:19 del limite)
	db 0x00			;base

tss_ini	EQU	$-GDT
	dw		0x67			; Tamaño mínimo de la TSS (104 -1) (0 - 15)
	dw		0				; Base parte baja (0 - 15)  - Lo lleno en tiempo de ejecución
	db		0				; Base parte media (16 - 23)
	db		0x89			; Permisos del descriptor (Kernel) de TSS (Desocupada)
	db		0				;
	db		0				; Base parte alta	(24 - 31) - Lo lleno en tiempo de ejecución

valor_gdtr:     
	dw $-GDT
	dd GDT
				
;--------------------------------------------------------------------------------
; IDT
;--------------------------------------------------------------------------------
		
IDT:

; Error de división #DE - Clase Falta.

divisionError equ $-IDT
	    dw divisionErrorLow 		
	    dw codsel
	    db 0
	    db 0x8F
	    dw divisionErrorHigh
	     			
times 5*8 db 0 

; Código OP no válido #UD - Clase Falta.

undefinedcode equ $-IDT
	    dw undefinedcodeLow 		
	    dw codsel
	    db	0
	    db 0x8F
	    dw undefinedcodeHigh 		

times 1*8 db 0 

; Doble falta #DF - Clase Aborto.

doublefault equ $-IDT
	    dw doublefaultLow 		
	    dw codsel
	    db	0
	    db 0x8F
	    dw doublefaultHigh		

times 4*8 db 0 

;Protección general #GP - Clase Falta.

generalprotection equ $-IDT
	    dw generalprotectionLow	
	    dw codsel
	    db	0
	    db 0x8F
	    dw generalprotectionHigh 	
	    		
; Fallo de página #PF - Clase Falta.

pagefault equ $-IDT
	    dw pagefaultLow 		
	    dw codsel
	    db	0
	    db 0x8F
	    dw pagefaultHigh 		

times 17*8 db 0 ; Reservadas por Intel

; Interrupción de timer

timer equ $-IDT
	    dw timerLow 		
	    dw codsel
	    db	0
	    db 0x8E
	    dw timerHigh 	
	    	    
; Interrupción del teclado

keyboard equ $-IDT
	    dw keyboardLow 		
	    dw codsel
	    db	0
	    db 0x8E
	    dw keyboardHigh

times 46*8 db 0

INT80 equ $-IDT
	    dw ServicioSistemaLow 		
	    dw codsel
	    db	0
	    db 0xEE
	    dw ServicioSistemaHigh

times 174*8 db 0 ; Completo a 255 descriptores.

valor_idtr:   
			dw	$-IDT		;defino el limite de la idtr
			dd	IDT			;base de la idtr

ALIGN 4096

IndicePag:	; de acá en adelante directorios/tablas de página (ver PF)

;/* ----------- Fin del archivo ----------- */
