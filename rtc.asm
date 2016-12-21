;--------------------------------------------------------------------------------
;|	Título: Control RTC															|
;|	Versión:		1.0						Fecha: 	16/07/2009					|
;|	Autor: 			D.GARCIA				Modelo:	IA-32 (32 bits)				|
;|	------------------------------------------------------------------------	|
;|	Descripción:																|
;|		Rutina para manejo de servicios del Reloj de Tiempo Real				|
;|	------------------------------------------------------------------------	|
;|	Recibe:																		|
;|		AL = 0 Subfuncion fecha													|
;|		AL = 1 Subfuncion hora													|
;|																				|
;|	Retorna:																	|
;|		Fecha:																	|
;|			DH = Año  															|
;|			DL = Mes		  													|	
;|			AH = Dia   															|
;|			AL = Dia de la semana												|
;|		Hora:																	|
;|			DL = Hora		  													|	
;|			AH = Minutos														|
;|			AL = Segundos														|
;|			CL = 0:OK  N:Codigo de error										|
;|	------------------------------------------------------------------------	|
;|	Revisiones:																	|
;|		1.0 | 15/02/2010 | D.GARCIA | Original									|
;--------------------------------------------------------------------------------
RTC_Service:
	cmp		al, 0
	je		Fecha				; Servicio de Fecha
	cmp		al, 1
	je		Hora				; Servicio de Hora
	jmp		RTC_Err_Exit		; Funcion no valida, salida con error
	
RTC_Err_Exit:
	mov		cl, 1				; Codigo de error. Subfuncion invalida
	ret
RTC_Exit:
	mov		cl, 0				; Codigo de error. OK
	ret



;--------------------------------------------------------------------------------
;|	Título: Auxiliar RTC														|
;|	Versión:		1.0						Fecha: 	16/07/2009					|
;|	Autor: 			D.GARCIA				Modelo:	IA-32 (32 bits)				|
;|	------------------------------------------------------------------------	|
;|	Descripción:																|
;|		Subfuncion para obtener la hora del sistema desde el RTC				|
;|	------------------------------------------------------------------------	|
;|	Recibe:																		|
;|		Nada																	|
;|	Retorna:																	|
;|		Nada																	|
;|	------------------------------------------------------------------------	|
;|	Revisiones:																	|
;|		1.0 | 15/02/2010 | D.GARCIA | Original									|
;--------------------------------------------------------------------------------
Hora:
	call	RTC_disponible		; asegura que no estÃ© actualizandose el RTC
	mov		al, 4
	out		70h, al				; Selecciona Registro de Hora
	in		al, 71h				; lee hora
	mov		dl, al

	mov		al, 2
	out		70h, al				; Selecciona Registro de Minutos
	in		al, 71h				; lee minutos
	mov		ah, al

	xor		al, al
	out		70h, al				; Selecciona Registro de Segundos
	in		al, 71h				; lee minutos

	jmp		RTC_Exit


;--------------------------------------------------------------------------------
;|	Título: Auxiliar RTC														|
;|	Versión:		1.0						Fecha: 	16/07/2009					|
;|	Autor: 			D.GARCIA				Modelo:	IA-32 (32 bits)				|
;|	------------------------------------------------------------------------	|
;|	Descripción:																|
;|		Subfuncion para obtener la fecha del sistema desde el RTC				|
;|	------------------------------------------------------------------------	|
;|	Recibe:																		|
;|		Nada																	|
;|	Retorna:																	|
;|		Nada																	|
;|	------------------------------------------------------------------------	|
;|	Revisiones:																	|
;|		1.0 | 15/02/2010 | D.GARCIA | Original									|
;--------------------------------------------------------------------------------
Fecha:
	call	RTC_disponible		; asegura que no estÃ© 
								; actualizandose el RTC
	mov		al, 9
	out		70h, al				; Selecciona Registro de AÃ±o
	in		al, 71h				; lee aÃ±o
	mov		dh, al

	mov		al, 8
	out		70h, al				; Selecciona Registro de Mes
	in		al, 71h				; lee mes
	mov		dl, al

	mov		al, 7
	out		70h, al				; Selecciona Registro de Fecha
	in		al, 71h				; lee Fecha del mes
	mov		ah, al

	mov		al, 6
	out		70h, al				; Selecciona Registro de DÃ­a 
	in		al, 71h				; lee dÃ­a de la semana

	jmp		RTC_Exit

	
;--------------------------------------------------------------------------------
;|	Título: Auxiliar RTC														|
;|	Versión:		1.0						Fecha: 	16/07/2009					|
;|	Autor: 			D.GARCIA				Modelo:	IA-32 (32 bits)				|
;|	------------------------------------------------------------------------	|
;|	Descripción:																|
;| 		Verifica en el Status Register A que el RTC no esta actualizando 		|
;|		fecha y hora.															|
;| 		Retorna cuando el RTC esta disponible									|
;|	------------------------------------------------------------------------	|
;|	Recibe:																		|
;|		Nada																	|
;|	Retorna:																	|
;|		Nada																	|
;|	------------------------------------------------------------------------	|
;|	Revisiones:																	|
;|		1.0 | 15/02/2010 | D.GARCIA | Original									|
;--------------------------------------------------------------------------------
RTC_disponible:
	mov		al, 0Ah
	out		70h, al				; Selecciona registro de status A
wait_for_free:
	in		al, 71h				; lee Status
	test	al, 80h
	jnz		wait_for_free
	
	ret
	
;/* ----------- Fin del archivo ----------- */
