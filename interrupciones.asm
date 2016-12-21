;################################################################################
;#	TÃ­tulo: Interrupciones del sistema							 				#
;#																				#
;#	Versión:		1.1									Fecha: 	14/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Interrupciones del sistema del trabajo práctico - Año: 2015				#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 14/01/2016 | F.POSE | Original									#
;#		1.1 | 23/01/2016 | F.POSE | Corregí el balance de pila en las excep.	#
;#		1.2 | 27/01/2016 | F.POSE | Corregí la interrupción de timer.			#
;#		1.2 | 30/01/2016 | F.POSE | Comencé a escribir el scheduler.			#
;#		2.0 | 31/01/2016 | F.POSE | interrupciones.asm completo (No modificar)	#
;#		5.0 | 10/01/2016 | F.POSE | Arregle funciones de timertick.				#
;#																				#
;################################################################################

BITS 32

SECTION .dataE

msgTimer: 				db "Se produjo la interrupcion por timer..", NULL
msgKeyboard: 			db "Se produjo la interrupcion por teclado..", NULL

;################################################################################
;							Sección: TimerHandler
;################################################################################

SECTION .TimerHandler
	
 	pushad			; Salvo todos los registros de propósito general 	
	push ds			; Salvo el selector de datos

	mov ax,datsel	; Cargo el selector de datos de Kernel (Privilegio 0)
	mov	ds,ax		; Cargo el selector de datos Kernel en el selector de datos

	; LImpiar el PIC sino, se rompe
	mov al,0x20     ; Indico fin de interrupción al PIC
	out 0x20,al        
	
	; Decremento los ticks - Obtengo prioridad máxima - Obtengo el valor final de la tabla
 	call DecrementarTiempo						; Decremento los ticks cargados en las tareas (TSleep)
	mov	eax,dword[CurrentTask]					; Cargo en eax la dirección de la tarea actualmente en ejecución
	mov	dl,byte	[eax + TareaTabla.Prioridad]	; Obtengo la prioridad de la tarea actualmente en ejecución
	mov	dh,PrioridadMaxima	       				; Guardo en parte alta de EDX la prioridad máxima de una tarea

; Busco la próxima tarea
LoopProximaTarea:

	add	eax,TareaTablaTam			; Cargo en eax la dirección de la próxima tarea a la actual ubicada en la tabla de tareas
	mov	ebx,PunteroFinTablaTareas	; Guardo la dirección donde termina la tabla de tareas enlistadas en la tabla de tareas del sistema
	cmp	eax,ebx						; Comparo contra la última tarea cargada en la tabla de tareas
	jge	InicioTabla					; Si es mayor o igual que la última tarea, llegué a la última tarea y me posiciono
									; al principio de la tabla de tareas cargadas en la tabla
									
; Si no es el final de la tabla sigo buscando la nueva tarea a ejecutar
ContinuarProximaTarea:	
	
	mov	ebx,dword[CurrentTask]				; Cargo la dirección de la tarea que se ejecuta actualmente al llegar la INT
	cmp	eax,ebx								; Comparo la siguiente tarea a ejecutar y la última tarea (actual) ejecutada
											; de forma de asegurarme que no sea la misma tarea y haya pegado toda la vuelta a la tabla
	je	DecrementoPrioridad					; Si es la misma tarea decremento la prioridad buscada para encontrar una nueva tarea
											; de la prioridad buscada
											
; En este punto tengo:
;						eax:	Próxima tarea a verificar
;						ebx:	Tarea en ejecución actualmente
;						dh :	Prioridad máxima actualmente

	mov	dl,byte[eax + TareaTabla.Prioridad]	; Obtengo la prioridad de la tarea nueva a ejecutar
	cmp	dl,dh								; Comparo la prioridad de la tarea nueva con la máxima actualmente
	jge	VerificarTiempoSleep				; Si es mayor o igual prioridad verifico si tiene que seguir "dormida"
	
	jmp	LoopProximaTarea					; Si es menor prioridad busco la próxima tarea en la tabla de tareas

; Decremento la prioridad buscada en la tabla de tareas
DecrementoPrioridad:	

	; Verifico si estoy en la tarea IDLE (prioridad 1) ó si estoy en otra tarea de prioridad 2-9
	cmp	dh,1				; Comparo si me encuentro en una tarea de prioridad 1 (por enunciado tarea IDLE)
	je	TerminarInt			; Si me encuentro en dicha tarea no debo cambiar el contexto
	
	; Disminuyo prioridad si es que no estoy en la tarea IDLE
	mov	dl,byte[eax + TareaTabla.Prioridad]	; Obtengo la prioridad de la tarea futura
	cmp	dl,dh								; Verifico si la próxima tarea en la lista
											; tiene mayor ó igual prioridad
	sub dh,1								; Decremento la prioridad de búsqueda

	jge	LoopProximaTarea					; Si es de mayor prioridad busco nueva tarea en la tabla de tareas

	jmp	VerificarTiempoSleep				; Si la próxima tarea en la lista tiene menor prioridad verifico
											; antes de cambiar de tarea si no debo seguir ejecutando la tarea actual
	
InicioTabla:	

	mov	eax,PuntInicioTablaTareas		
	
	jmp	ContinuarProximaTarea	

; Verifico el estado de la tarea si está o no dormida	
VerificarTiempoSleep:	
	
	cmp	dword[eax + TareaTabla.TSleep],PrioridadSleep	; Verifico que la siguiente tarea no este dormida
														; tenga ticks o no esté inicializada (-1)	
	jne	LoopProximaTarea								; Si no está dormida continuo a la próxima tarea
	
VerificarCR3:

	mov	ebx,dword[CurrentTask + TareaTabla.IdCr3]		; Cargo en ebx el CR3 de la tarea que generó la INT
	mov	ecx,dword[eax + TareaTabla.IdCr3]				; Cargo en ecx el CR3 de la próxima tarea en tabla
	cmp	ebx,ecx											; Si no coinciden tengo que cambiar a la tarea actual
														; al momento de generar la interrupción
	je	TerminarInt										; Si coinciden no cambio el contexto, de lo contrario
														; debo cambiar el contexto

; Realizo el cambio de contexto (Cambio de tarea)
CambiarContexto:

	; Realizo el salvado del contexto de la tarea actual antes de ejecutarse la interrupción
	mov	 ebx,dword[CurrentTask]			; Cargo ebx con la tarea actual, perteneciente a la
										; tabla de tareas que se encuentra en ejecución
	add	 ebx,TareaTabla.rContexto		; Quedo apuntando al contexto de la tarea actual
	mov	 ebx,dword[ebx]					; Cargo en ebx el contexto de la tarea en ejecución
	push ebx							; Apilo el puntero al contexto de la tarea que se está
										; ejecutando para pasar por pila a la función que se
										; encarga de guardar el contexto
	call GuardarContexto				; Guardo el contexto de la tarea actual ejecutandose

	; Nota: En este momento eax tiene la dirección de la tarea próxima a ejecutar
	
	; Realizo el cambio de contexto - Paso a la nueva tarea que se debe ejercutar
	mov	 dword[CurrentTask],eax			; Cargo CurrentTask con la dirección de la nueva
										; tarea a ejecutar
	add	 eax,TareaTabla.rContexto		; Quedo apuntando al contexto de la tarea a ejecutar
	mov	 eax,dword[eax]					; Cargo en eax el contexto de la tarea a ejecutar
	push eax							; Apilo el puntero al contexto de la tarea que se 
										; ejecutará para pasar por pila a la función que se
										; encarga de cargar el contexto

	call CargarContexto					; Cargo el contexto de la tarea que se va a ejecutar	

	; Cargo el nuevo valor de CR3 y esp de la nueva tarea a ejecutar
	mov	cr3,eax							; Cargo el nuevo CR3, que se retorna por pila en eax
										; por la función CambiarContexto
	mov	esp,ebx							; Cargo ESP0 de la tarea nueva, que es retornado por pila
										; en ebx por la función CambiarContexto

; Termino la interrupción por timer
TerminarInt:

 	pop ds		; Popeo el selector de datos
	popad		; Popeo todos los registros de propósito general pusheados	
		
	iret		; Retorno de la interrupción
	
;################################################################################
;							Sección: keyboardHandler
;################################################################################

SECTION .keyboardHandler ; Ejercicio 5 - No está implementada.

	push		eax
	
	in			al,60h			
	mov 		al,20h
	out			20h,al
	pop			eax
	
	iret

;/* ----------- Fin del archivo ----------- */
