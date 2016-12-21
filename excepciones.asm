;################################################################################
;#	TÃ­tulo: Excepciones del sistema							 					#
;#																				#
;#	Versión:		1.1									Fecha: 	14/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Excepciones del sistema del trabajo práctico - Año: 2015				#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 14/01/2016 | F.POSE | Original									#
;#		2.0 | 23/01/2016 | F.POSE | Le agregué el PF - Funciona correctamente	#
;#		3.0 | 24/01/2016 | F.POSE | excepciones.asm completo (No modificar)		#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################

BITS 32

SECTION .dataE1

msgDivisionError: 		db "¡ALTO! Se produjo la excepcion 0..", NULL
msgUndefinedcode: 		db "¡ALTO! Se produjo la excepcion 6..", NULL
msgDoublefault:   		db "¡ALTO! Se produjo la excepcion 8..", NULL
msgGeneralprotection: 	db "¡ALTO! Se produjo la excepcion 13..", NULL
msgPagefault: 			db "¡ALTO! Se produjo la excepcion 14..", NULL

AuxNuevPag	 		dd	0x00160000	; Dirección física a partir de la cual se crean las páginas.
NuevaPagTab		 	dd	IndicePag	; Dirección donde creo la DP	

;################################################################################
;							Sección: DEHandler
;################################################################################

SECTION .DEHandler
	
	%if DEBUG_MAGIC
	_UMAGIC
	%endif
		
	call	limpiar_pantalla	; Limpio pantalla
	push	RED_F | INTENSE		; Paso como parámetro el color y intense
	push	0					; Paso como parámetro el número de la fila a escribir
	push	0					; Paso como parámetro el número de la columna a escribir
	push	msgDivisionError	; Paso como parámetro el string a imprimir
	call	print				; Imprimo la leyenda en la pantalla
	add		esp,16				; Equivale a cuatro pops consecutivos
	hlt							; Pongo el procesador en alta impedancia
	jmp		$-1					; Acá finaliza el programa si salta una DE
	iret
	
;################################################################################
;							Sección: UDHandler
;################################################################################

SECTION .UDHandler

	%if DEBUG_MAGIC
	_UMAGIC
	%endif

	call	limpiar_pantalla	; Limpio pantalla
	push	RED_F | INTENSE		; Paso como parámetro el color y intense
	push	0					; Paso como parámetro el número de la fila a escribir
	push	0					; Paso como parámetro el número de la columna a escribir
	push	msgUndefinedcode	; Paso como parámetro el string a imprimir
	call	print				; Imprimo la leyenda en la pantalla
	add		esp,16				; Equivale a cuatro pops consecutivos
	hlt							; Pongo el procesador en alta impedancia
	jmp		$-1					; Acá finaliza el programa si salta una UD
	iret

;################################################################################
;							Sección: DFHandler
;################################################################################

SECTION .DFHandler

	%if DEBUG_MAGIC
	_UMAGIC
	%endif

	call	limpiar_pantalla	; Limpio pantalla
	push	RED_F | INTENSE		; Paso como parámetro el color y intense
	push	0					; Paso como parámetro el número de la fila a escribir
	push	0					; Paso como parámetro el número de la columna a escribir
	push	msgDoublefault		; Paso como parámetro el string a imprimir
	call	print				; Imprimo la leyenda en la pantalla
	add		esp,16				; Equivale a cuatro pops consecutivos
	hlt							; Pongo el procesador en alta impedancia
	jmp		$-1					; Acá finaliza el programa si salta una DF
	iret

;################################################################################
;							Sección: GPHandler
;################################################################################

SECTION .GPHandler

	%if DEBUG_MAGIC
	_UMAGIC
	%endif

	call	limpiar_pantalla	; Limpio pantalla
	push	RED_F | INTENSE		; Paso como parámetro el color y intense
	push	0					; Paso como parámetro el número de la fila a escribir
	push	0					; Paso como parámetro el número de la columna a escribir
	push	msgGeneralprotection; Paso como parámetro el string a imprimir
	call	print				; Imprimo la leyenda en la pantalla
	add		esp,16				; Equivale a cuatro pops consecutivos
	hlt							; Pongo el procesador en alta impedancia
	jmp 	$-1					; Acá finaliza el programa si salta una GP
	iret

;################################################################################
;							Sección: PFHandler
;################################################################################

SECTION .PFHandler

	%if DEBUG_MAGIC
	_UMAGIC
	%endif

;31                4                             0
;+-----+-----+-----+-----+-----+-----+-----+-----+
;|     Reserved    | I/D | RSVD| U/S | W/R |  P  |
;+-----+-----+-----+-----+-----+-----+-----+-----+

;	P: When set, the fault was caused by a protection violation.
;   When not set, it was caused by a non-present page.
;   W/R: When set, write access caused the fault; otherwise read access.
;   U/S: When set, the fault occurred in user mode; otherwise in supervisor mode.
;   RSVD: When set, one or more page directory entries contain reserved bits which are set to 1.
;   This only applies when the PSE or PAE flags in CR4 are set to 1.
;   I/D: When set, the fault was caused by an instruction fetch.
;   This only applies when the No-Execute bit is supported and enabled. 
	


; Para esta exepción utilizo los registros eax, ebx y ecx para cortar la dirección lineal.
; Utilizo los registros exd, esi y edi como indices de la PDP, DP y TP 
; Para más información ir al cuadernillo donde está el dibujo!

	cli						; Deshabilito las interrupciones
	pop 	eax				; Analizo el código de error que quedó en la primera posición de la pila
	pushad					; Salvo los registros de propósito general, los voy a modificar
	push	ebp				; Pusheo el base pointer en la pila 
	mov		ebp,esp			; Resguardo la posición de la pila al momento de comenzar la función
	
	and		eax,0x01		; Obtengo el bit 1 del error code (Bit de presencia)
	jnz		NO_ES_PAG_AUS	; Si es un problema de permisos no lo soluciono y me voy al final

	; Si es por página ausente tengo que armar la página y lo hago a partir de acá.
	
	mov		edi,[AuxNuevPag]; Dirección donde se va a crear la nueva página	
	or		edi,0x03		; Le pongo los permisos a la página nueva a crear
	
	add		dword[AuxNuevPag],PG_TAM	; Avanzo 4k para cuando sea necesario una nueva página no sobreescribir
	
	
	; Obtengo los índices de la dirección lineal (Que se carga en el registro CR2)
	
	mov		eax,cr2		; Guardo en eax la dirección lineal no presente
	shr		eax,30		; Obtengo el indice de PDPT
	
	mov		ebx,cr2		; Guardo en ebx la dirección lineal no presente
	shr		ebx,21		; Obtengo el indice de la DP
	and		ebx,0x1FF	; Obtengo solo los 9 bits que me interesan (índice de la DP)
	
	mov		ecx,cr2		; Guardo en ecx la dirección lineal no presente
	shr		ecx,12		; Obengo indice de la TP
	and		ecx,0x1FF	; Obtengo solo los 9 bits que me interesan (índice de la TP)
	
	; Acá ya tengo los 3 índices de las tablas que necesito luego.
	
	mov		edx, [DirPDPTE + eax * 8]	; Cargo el índice de la PDPT para comprobar la presencia
	and		edx, 0x01					; Verifico si la entrada está presente
	jz		CrearEntradaPDPT			; Si no está presente, creo una nueva entrada PDPT
	
	; Si está presente paso a la DP
	
	mov		edx, [DirPDPTE + eax * 8]	; Lo vuelvo a leer porque lo destruí en la máscara anterior
	and 	edx, 0xFFFFF000				; Me quedo con la parte alta del descriptor y le saco los atributos
	
	mov		esi, [edx + ebx * 8] 		; Cargo la entrada de la DP seleccionada
	and		esi, 0x01					; Verifico si la entrada está presente
	jz		CrearEntradaDP				; Si no está presente, creo una nueva entrada DP
	
	; Si está presente creo una nueva entrada TP	
	
	mov		esi, [edx + ebx * 8]		; Acá voy a crear la entrada TP
	jmp		CrearEntradaTp				; Salto para crear la entrada TP
	
	
CrearEntradaPDPT:

; Nota: NuevaDP está en Sys_Tables. Es el mejor lugar que se me ocurrió para ponerla. A partir de esta dirección
; es donde se comienzan a crear las tablas de DP y TP

	mov		edx,[NuevaPagTab]				; Utilizo a edx para crear la nueva entrada en la PDPT
	add		dword[NuevaPagTab],PG_TAM		; Avanzo 4k para cuando sea necesario una nueva DP no sobreescribir
	
	or		edx,0x01					; Le agrego los permisos al nuevo descriptor de la PDPT
	mov 	[DirPDPTE + eax * 8],edx	; Le agrego el descriptor a la PDPT
	
	and		edx,0xFFFFF000				; Me quedo con la parte alta sin los permisos
	
	mov		eax,DirPDPTE				; Guardo la dirección base de la PDPT en el acumulador
	mov		cr3,eax						; Recargo cr3 y actualizo las tablas de paginación

CrearEntradaDP:

	mov		esi,[NuevaPagTab]			; Utilizo a esi para crear la nueva entrada TP
	add		dword[NuevaPagTab],PG_TAM	; Avanzo 4k para cuando sea necesario una nueva TP no sobreescribir
	
	or		esi,0x03					; Le agrego los permisos al nuevo descriptor de la DP
	mov		[edx + ebx*8],esi			; Le agrego el descriptor a la DP


CrearEntradaTp:

	and		esi,0xFFFFF000				; Me quedo con la parte alta sin los permisos

	mov		[esi + ecx * 8],edi			; Cargo la dirección de la nueva página en la entrada de la TP


	mov		esp,ebp						; Recupero la posición de la pila al momento de iniciar la excepción


	mov		eax,DirPDPTE				; Guardo la dirección base de la PDPT en el acumulador
	mov		cr3,eax						; Recargo cr3 y actualizo las tablas de paginación
	
	pop ebp								; Recupero el ebp pusheado al inicio de la excepción
	popad								; Recupero los registros de uso general
	
	sti									; Habilito las interrupciones
	iret								; Retorno de la excepción


NO_ES_PAG_AUS:
	
	; Si es un problema de permisos, excepción 14 y reset.
	
	call	limpiar_pantalla			; Borro la pantalla
	push	RED_F | INTENSE				; Paso como parámetro el color y intense
	push	0							; Paso como parámetro el número de la fila a escribir
	push	0 							; Paso como parámetro el número de la columna a escribir
	push	msgPagefault				; Paso como parámetro el string a imprimir
	call	print						; Imprimo el mensaje en pantalla
	add		esp,16						; Equivale a cuatro pops consecutivos
	push	0xFFFF0						; Reset al regresar
	
	sti									; Habilito interrupciones
	iret								; Retorno de la excepción al reset

;/* ----------- Fin del archivo ----------- */
