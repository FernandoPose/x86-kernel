;################################################################################
;#	Tí­tulo: Estructuras - Trabajo Práctico			 					#
;#																				#
;#	Versión:		1.1									Fecha: 	29/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Estructuras que utilizo para el trabajo práctico - Año: 2015			#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 29/01/2016 | F.POSE | Original									#
;#		2.0 | 29/01/2016 | F.POSE | Agregué la estructura TSS, Contexto y Tarea	#
;#		2.0 | 29/01/2016 | F.POSE | estructuras.asm completo (No modificar)		#
;#																				#
;################################################################################

BITS 32

;################################################################################
;							Sección: bssE
;################################################################################

SECTION .bssE

;################################################################################
;	Estructura: Contexto de la tarea
;################################################################################

struc Contexto

	.ESP0:			 resd	1
    .posterior_ESP0: resd	1
    .CR3:			 resd	1
    .ESP:			 resd	1
    .SS:			 resw	1
    .SS0:			 resw	1
	.size:
    
ENDSTRUC

;################################################################################
;	Estructura: Estructura TSS IA-32
;################################################################################

STRUC EstructuraTSS ;TSS-IA32

	.reg_BL:		resw 2		; Back link.
	.reg_ESP0:		resd 1		; ESP0
	.reg_SS0:		resw 2		; SS0
  	.reg_ESP1:		resd 1		; ESP1
  	.reg_SS1:		resw 2		; SS1
  	.reg_ESP2:		resd 1		; ESP2
 	.reg_SS2:		resw 2		; SS2
  	.reg_CR3:		resd 1		; CR3
  	.reg_EIP:		resd 1		; EIP
  	.reg_EFLAGS:	resd 1		; EFLAGS
  	.reg_EAX:		resd 1		; EAX
  	.reg_EBX:		resd 1		; EBX
  	.reg_ECX:		resd 1		; ECX
  	.reg_EDX:		resd 1		; EDX
  	.reg_ESP:		resd 1		; ESP
  	.reg_EBP:		resd 1		; EBP
  	.reg_ESI:		resd 1		; ESI
  	.reg_EDI:		resd 1		; EDI
  	.reg_ES:		resw 2		; ES
  	.reg_CS:		resw 2		; CS
  	.reg_SS:		resw 2		; SS
  	.reg_DS:		resw 2		; DS
  	.reg_FS:		resw 2		; FS
  	.reg_GS:		resw 2		; GS
  	.size:
  	
ENDSTRUC

;################################################################################
;	Estructura: Estructura de la tabla de las tareas
;################################################################################

STRUC TareaTabla
	
	
	.TSleep:	resd 1
  	.IdCr3:		resd 1
  	.rContexto:	resd 1
  	.Prioridad:	resb 1
  	.size:
  	
ENDSTRUC

;/* ----------- Fin del archivo ----------- */
