;################################################################################
;#	Tí­tulo: Funciones de tareas									 				#
;#																				#
;#	Versión:		1.1									Fecha: 	19/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Funciones de tareas del sistema del trabajo práctico - Año: 2015		#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 19/01/2016 | F.POSE | Original									#
;#		2.0 | 28/01/2016 | F.POSE | Termine el código de las tareas				#
;#		2.0 | 28/01/2016 | F.POSE | tareas.asm terminado (No modificar)			#
;#																				#
;################################################################################

BITS 32

;###############################################################################
;	Tarea 1: Tarea de HORA.
;################################################################################

SECTION .Tarea1

; La tarea uno es la tarea encargada de imprimir la hora en la pantalla

InicioTareaUno:
	
	mov al,PrintHora		; Es para la función de la System Call - Requiero hora
	int 80					; Genero la interrupción 80 (ver system_call.asm)
	
	; Esto es para la system_call de sleep
	mov al,PrintSleep		; Es para la función de la System Call - Requiero sleep
	mov edx,TicksTar1		; Muevo al acumulador el tiempo de la tarea dormida
	int 80					; Genero la interrupción 80 (ver system_call.asm)
	
	jmp InicioTareaUno

;###############################################################################
;	Tarea 2: Tarea de FECHA.
;################################################################################

SECTION .Tarea2

; La tarea dos es la tarea encargada de imprimir la fecha en la pantalla

InicioTareaDos:

	mov al,PrintFecha		; Es para la función de la System Call - Requiero fecha
	int 80					; Genero la interrupción 80 (ver system_call.asm)

	; Esto es para la system_call de sleep
	
	mov edx,TicksTar2		; Muevo al acumulador el tiempo de la tarea dormida
	mov al,PrintSleep		; Es para la función de la System Call - Requiero sleep
	int 80					; Genero la interrupción 80 (ver system_call.asm)

	jmp InicioTareaDos

;###############################################################################
;	Tarea 3: Tarea de CONTADOR.
;################################################################################

SECTION .Tarea3

; La tarea tres es la tarea encargada de imprimir un contador en la pantalla

InicioTareaTres:
	
	mov al,PrintContador	; Es para la función de la System Call - Requiero contador
	int 80					; Genero la interrupción 80 (ver system_call.asm)
	
	; Esto es para la system_call de sleep
	mov edx,TicksTar3		; Muevo al acumulador el tiempo de la tarea dormida
	mov al,PrintSleep		; Es para la función de la System Call - Requiero sleep
	int 80					; Genero la interrupción 80 (ver system_call.asm)

	jmp InicioTareaTres

;/* ----------- Fin del archivo ----------- */
