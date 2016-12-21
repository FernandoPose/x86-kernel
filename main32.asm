;################################################################################
;#	Tí­tulo: Función Principal del trabajo práctico (Modo Protegido)				#
;#																				#
;#	Versión:		1.1									Fecha: 	11/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Función principal 32 bits (Modo Protegido) - Año: 2015					#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 11/01/2016 | F.POSE | Original									#
;#		1.1 | 12/01/2016 | F.POSE | Agregué la sección .data y el salto a flush	#
;#		1.2 | 12/01/2016 | F.POSE | Arregle el orden de las cosas en el archivo	#
;#		1.3 | 23/01/2016 | F.POSE | Corregí balance de pila en mensaje de inicio#
;#		1.4 | 26/01/2016 | F.POSE | Agregué la carga del registro y var. modif.	#
;#		2.0 | 30/01/2016 | F.POSE | Agregué variables de secciones dataE y bssE	#
;#		2.1 | 30/01/2016 | F.POSE | init32.asm completo (No modificar)			#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################

;################################################################################
;							Sección: data
;################################################################################

SECTION .dataE2

msgInicio1: 	db "Multitareas con cambio de tarea manual (Ejercicio 8)"
				db	0
msgInicio2: 	db "Alumno : Pose, Fernando Ezequiel"
				db	0
msgInicio3: 	db "Curso : R505x"
				db	0
msgInicio4: 	db "Ano : Ciclo lectivo 2015"
				db	0
msgInicio5: 	db "Tarea fecha del sistema :"
				db	0
msgInicio6: 	db "Tarea hora del sistema  :"
				db	0
msgInicio7: 	db "Tarea contador :"
				db	0							

CantTask	db 	0 					; Cantidad de tareas que hay en la cola
PntNewPage	dd  BaseTablaPaginacion ; Inicializo el puntero de paginación (0x0x00294000)
CurrentTask	dd	0					; Tarea actual	
LastTask	dd	Pag1Tar1 			; Punteros para indicar la dirección de paginación de la anterior tarea
NextTask	dd	Pag1Tar1 			; Puntero para indiciar la dirección de paginación de la próxima tarea

;################################################################################
;							Sección: bssE
;################################################################################

SECTION .bssE

PuntInicioTablaTareas:	resb TablaTareasTam		; Puntero al inicio de la tabla de tareas
PunteroFinTablaTareas:	equ $		 			; Puntero al fin de la tabla de tareas
TASK_IDLE:				equ ($-TareaTablaTam)	; Apunto a la última parte de la tabla de tarea

;################################################################################
;							Sección: Code_main
;################################################################################

BITS 32

SECTION .code_main

	jmp codsel:flush

flush:

;################################################################################
;	Inicializo el Selector de pila y datos
;################################################################################

	mov eax,datsel
	mov ds,ax
	mov ss,ax
	mov es,ax
	mov fs,ax
	mov gs,ax

;################################################################################
;	Activo la paginación
;################################################################################

 	call ActivatePaging

	cld					; selecciono modo incremento, borro la bandera D
	call MensajeInicio	; Imprimo mensaje de entrada a 32 bits
	
;	%if DEBUG_MAGIC
;	_UMAGIC
;	%endif
;	mov eax,dword[0x300000] ; Esto es para probar el PF
	
;	%if DEBUG_MAGIC
;	_UMAGIC
;	%endif
	
;################################################################################
;	Cargo el registro TR
;################################################################################	

	mov ax,tss_ini	; El Scheduler se encuentra en la tarea inicial (IDLE)
	ltr ax
	mov dword[CurrentTask],TASK_IDLE 	; Cargo como tarea inicial la posición de la tarea IDLE
										; en la tabla de tareas
	
	sti  								; Habilita interrupciones

;###############################################################################
;	Tarea: IDLE - Principal.
;################################################################################

; La tarea IDLE es la tarea inicial en la cual se encuentra el sistema es de prioridad 1

InicioTareaIdle:

loop_tarea_idle:
		hlt
		jmp	loop_tarea_idle	

;###############################################################################
;	Imprimo un mensaje de bienvenida.
;################################################################################

MensajeInicio:
	
	call limpiar_pantalla		; Borro pantalla

	push	BLUE_F | INTENSE   ; Paso como parámetro el color y intense
	push	3					; Paso como parámetro el número de la fila a escribir
	push	15					; Paso como parámetro el número de la columna a escribir
	push	msgInicio1			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla
	
	push	BLUE_F | INTENSE   ; Paso como parámetro el color y intense
	push	20					; Paso como parámetro el número de la fila a escribir
	push	1					; Paso como parámetro el número de la columna a escribir
	push	msgInicio2			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla
	
	push	BLUE_F | INTENSE   ; Paso como parámetro el color y intense
	push	22					; Paso como parámetro el número de la fila a escribir
	push	1					; Paso como parámetro el número de la columna a escribir
	push	msgInicio3			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla
	
	push	BLUE_F | INTENSE   ; Paso como parámetro el color y intense
	push	24					; Paso como parámetro el número de la fila a escribir
	push	1					; Paso como parámetro el número de la columna a escribir
	push	msgInicio4			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla

	push	BLUE_F | INTENSE   ; Paso como parámetro el color y intense
	push	8					; Paso como parámetro el número de la fila a escribir
	push	1					; Paso como parámetro el número de la columna a escribir
	push	msgInicio5			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla

	push	BLUE_F | INTENSE   ; Paso como parámetro el color y intense
	push	11					; Paso como parámetro el número de la fila a escribir
	push	1					; Paso como parámetro el número de la columna a escribir
	push	msgInicio6			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla

	push	BLUE_F | INTENSE   	; Paso como parámetro el color y intense
	push	14					; Paso como parámetro el número de la fila a escribir
	push	1					; Paso como parámetro el número de la columna a escribir
	push	msgInicio7			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla
	
	add esp,4*28				; También puede ser cuatro pops seguidos, balance de stack
	
	ret
	
;/* ----------- Fin del archivo ----------- */
