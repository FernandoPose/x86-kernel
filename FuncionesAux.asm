;################################################################################
;#	Tí­tulo: Funciones Auxiliares - Trabajo Práctico			 					#
;#																				#
;#	Versión:		1.1									Fecha: 	10/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		FUnciones auxiliares creadas para el trabajo práctico - Año: 2015		#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 10/01/2016 | F.POSE | Original									#
;#		2.0 | 11/01/2016 | F.POSE | Agregué la función print y clear			#
;#		3.0 | 11/01/2016 | F.POSE | Agregué: Obtener: Fecha, Hora y contador	#
;#		3.0 | 30/01/2016 | F.POSE | FuncionesAux.asm completo (No modificar)	#
;#		6.0 | 12/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################

BITS 32

;################################################################################
;							Sección: functions
;################################################################################

SECTION .functions

;################################################################################
;	Función: Imprimir en pantalla
;################################################################################

;void print (char *string_ptr, char columna, char fila, char color); columna y fila minima = 1

print:           
	
	  push		ebp			; Guado ebp
	  mov		ebp, esp	; Cargo el valor de esp por si me interrupen	  
	  push		eax			; Resguardo eax para retornar de la función
	  push		ebx			; Resguardo ebx para retornar de la función
	  push		edi			; Resguardo edi para retornar de la función
	  push		edx			; Resguardo edx para retornar de la función
	
	cld								; Incremento el registro EDI

	mov	eax, MAX_COLUMNAS_PANTALLA	; Cargo la cantidad máxima de columnas en EAX
	shl	eax, 1						; Cada caracter son 2 bytes
	mul	dword[ebp+0x10] 			; Multiplico a EAX por la fila obtenida de los argumentos
	mov	edi, eax					; Guardo en EDI la posición del caracter
	mov	eax, dword[ebp+0x0C] 		; Obtengo la columna
	shl	eax, 1						; Cada caracter son 2 bytes
	add	edi, eax					; Agrego el offset por la columna
	add	edi, VGA_RAM_VIRTUAL		; Le sumo la dirección de la VGA

	mov	ebx, dword[ebp+0x14] 		; Obtengo el color pasado como argumento
	shl	ebx, 8				 		; Guardo el color en el byte alto
	mov	esi, dword[ebp+0x08] 		; Obtengo el puntero a char

loop_print:

	xor	eax, eax
	lodsb 						; Guardo el caracter en AL
	cmp   	al, CARACTER_NULO	; Lo comparo con el NULL
	je	fin_print				; Si es el NULL es porque termino.
	add	eax, ebx			 	; Le agrego el color
	mov	[edi], eax				; Imprimo en pantalla
	add	edi, 2					; Aumento el cursor
	jmp	loop_print				; Continuo el loop

fin_print:

	  pop		edx		; Recupero el edx
	  pop		edi	  	; Recupero el edi
	  pop		ebx		; Recupero el ebx
	  pop		eax		; Recupero el eax
	  pop		ebp		; Recupero el ebp

ret						; Retorno de la función

;################################################################################
;	Función: Limpiar Pantalla
;################################################################################

limpiar_pantalla:

	push ebp
	mov	 ebp, esp	  	  
	push eax
	push ecx
	push edi
	mov	 ax,  CARACTER_NULO			; Cargo en ax el valor del caracter limpio
	mov	 edi, VGA_RAM_VIRTUAL		; Coloco el inicio de la memoria de video
	mov	 ecx, TAM_VIDEO_CARACTERES	; Coloco el tamaño en words de la memoria de video

ClearAlmacenado:

	stosw							; Itero cargando un word en la memoria de video (ver apunte - sevilla)
	loop ClearAlmacenado	  
	pop	 edi				; Recupero el registro edi
	pop	 ecx				; Recupero el registro ecx
	pop	 eax	  			; Recupero el registro eax
	pop	 ebp				
	  
ret				

;################################################################################
;	Función: Obtener Fecha
;################################################################################	

; La función devuelve un string con el contenido de la fecha armado

ObtenerFecha:

	call RTC_Service	; Función brindada por la cátedra (rtc.asm)
	;add	esp,4		; Compenso la pila para que no esté desbalanceada
	cmp	cl,0			; Si es igual a 0 el cl entonces el dato es correcto
	jne	ErrorFuncionRTC	; Si no es igual a 0 el cl entonces el dato es incorrecto
	xor ebx,ebx			; Limpio el registro ebx (lo pongo todo en cero)
 	
; Reacomodo la fecha del sistema

; Reacomodo el día del sistema perteneciente a la fecha
 	mov	bl,ah							; Obtengo en ah el día de la función rtc_service
	shr	bl,4							; Shifteo para obtener los 4 bits mas significativos correspondientes a las decenas
	add	bl,0x30							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgFecha+DiaDecena],bl 	; Incluyo en el texto de Fecha las decenas del día
	mov	bl,ah							; Obtengo en ah el día de la función rtc_service
	and bl,0x0F							; Enmascaro para quedarme con los 4 bits menos significativos correspondientes a las unidades
	add	bl,0x30							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgFecha+DiaUnidad],bl		; Incluyo en el texto Fecha las unidades del día

; Reacomodo el mes del sistema perteneciente a la fecha
	mov	bl,dl							; Obtengo en dl el mes de la función rtc_service
	shr	bl,4							; Shifteo para obtener los 4 bits más significativos correspondientes a las decenas
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgFecha+MesDecena],bl 	; Incluyo en el texto de Fecha las decenas del mes
	mov	bl,dl							; Obtengo en bl el me de la función rtc_service
	and bl,0x0F							; Enmascaro para quedarme con los 4 bits menos significativos correspondientes a las unidades
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgFecha+MesUnidad],bl		; Incluyo en el texto Fecha las unidades del mes

; Reacomodo el año del sistema perteneciente a la fecha
	mov	bl,dh							; Obtengo en el bl el año de la función rtc_service
	shr	bl,4							; Shifteo para obtener los 4 bits más significativos correspondientes a las decenas
	add	bl,30h							; Le sumo el offsetde ASCII correspondiente para obtener el valor numérico
	mov	byte[msgFecha+AnoDecena],bl 	; Incluyo en el texto de Fecha las decenas del año
	mov	bl,dh							; Obtengo en bl el año de la función rtc_service
	and bl,0x0F							; Enmascaro para quedarme con los 4 bits menos significativos correspondientes a las unidades
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgFecha+AnoUnidad],bl		; Incluyo en el texto Fecha las unidades del año

; Reacomodo el fecha del sistema perteneciente a la fecha
	mov	bl,al							; Obtengo en el bl el día de la semana de la función rtc_service
	shr	bl,4							; Shifteo para obtener los 4 bits más significativos correspondientes a las decenas
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgFecha+FechaDecena],bl 	; Incluyo en el texto de Fecha las decenas del día de la semana
	mov	bl,al							; Obtengo en bl el día de la semana de la función rtc_service
	and bl,0x0F							; Enmascaro para quedarme con los 4 bits menos significativos correspondientes a las unidades
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgFecha+FechaUnidad],bl	; Incluyo en el texto de Fecha las unidades del día de la semana
		
	ret

;################################################################################
;	Función: Obtener Hora
;################################################################################

; La función devuelve un string con el contenido de la hora armado

ObtengoHora:

	call RTC_Service		; Función brindada por la cátedra (rtc.asm)
	cmp	cl,0				; Si es igual a 0 el cl entonces el dato es correcto
	jne	ErrorFuncionRTC		; Si no es igual a 0 el cl entonces el dato es incorrecto
	xor ebx,ebx				; Limpio el registro ebx (lo pongo todo en cero)

; Reacomodo la hora del sistema

; Reacomodo las horas del sistema perteneciente a la hora
	mov	bl,dl							; Obtengo en bl la hora de la función rtc_service
	shr	bl,4							; Shifteo para obtener los 4 bits más significativos correspondientes a las decenas
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgHora+ HorasDecena],bl 	; Incluyo en el texto de Hora las decenas de la hora
	mov	bl,dl							; Obtengo en bl la hora de la función rtc_service
	and bl,0x0F							; Enmascaro para quedarme con los 4 bits menos significativos correspondientes a las unidades
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgHora+ HorasUnidad],bl	; Incluyo en el texto Hora las unidades de la hora

; Reacomodo los minutos del sistema perteneciente a la hora
	mov	bl,ah							; Obtengo en bl los minutos de la función rtc_service
	shr	bl,4							; Shifteo para obtener los 4 bits más significativos correspondientes a las decenas
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgHora+ MinutosDecena],bl ; Incluyo en el texto de Hora las decenas de los minutos
	mov	bl,ah							; Obengo en bl los minutos de la función rtc_service
	and bl,0x0F							; Enmascaro para quedarme con los 4 bits menos significativos correspondientes a las unidades
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgHora+ MinutosUnidad],bl	; Incluyo en el texto Hora las unidades de los minutos

; Reacomodo los segundos del sistema perteneciente a la hora
	mov	bl,al							; Obtengo en bl los segundos de la función rtc_service
	shr	bl,4							; Shifteo para obtener los 4 bits más significativos correspondientes a las decenas
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgHora+ SegundosDecena],bl; Incluyo en el texto de Hora las decenas de los segundos
	mov	bl,al							; Obtengo en bl los segundos de la función rtc_service
	and bl,0x0F							; Enmascaro para quedarme con los 4 bits menos signifiativos correspondientes a las unidades
	add	bl,30h							; Le sumo el offset de ASCII correspondiente para obtener el valor numérico
	mov	byte[msgHora+ SegundosUnidad],bl; Incluyo en el texto Hora las unidades de los segundos
	
	ret

;################################################################################
;	Función: Obtener Contador
;################################################################################	
	
ObtengoContador:

	mov	ecx,8
	mov	edi,msgContador+TextoEspacio+8 ; Digito menos significativo

IncrementoContador:	

	mov al, byte[edi]			; Cargo en el acumulador el dígito menos significativo
	inc al						; Incremento el dígito
	cmp al,'9'					; Lo comparo contra el máximo valor a tomar
	jbe DigitoOk				; Si es válido. Rango: 0 - 9 => Dígito OK
	mov al,'0'					; De lo contrario le pongo 0 y paso al siguiente dígito
	mov byte[edi],al			; Le asigno valor 0 al dígito
	dec edi						; Decremento al siguiente dígito
	loop IncrementoContador		; Vuevlo para incrementar el siguiente dígito menos significativo
	jmp MostrarContador			; Muestro la cuenta

DigitoOk:

	mov byte[edi],al			; Si el dígito es válido lo cargo al contador y muestro cuenta

MostrarContador:
	
	ret
	
;/* ----------- Fin del archivo ----------- */
