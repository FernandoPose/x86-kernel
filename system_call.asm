;################################################################################
;#	Tí­tulo: Syste Call - Trabajo Práctico					 					#
;#																				#
;#	Versión:		1.1									Fecha: 	26/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		FUnciones auxiliares creadas para el trabajo práctico - Año: 2015		#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 26/01/2016 | F.POSE | Original									#
;#		2.0 | 27/01/2016 | F.POSE | Corregí balance de stack					#
;#		2.1 | 01/02/2016 | F.POSE | Agregué la función sleep					#
;#		3.0 | 01/01/2016 | F.POSE | system_call.asm completo (No modificar)		#
;#																				#
;################################################################################

BITS 32

SECTION .dataE

msgHora: 		db 	"Hora del Sistema:  :  :  ", NULL
msgFecha: 		db 	"Fecha del Sistema:  /  /  -  ", NULL
msgErrorRTC:	db 	"¡Alto! Error en las funciones de RTC", NULL
msgErrorTable:	db 	"¡Alto! Cola de tareas llena", NULL
msgContador:	db 	"Contador: 000000000",NULL

;################################################################################
;							Sección: Servicio del sistema
;################################################################################

SECTION .ServicioSistema

;################################################################################
;	Función: Función System Call
;################################################################################

; Nota: En el registro ebx tengo la cantidad de ticks

SystemCall:
	
	push	ebp
	mov	ebp,esp
	
	cmp al,PrintFecha		; Servicio: Imprimir la fecha del sistema
	jz	FuncionFecha
	
	cmp al,PrintHora		; Servicio: Imprimir la hora del sistema
	jz	FuncionHora
	
	cmp al,PrintContador	; Servicio: Imprimir un contador
	jz	FuncionContador

	cmp	al,PrintSleep		; Servicio: Duerme!
	jz	FuncionSleep
	
	jmp FinSysteCall

FuncionFecha:

	mov	al,0					; Muevo al acumulador 0 para obtener la fecha (Ver rtc.asm)
	call ObtenerFecha			; Salto a la función que utiliza RTC_Service para obtener la fecha

	push	BLUE_F | INTENSE	; Paso como parámetro el color y intense
	push	9					; Paso como parámetro el número de la fila a escribir
	push	20					; Paso como parámetro el número de la columna a escribir
	push	msgFecha			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla
	add esp,4*4					; También puede ser cuatro pops seguidos, balance de stack
	
	jmp FinSysteCall			; Termino la función de obtener la fecha
	
FuncionHora:	
	
	mov al,1					;para que busque la hora
	call ObtengoHora			; Salto a la función que utiliza la RTC_Service para obtener la hora

	push	BLUE_F | INTENSE   	; Paso como parámetro el color y intense
	push	12					; Paso como parámetro el número de la fila a escribir
	push	20					; Paso como parámetro el número de la columna a escribir
	push	msgHora				; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla
	add esp,4*4					; También puede ser cuatro pops seguidos, balance de stack
	
	jmp FinSysteCall			; Termino la función de obtener la hora

FuncionContador:
		
	call    ObtengoContador

	push	BLUE_F | INTENSE   	; Paso como parámetro el color y intense
	push	15					; Paso como parámetro el número de la fila a escribir
	push	20					; Paso como parámetro el número de la columna a escribir
	push	msgContador			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla
	add esp,4*4					; También puede ser cuatro pops seguidos, balance de stack
	
	jmp FinSysteCall			; Termino la función de obtener el contador
	
;################################################################################
;	Función: Sleep
;################################################################################

FuncionSleep:
		
	mov eax,PuntInicioTablaTareas	; Apunto a la tabla de tareas cargadas
	mov ecx,MaxNumTareas			; Cargo en ecx el máximo de tareas cargadas permitidas 	

BuscarTarea:
	
	mov ebx,cr3							; Obengo el CR3 de la tarea actual
	cmp ebx,[eax + TareaTabla.IdCr3]	; Comparo CR3 actual contra CR3 de la tarea de la tabla seleccionada
	je CargarTicks						; Si es la tarea llamante, debo cargar ticks de sleep
	add eax,TareaTablaTam				; Apunto a la próxima tarea en la tabla de tareas 
	loop BuscarTarea					; Realizo los pasos con las siguientes tareas de la tabla

CargarTicks:
	
	mov ebx,eax							; Guardo la dirección actual
	add ebx,TareaTabla.TSleep			; Apunto a la columna de los ticks de sleep
	mov eax,edx							; Le guardo los ticks a dormir la tarea
	mov edx,0x00						; Borro el dividiendo superior
	mov ecx,10							; Cargo el divisor
	div ecx								; Obtengo ticks del sleep(int c/10mS)
	
	mov [ebx],eax					; Cargo en ebx los ticks					
	
	int 0x20			; Impongo la interrupción por timer
	
	jmp FinSysteCall	; Termino la función de obtener Sleep


ErrorFuncionRTC:
	
	call limpiar_pantalla		; Borro pantalla

	push	BLUE_F | INTENSE  	; Paso como parámetro el color y intense
	push	10					; Paso como parámetro el número de la fila a escribir
	push	15					; Paso como parámetro el número de la columna a escribir
	push	msgErrorRTC			; Paso como parámetro el string a imprimir
	call	print				; Imprimo mensaje en la pantalla
	add esp,4*4					; También puede ser cuatro pops seguidos, balance de stack

FinSysteCall:

	mov	esp,ebp
	pop ebp
	
	iret  	
		
;/* ----------- Fin del archivo ----------- */
