;################################################################################
;#	Tí­tulo: Inicialización 32 bits (Modo Protegido)			 					#
;#																				#
;#	Versión:		1.1									Fecha: 	07/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Inicialización 32 bits (Modo Protegido) - Año: 2015						#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 07/01/2016 | F.POSE | Original									#
;#		1.0 | 29/01/2016 | F.POSE | Agregué llamado de func de carga de tareas.	#
;#		2.0 | 29/01/2016 | F.POSE | init32.asm completo (No modificar)			#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################

BITS 16

;################################################################################
;							Sección: Reset_vector
;################################################################################

GLOBAL Entry

SECTION .reset_vector
	
	Entry:
		cli
		jmp dword _init16_inicio
		ALIGN 16

;################################################################################
;							Sección: Init16
;################################################################################

BITS 16

SECTION .init16


_init16_inicio:

	incbin "init_catedra.bin"

BITS 32

;################################################################################
;							Sección: bssE
;################################################################################

SECTION .bssE

TSS:			resb EstructuraTSS.size ; Reservo espacio para el contexto de cambio de tarea
ContextoIDLE: 	resb Contexto.size		; Reservo espacio para el contexto de tarea IDLE
ContextoTask1: 	resb Contexto.size		; Reservo espacio para el contexto de tarea 1
ContextoTask2: 	resb Contexto.size		; Reservo espacio para el contexto de tarea 2
ContextoTask3: 	resb Contexto.size		; Reservo espacio para el contexto de tarea 3

;################################################################################
;							Sección: init32
;################################################################################

SECTION .init32
	
;################################################################################
;	Inicializo la pila
;################################################################################

; Inicializo la pila

	mov esp, STACK_ADDR + STACK_SIZE ; Inicializo la pila, cargo offset, de ahi voy bajando, maximo 32kb
	
;################################################################################
;	Copio ROM a RAM 
;################################################################################

	mov esi,_sys_tables_start   ; Guardo en esi donde comienza en ROM la sección
	mov edi,_sys_tables			; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx,_sys_tables_tam     ; Guardo en ecx el tamaño de la sección
	rep movsb 					; Copio los datos hasta que ecx se decremente a 0
								
	mov esi,_stack_start		; Guardo en esi donde comienza en ROM la sección
	mov edi,_stack				; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx,_stack_tam			; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0
	
	mov esi, _code_main_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, _code_main			; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov	ecx, _code_main_tam		; Guardo en ecx el tamaño de la sección
	rep	movsb					; Copio los datos hasta que ecx se decremente a 0

	mov esi, _data_start		; Guardo en esi donde comienza en ROM la sección
	mov edi, _data				; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _data_tam			; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0

	mov esi, _bss_start			; Guardo en esi donde comienza en ROM la sección
	mov edi, _bss				; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _bss_tam			; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0
	
	mov esi, _functions_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, functions			; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _functions_tam 	; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0

	mov esi, _DEHandler_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, divisionErrorVMA	; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _DEHandler_tam		; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0

	mov esi, _UDHandler_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, undefinedcodeVMA	; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _UDHandler_tam		; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0

	mov esi, _DFHandler_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, doublefaultVMA		; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _UDHandler_tam		; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0

	mov esi, _GPHandler_start		; Guardo en esi donde comienza en ROM la sección
	mov edi, generalprotectionVMA	; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _GPHandler_tam			; Guardo en ecx el tamaño de la sección
	rep movsb						; Copio los datos hasta que ecx se decremente a 0

	mov esi, _PFHandler_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, pagefaultVMA		; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _PFHandler_tam		; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0

	mov esi, _TimerHandler_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, timerVMA				; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _TimerHandler_tam		; Guardo en ecx el tamaño de la sección
	rep movsb						; Copio los datos hasta que ecx se decremente a 0

	mov esi, _keyboardHandler_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, keyboardVMA			; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _keyboardHandler_tam	; Guardo en ecx el tamaño de la sección
	rep movsb						; Copio los datos hasta que ecx se decremente a 0

	mov esi, _ServicioSistema_start			; Guardo en esi donde comienza en ROM la sección
	mov edi, ServicioSistemaVMA				; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _ServicioSistemaHandler_tam	; Guardo en ecx el tamaño de la sección
	rep movsb								; Copio los datos hasta que ecx se decremente a 0

	mov esi, _PageTable_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, PageTableVMA		; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _PageTable_tam		; Guardo en ecx el tamaño de la sección
	rep movsb					; Copio los datos hasta que ecx se decremente a 0

	mov esi, _Tarea1_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, Tarea1VMA		; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _Tarea1_tam	; Guardo en ecx el tamaño de la sección
	rep movsb				; Copio los datos hasta que ecx se decremente a 0

	mov esi, _Tarea2_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, Tarea2VMA		; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _Tarea2_tam	; Guardo en ecx el tamaño de la sección
	rep movsb				; Copio los datos hasta que ecx se decremente a 0

	mov esi, _Tarea3_start	; Guardo en esi donde comienza en ROM la sección
	mov edi, Tarea3VMA		; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _Tarea3_tam	; Guardo en ecx el tamaño de la sección
	rep movsb				; Copio los datos hasta que ecx se decremente a 0
	
	mov esi, tss1VMA		; Guardo en esi donde comienza en ROM la sección
	mov edi, Tarea3VMA		; Guardo en edi la dirección de destino (RAM) de la sección a copiar.
	mov ecx, _tss1_tam		; Guardo en ecx el tamaño de la sección
	rep movsb				; Copio los datos hasta que ecx se decremente a 0
	
;################################################################################
;	Configuro el Hardware
;################################################################################
	
	call Pic_Reprog		; Programo el PIC
	
	mov al,11111100b 
	out 21h,al
	mov al,20h
	out 20h,al
	in  al,0x60
	
	call Timer_Reprog	; Programo el timer

;################################################################################
;	Inicializo la paginación 
;################################################################################

	call InitializePage			; Inicializo la tabla de paginación (paginacion.asm)
	
;################################################################################
;	Inicializo la tabla de tareas
;################################################################################

	call InitializaTableTask	; Inicializo la tabla de tareas (FuncionesTareas.asm)

;################################################################################
;	Cargo las tareas en la tabla de tareas
;################################################################################

	; Cargo la tarea IDLE - Tarea inicial del sistema
	mov  eax,DirPDPTE		; Dirección donde se va a paginar la tarea
	push eax
	push ContextoIDLE		; Pusheo el contexto de la tarea IDLE
	push PrivPresIDLE		; Pusheo el nivel de privilegios + bit de presencia tarea IDLE
	mov	 eax,PrioridadIdle	; Nivel de prioridad de la tarea IDLE
	push eax				; Pusheo el nivel de prioridad de la tarea IDLE
	call AgregarTarea		; Pagino la tarea, la agrego a la tabla de tareas y 
							; para el caso de la IDLE inicializo la TSS-IA32
	
	; Cargo la tarea 1 - Tarea de hora del sistema
	mov  eax,[NextTask]	; Dirección donde voy a paginar la tarea
	push eax				
	push ContextoTask1		; Pusheo el contexto de la tarea 1
	push PrivilegioUser		; Pusheo el nivel de privilegios de la tarea 1
	mov	 eax,PrioridadMaxima; Nivel de prioridad de la tarea 1
	push eax				; Pusheo el nivel de prioridad de la tarea 1
	call AgregarTarea		; Pagino la tarea, la agrego a la tabla de tareas y 
							; para el caso de la IDLE inicializo la TSS-IA32 	

	; Cargo la tarea 2 - Tarea de fecha del sistema
	mov  eax,[NextTask]	; Dirección donde voy a paginar la tarea
	push eax				
	push ContextoTask2		; Pusheo el contexto de la tarea 1
	push PrivilegioUser		; Pusheo el nivel de privilegios de la tarea 1
	mov	 eax,PrioridadMaxima; Nivel de prioridad de la tarea 1
	push eax				; Pusheo el nivel de prioridad de la tarea 1
	call AgregarTarea		; Pagino la tarea, la agrego a la tabla de tareas y 
							; para el caso de la IDLE inicializo la TSS-IA32 
	
	; Cargo la tarea 3 - Tarea de contador en pantalla
	mov  eax,[NextTask]	; Dirección donde voy a paginar la tarea
	push eax				
	push ContextoTask3		; Pusheo el contexto de la tarea 1
	push PrivilegioUser		; Pusheo el nivel de privilegios de la tarea 1
	mov	 eax,PrioridadMaxima; Nivel de prioridad de la tarea 1
	push eax				; Pusheo el nivel de prioridad de la tarea 1
	call AgregarTarea		; Pagino la tarea, la agrego a la tabla de tareas y 
							; para el caso de la IDLE inicializo la TSS-IA32 	

;################################################################################
;	Cargo lgdt con la GDT de 32 bit (Modo Protegido)
;################################################################################
	
	lgdt [valor_gdtr]	; Cargo la GDT

;################################################################################
;	Cargo IDTR 
;################################################################################

	lidt [valor_idtr] 	; Cargo la IDT

	jmp codsel:_code_main  ;Continuo en main32

;###################################################################
;	Función Inicialización HardWare - Timer
;################################################################################

Timer_Reprog:

	mov al,00110100b 	; PROGRAMACION DEL TIMER TICK
	out 43h,al
	mov ax,11932		; 10ms
	out 40h,al
	mov al,ah
	out 40h,al	
	ret

;################################################################################
;	Función Inicialización HardWare - PIC 1 & 2
;################################################################################

Pic_Reprog:

; Inicialización PIC #1
	mov al,11h			;ICW1: IRQs activas por flanco, Modo cascada, ICW4 Si.	        
	out 20h,al
    mov al,32   		;ICW2: INT base para el PIC N#1 Tipo IRQ0_Base_interrupt     
    out 21h,al
    mov al,04h     		;ICW3: PIC N#1 Master, tiene un Slave conectado a IRQ2 (0000 0100b)
    out 21h,al
    mov al,01h  		;ICW4: Modo No Buffered, Fin de Interrupción Normal, procesador 8086     
    out 21h,al

; Deshabilito las Interrupciones del PIC #1
	mov al,0FFh  		;OCW1: Set o Clear el IMR     
    out 21h,al

; Inicialización PIC #2
	mov al,11h   		 ;ICW1: IRQs activas por flanco, Modo cascada, ICW4 Si.            
    out 0A0h,al
    mov al,40     		 ;ICW2: INT base para el PIC N#1 Tipo IRQ0_Base_interrupt + 8h.  
    out 0A1h,al
    mov al,02h  		 ;ICW3: PIC N#2 Slave, IRQ2 es la línea que envía al Master (010b)     
    out 0A1h,al
    mov al,01h   	     ;ICW4: Modo No Buffered, Fin de Interrupción Normal, procesador 8086
	out 0A1h,al

    ret

;/* ----------- Fin del archivo ----------- */
