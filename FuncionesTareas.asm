;################################################################################
;#	Tí­tulo: Funciones Auxiliares de tareas - Trabajo Práctico					#
;#																				#
;#	Versión:		1.1									Fecha: 	30/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Funciones auxiliares creadas para el trabajo práctico - Año: 2015		#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 30/01/2016 | F.POSE | Original									#
;#		1.1 | 30/01/2016 | F.POSE | Agregué inicializar tabla y inicializar IDLE#
;#		1.2 | 31/01/2016 | F.POSE | Agregué función de load y save de contexto	#
;#		2.0 | 01/01/2016 | F.POSE | Agregué función decrementar tick			#
;#		2.1 | 01/01/2016 | F.POSE | Agregué función de carga de contexto ambas	#
;#		2.2 | 03/01/2016 | F.POSE | Agregué función agregar tarea a la tabla	#
;#		2.3 | 03/01/2016 | F.POSE | Agregué función agregar tarea 				#
;#		2.4 | 04/01/2016 | F.POSE | Agregué función que inicializa la pila		#
;#		2.5 | 04/01/2016 | F.POSE | Empecé la función de paginar tarea			#
;#		3.0 | 08/01/2016 | F.POSE | FuncionesTareas.asm completo (No modificar)	#
;#		5.0 | 10/01/2016 | F.POSE | Arregle funciones de agregado carga y salv.	#
;#		5.1 | 11/01/2016 | F.POSE | Arregle carga de la tss_ini.				#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################

BITS 32	

;################################################################################
;							Sección: dataE
;################################################################################

SECTION .dataE

msgAgregarTareaError: 		db "¡ALTO! Error al paginar la tarea en la dirección requerida..", NULL

;################################################################################
;							Sección: functions
;################################################################################

SECTION .functions

;################################################################################
;	Función: Función que pagina las tareas
;################################################################################
; Info:		La función crea un nuevo árbol de paginación para la nueva tarea (PDTP, DTP, TP)
;			La función pagina además:
;										- Código de la tarea
;										- Datos inicialiados
;										- Datos no inicializados
;										- Pila de privilegios: Usuario y Kernel
;										- Funciones de las tareas
;										- Funciones auxilieares
;										- Memoria compartida 
;										- Excepciones e interrupciones
;										- Código de kernel
;										- System Tables
;										- Main32
; Retorna:	En el registro EAX la dirección de la PDTP creado
; Recibe:	Recibo por registro (EAX) la dirección base de la tarea a paginar
; Nota: 	Para las tareas la dirección lineal coincide, la dirección física no coincide

;********************************************************************************
;					Estructura final de las tablas creadas
;********************************************************************************

; Primer nivel (Tabla de punteros a directorio de páginas - PDPT)
; Contenido de descriptores:
;							DTP (Directorio de tabla de páginas)

; Segundo nivel (Directorio de tabla de páginas - DTP)
; Contenido de descriptores:
;							TP1 (Tabla de página 1)
;							TP2 (Tabla de página 2)

; Tercer nivel (Tabla de páginas - TPx)

; Tabla de página - TP1
; Tabla de pagina - TP2
							
PaginarTarea:					
	
; Armo el árbol de paginación a partir de la dirección de la TP2 creada anteriormente (0x00294000)			
	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)		
	mov ecx,ebx						; Guardo en ecx el valor de ebx (para realizar modificaciones sin perder
									; el valor de ebx)
	
; Creo la entrada de la DTPT a la DTP		
	add ecx,PG_TAM					; Incremento ecx apuntando al comiendo de mi DTP
	mov [ebx],ecx					; Guardo en la primer entrada de mi nueva PDPT el valor del nuevo DTP
	add dword[ebx],PermisosDTP		; Pongo el DTP presente (Primer bit del descriptor) 
	mov	dword[ebx+4], 0x00000000	; Parte alta del registro 0's
		
; Creo la entrada de DTP a TP1
	add ebx,PG_TAM					; Apunto a la base de la DTP creada
	add ecx,PG_TAM					; Incremento ecx apuntando al comienzo de la TP1
	mov [ebx],ecx					; Guardo en la primer entrada de mi nueva DTP el valor de la nueva TP1
	add dword[ebx],PermisosUsuario 	; Pongo la nueva TP1 presente con los permisos de usuario
	mov	dword[ebx+4], 0x00000000	; Parte alta del registro 0's
	
; Creo la entrada de DTP a TP2
	add ebx,0x08					; Apunto a la segunda entrada (segundo descriptor) de la DTP
	add ecx,PG_TAM					; Apunto con ecx a mi nueva TP2
	mov	[ebx],ecx					; Guardo en la segunda entrada de mi nueva DTP el valor de la nueva TP2
	add dword[ebx],PermisosUsuario	; Pongo la nueva TP2 presente con los permisos de usuario
	mov	dword[ebx+4], 0x00000000	; Parte alta del registro 0's
	
; Creo las páginas de la nueva TP1

	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x2000					; Apunto a mi nueva TP1
	mov ecx,0x04					; Le asigno a ecx la cantidad de páginas por tarea a tener de código
	add ebx,0x880					; offset de la dirección lineal de la tarea

loopPagTask:

	mov [ebx],eax					; Cargo la dirección física donde se encuentra el código de la tarea - 0x00AX0000
	add dword[ebx],PermisosUsuario	; Pongo la página presente con los permisos de usuario
	mov	dword[ebx+4], 0x00000000	; Parte alta del registro 0's
	add ebx,0x08					; Paso al siguiente descriptor de mi nueva TP
	add eax,PG_TAM					; Paso a la siguiente página de código
	
	loop loopPagTask				; Continuo creando las páginas de código de tarea "x"
									; creo 4 páginas. 

PaginoTP1:
	
; Armo el descriptor de entrada de la TP de la pila de privilegio 0 (Kernel)
; STACK_ADDRL_KERNEL	0x00124000
	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x2000					; Apunto a mi nueva TP1
	add ebx,0x920					; Le agrego el offset a la dirección de la pila de privilegio 0 (Kernel) - 0x00124000
	mov [ebx],eax					; En eax acá tengo la dirección de la pila de privilegio 0 (kernel) - 0x00AX4000
	add dword[ebx],PermisosKernel	; Pongo la página presente con los permisos de Kernel
	mov dword[ebx+4], 0x00000000	; Parte alta del registro 0's
	add ebx,0x08					; Paso al siguiente descriptor de mi nueva TP
	add eax,PG_TAM					; Paso a la siguiente página de código

; Armo el descriptor de entrada de la TP de la pila de privilegio 3 (Usuario)	
;STACK_ADDRL_USER	0x00121000
	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x2000					; Apunto a mi nueva TP1
	add ebx,0x908					; Le agrego el offset a la dirección de la pila de privilegio 3 (Usuario) - 0x00121000
	mov [ebx],eax					; En eax acá tengo la dirección de la pila de privilegio 3 (Usuario) - 0x00AX5000
	add dword[ebx],PermisosUsuario	; Pongo la página presente con los permisos de usuario
	mov dword[ebx + 4],0x00000000	; Parte alta del registro 0's
	add ebx,0x08					; Paso al siguiente descriptor de mi nueva TP
	add eax,PG_TAM					; Paso a la siguiente página de código
									
; 0x000F4000: sys_tables ->  0x00100000 (0x100) 	
	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x2000					; Apunto a mi nueva TP1
	add ebx,0x800					; Sumo el offset del descriptor de la TP1
	mov dword[ebx],_sys_tables		; Cargo la dirección base de la sys_table
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .code_main -> 0x00150000 (0x150) 	
	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x2000					; Apunto a mi nueva TP1
	add ebx,0xA80					; Sumo el offset del descriptor de la TP1
	mov dword[ebx],Pag1CodeMain		; Cargo la dirección base de la code_main
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .tss1  -> 0x00190000 (0x190)
	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x2000					; Apunto a mi nueva TP1
	add ebx,0xC80					; Sumo el offset del descriptor de la TP1
	mov dword[ebx],PagTss1			; Cargo la dirección base de la tss
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's			
		
PaginoTP2:
;#######TODOOO : Error de Paginacion !!
	mov eax,[PntNewPage]			; Guardo en eax el puntero a las tabalas de paginación (0x00294000)
	add eax,0x3000					; Apunto a mi nueva Tabla de paginación 2 (TP2)
	mov ebx,[PntNewPage]			; Cargo en ebx la dirección a las tablas de paginación (0x00294000) - Nueva PDTP
	shr ebx,12						; Descarto los primeros 3 nibbles ( 12 bits)
	and ebx,0x1FF					; Me quedo con el offset dentro de la nueva TP (Tabla de paginación)
	shl ebx,3						; Calculo la cantidad de descriptores que es mi offset (multiplico por 8)
	add eax,ebx						; Guardo en eax TP2 + offset generado por el PDT
	mov ebx,[PntNewPage]			; Cargo la dirección del PDTP
	mov ebx,PermisosUsuario			; Página presente + permisos de usuario
	mov [eax],ebx					; Pagino dentro de mi TP2 a la página del PDTP
	add eax,0x08					; Paso al siguiente descriptor
	add ebx,0x1000					; Apunto a mi nuevo DTP
	mov [eax],ebx					; Pagino dentro de mi TP2 la página de DTP
	add eax,0x08					; Paso al siguiente descriptor
	add ebx,0x1000					; Apunto a mi nueva TP1
	mov [eax],ebx					; Pagino dentro de mi TP2 la página de TP1
	add eax,0x08					; Paso al siguiente descriptor
	add ebx,0x1000					; Apunto a mi nueva TP2
	mov [eax],ebx					; Pagino dentro de mi TP2 la página de TP2

; Páginas: .dataE -> 0x00200000 (0x200)
	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)
	add ebx,0x3000					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1Data			; Cargo la dirección base de Data
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .bssE -> 0x00210000 (0x210)
	mov ebx,[PntNewPage]			; Guardo en ebx el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x80					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1Bss			; Cargo la dirección base de Bss
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's
	
; Páginas: .function -> 0x00230000 (0x230)
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x180					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1Function		; Cargo la dirección base de funcion
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .DEHandler -> 0x00250000 (0x250) 	
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x280					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1DeHandler	; Cargo la dirección base de DeHandler
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		

; Páginas: .UDHandler -> 0x00251000 (0x251) 
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x288					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1UdHandler	; Cargo la dirección base de dHandler
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .DFHandler -> 0x00252000 (0x252) 
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x290					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1DfHandler	; Cargo la dirección base de DfHandler
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .GPHandler ->  0x00253000 (0x253) 
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x298					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1GpHandler	; Cargo la dirección base de GpHandler
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .PFHandler -> 0x00254000 (0x254)
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x2A0					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1PfHandler	; Cargo la dirección base de PfHandler
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .TimerHandler -> 0x00270000 (0x270)
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x380					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1Timer		; Cargo la dirección base de Timer
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .keyboardHandler -> 0x00271000 (0x271) 
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x388					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1Keyboard		; Cargo la dirección base de Keyboard
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Páginas: .ServicioSistema -> 0x00272000 (0x272) 
	mov ebx,[PntNewPage]				; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000						; Apunto a mi nueva TP2
	add ebx,0x390						; Sumo el offset del descriptor de la TP2
	mov dword[ebx],Pag1ServicioSistema	; Cargo la dirección base de ServicioSistema
	add dword[ebx],PermisosKernel		; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000			; Parte alta del registro 0's
	
; Páginas: Buffer de video -> 0x00280000 
	mov ebx,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add ebx,0x3000					; Apunto a mi nueva TP2
	add ebx,0x400					; Sumo el offset del descriptor de la TP2
	mov dword[ebx],VGA_RAM			; Cargo la dirección base de VGA_RAM
	add dword[ebx],PermisosKernel	; Le agrego los permisos de Kernel
	mov dword[ebx+4],0x00000000		; Parte alta del registro 0's

; Actualizo PntNewPage (para próxima paginación de tarea) y guardo en eax la nueva PDTP
	mov eax,[PntNewPage]			; Guardo en eax el puntero a las tablas de paginación (0x00294000)	
	add eax,0x4000					; Definí un nuevo PDTP,un DTP y dos TP (equivalente a 4 páginas nuevas)
	mov dword[PntNewPage],eax		; Actualizo PntNewPage para la próxima tarea
	sub eax,0x4000					; Guardo en eax la dirección de la nueva PDTP
	
	ret								; Vuelvo al programa

;################################################################################
;	Función: Inicialización de la TSS-IA32
;################################################################################

; Info:			La función inicializa la estructura TSS-IA32 para todas las tareas
; Retorna:		Nada
; Argumentos:	Nada

InitializaTSS:

	mov dword[ebx + EstructuraTSS.reg_ESP0],(STACK_ADDR + STACK_SIZE)	; Puntero al final de la pila IDLE de privilegio 0 (Kernel)
	mov dword[ebx + EstructuraTSS.reg_SS0],datsel						; Cargo el selector de pila SS de privilegio 0 (Kernel)
	mov dword[ebx + EstructuraTSS.reg_EIP],InicioTareaIdle				; Puntero al inicio de la tarea IDLE 
	mov dword[ebx + EstructuraTSS.reg_EFLAGS],0x202						; Cargo flags de interrupción de EFLAGS
	mov dword[ebx + EstructuraTSS.reg_CR3],DirPDPTE						; Cargo la dirección de la PDPT (CR3)
	mov dword[ebx + EstructuraTSS.reg_ESP],(STACK_ADDR + STACK_SIZE)	; Puntero al final de la pila IDLE de privilegio 3 (Usuario)
	mov dword[ebx + EstructuraTSS.reg_ES],datsel						; Cargo el selector extra de datos ES de privilegio 0 (Kernel)
	mov dword[ebx + EstructuraTSS.reg_CS],codsel						; Cargo el selector de codigo CS de privilegio 0 (Kernel)
	mov dword[ebx + EstructuraTSS.reg_SS],datsel						; Cargo el selector de pila SS de privilegio 0 (Kernel)
	mov dword[ebx + EstructuraTSS.reg_DS],datsel						; Cargo el selector de datos DS de privilegio 0 (Kernel)
	mov dword[ebx + EstructuraTSS.reg_FS],datsel						; Cargo el selector extra de datos FS de privilegio 0 (Kernel)
	mov dword[ebx + EstructuraTSS.reg_GS],datsel						; Cargo el selector extra de datos GS de privilegio 0 (Kernel)
	
	; Realizo la carga del descriptor de la TSS-IA32 (ver manual de INTEL - figure 7.4 - Format of tss and ldt descriptor)
	mov	eax,ebx				; Cargo el puntero de la tss_ini
	mov	ebx,edx				; Cargo el puntero del selector de TSS-IA32
	add 	ebx,0x100000	; Me posiciono en la dirección donde tengo el selector en la GDT
	mov	[ebx + 2],ax		; Cargo la parte baja de la dirección tss_ini en el selector (o:15)
	shr	eax,16				; Apunto a los 16 bits más significativos (en la parte baja de eax)
	mov	[ebx + 4],al		; Cargo la parte baja de la parte alta de la dirección tss_ini en el selector (16_23)
	mov	[ebx + 7],ah		; Cargo la parte alta de la parte alta de la dirección tss_ini en el selector (24-31)
	
	ret						; Retorno de la función

;################################################################################
;	Función: Agrega tarea al sistema
;################################################################################
; Info:		Pagina y carga en la lista de tareas la tarea en cuestión. Si es la IDLE además carga la TSS-IA32
; Retorna:	Nada
; Recibe:	Por pila: Dir.Física de la tarea - Contexto - N. privilegio - N. prioridad 
; Orden de pila al entrar a la función:
;										Dirección física de la tarea	+14
;										Contexto						+10
;										N. de Privilegio				+0C
;										N. Prioridad					+08
;										ip								+04

AgregarTarea:

	push ebp				; Guardo ebp
	mov	 ebp,esp			; Cargo el valor de esp por si me interrumpen
	cld						

	; Pila al momento:
	;		Dirección física de la tarea	+14
	;		Contexto						+10
	;		N. de Privilegio				+0C
	;		N. Prioridad					+08
	;		ip								+04		
	;		ebp								+00

	mov	eax,[ebp + 0x14]		; Cargo la posición de la tarea a paginar (Dirección física de la tarea)	
	mov	ecx,[ebp + 0x0C]		; Cargo el nivel de privilegio de la tarea a agregar
	cmp	ecx,PrivPresIDLE		; Verifico si la tarea a agregar se trata de la tarea IDLE
	je	TareaInicial			; Si es la tarea inicial, inicializo la TSS-IA32
								; La tarea ya está en tabla y paginada
								; Se agrega en la tabla en la función InitTablaTarea						
	call PaginarTarea			; Si no es la IDLE -> Pagino la tarea en la dirección de memoria requerida
						
	; Agrego la tabla paginada a la tabla de tareas del sistema
	push dword[ebp + 0x10]		; Pusheo en la pila el contexto de la tarea a enlistar
	push eax					; Registro de control CR3 obtenido como parámetro de la función
								; Paginación: PaginarTarea
	push dword[ebp + 0x08]		; Pusheo el nivel de prioridad
	call AgregarTareaTabla		; Agrego la tarea a la tabla de tareas
	
	; Cargo el contexto de la tarea en la tarea cargada en la tabla de tareas del sistema
	cmp	edx,1					; Verifico si el agrego de la tarea se realizo con éxito
	mov	ebx,dword[ebp +0x10]	; Pusheo el contexto de la tarea a inicializar el contexto		
	call CargarContextoTarea	; Cargo el contexto de la tarea nueva en la lista de tareas
	
	; Guardo la dirección de NextTask - Próximo agregado de tareas (Ubicación)
	; Guardo la dirección de LastTask - Último agregado de tarea
	mov	eax,dword[NextTask]		; Guardo en el acumulador la dirección donde se encuentra la tarea cargada
	mov	dword[LastTask],eax		; Le cargo a LastTask la última dirección paginada
	
	; Cargo próxima dirección a paginar la tarea siguiente
	add eax,OffsetPagTar		; Sumo el offset (0x10000) correspondiente a la próxima tarea a agregar
	mov	dword[NextTask],eax		; Guardo el valor de la próxima dirección de tarea en NextTask
	
	; Inizializo la pila de la tarea
	mov	eax,[ebp + 0x14]		; Cargo la dirección en la cual se pagina la tarea (0x00Ax0000)
								; Nota: No lo saqué del eax dado que lo modifiqué sumando el offset de próxima tarea
	call InitPilaTarea			; Inicializo la pila de la tarea enlistada
	inc byte[CantTask]			; Incremento la cantidad de tareas que hay en la lista de tareas del sistema (declarada en main32.asm)
	jmp	FinAgregarTarea			; Ya paginé, inicialicé la tarea y la pila, me voy!
	
TareaInicial:

	; Si la tarea a enlistar es la tarea inicial, ya está enlistada -> Cargo contexto e inicializo TSS-IA32
	mov ebx,TSS					; Guardo en ebx el puntero a la TSS-IA32 (única en cambio manual de tareas)
	mov	edx,tss_ini				; Guardo en edx el selector de TSS-IA32 (ver: system_tables.asm)
	
	; Inicializo la TSS-IA32
	mov	ecx,[ebp + 0x0C]		; Cargo el nivel de privilegio de la tarea inicial
	call InitializaTSS			; Inicializo la TSS-IA32
	
	; Cargo el contexto de la tarea IDLE
	mov	ebx,dword[ebp +0x10]	; Cargo el contexto de la tarea en ebx
	call CargarContextoInit		; Inicializo el contexto de la tarea inicial IDLE

	inc byte[CantTask]			; Incremento la cantidad de tareas que hay en la lista de tareas del sistema (Ver: Main32.asm)
	
FinAgregarTarea:

	; Si no hubo problemas termino el agregado de tareas lo mas bien!
	mov	esp,ebp					; Cargo en esp la dirección apuntada por untero a base
	pop ebp						; Recupero la posición del ebp
	mov	ebx,dword[esp]			; Obtengo el valor de IP (Dirección de retorno)
	mov	dword[esp + 0x14],ebx	; Guardo el valor de IP arriba de todo en la pila
	add esp,0x14				; Apunto el esp, limpiando la pila (Pusheos que ya no necesito en el retorno)
		
	ret							; Retorno de la función
	
AgregarTareaError:

	; Si es un problema de permisos, excepción 14 y reset
	push	BLUE_F | INTENSE		; Paso como parámetro el color y intense
	push	0						; Paso como parámetro el número de la fila a escribir
	push	0 						; Paso como parámetro el número de la columna a escribir
	push	msgAgregarTareaError	; Paso como parámetro el string a imprimir
	call	print					; Imprimo el mensaje en pantalla
 	jmp	0xFFFF0						; Reseteo el procesador
 	
 	ret								; Retorno de la función

;################################################################################
;	Función: Agrega tarea tabla
;################################################################################

; Info:		Agrega al listado de tareas la tarea con su prioridad
; Retorna:	Por registro edx: Si pudo agregar la tarea: 0	Si no pudo agregar la tarea: 1
; Recibe:	Por pila: CR3 - Prioridad de la tarea - TicksSleep
;				> CR3:        Puntero al directorio de la tabla de paginación de la tarea
;				> Prioridad:  Prioridad que tiene la tarea a insertar en la tabla de tareas
;				> TicksSleep: Cantidad de ticks que le queda de sleep: 1 tick = 1 INT_TIMER (10mS)
; Nota: 	STRUC TareaTabla:   IdCr3|Prioridad|TSleep|Contexto
; Orden de pila al entrar a la función:
;										Contexto	+10
;										CR3			+0C
;										Prioridad	+08
;										ip			+04

AgregarTareaTabla:

	push ebp		; Guardo ebp			
	mov	ebp,esp		; Cargo el valor de esp por si me interrumpen
	
	; Pila al momento:
	;		Contexto	+10
	;		CR3			+0C
	;		Prioridad	+08
	;		ip			+04
	;		ebp			+00	
			
	mov	ecx,MaxNumTareas			; Cargo la máxima cantidad de tareas que se pueden listar en la tabla
	mov	edx,PuntInicioTablaTareas	; Cargo el inicio de la tabla de tareas
	mov	ebx,Libre					; Lecargo a ebx la bandera de tarea libre en la tabla para buscar la posición en la tabla
					
LoopRecorrerTabla:
				
	cmp	bl,byte[edx + TareaTabla.Prioridad]	; Comparo la prioridad de la primera posición de la tabla con "Libre"
											; en caso de que esté libre agrego la tarea en esta posición de la tabla
	je	 TerminarBusqueda					; Termino la busqueda y agrego la tarea a la tabla de tareas del sistema
	add  edx,TareaTabla.size				; Apunto a la siguiente tarea de la tabla de tareas del sistema
	cmp	 edx,PunteroFinTablaTareas			; Si llegué al final de tabla de tareas
	je	 TablaLlena							; La tabla está llena, no agrego la tarea
	
	loop LoopRecorrerTabla					; Continuo en busqueda de una tarea libre
					
TerminarBusqueda:	

	; Agrega la tarea a la tabla de tareas del sistema
	; Al momento los registros son:
	;		ecx: Máximo numero de tareas permitidas - cantidad de posiciones barridas de la tabla
	;		edx: Puntero a la posición de la tabla donde agrego la tarea
	;		ebx: Libre (-1). En este punto la tarea esta libre
	
	; Realizo la copia de la prioridad de la tarea en la posición edx de la tabla de tareas
	xor	ebx,ebx									; Limpio estado de tareas
	mov	bl,byte[ebp + 0x08]						; Guardo la prioridad de la tarea a insertar
	mov	byte[edx + TareaTabla.Prioridad],bl		; Le cargo la prioridad a la tarea
	
	; Realizo la copia de ticks de la tarea en la posición edx de la tabla de tareas
	mov	ebx,0									; Cargo en ebx 0 ticks
	mov	dword[edx + TareaTabla.TSleep],ebx		; Inicializo a cero los ticks	
	
	; Realizo la copia de CR3 de la tarea en la posición ebx de la tabla de tareas
	mov	ebx,dword[ebp + 0x0C]					; Cargo en ebx el CR3 de la tarea a listar
	mov	dword[edx + TareaTabla.IdCr3],ebx		; Cargo el CR3 de la tarea
	
	; Realizo la copia de contexto de la tarea en la posición edx de la tabla de tareas
	mov	ebx,dword[ebp + 0x10]					; Cargo en ebx el contexto de la tarea a listar
	mov	dword[edx + TareaTabla.rContexto],ebx   ; Cargo el contexto a la tarea
	
FinTabla:

	; Termino la función de listar la tarea devolviendo por edx 0 - Pudo agregar tarea a la lista
	mov	esp,ebp						; Cargo en esp la dirección apuntada por puntero a base
	pop	ebp							; Recupero la posición del ebp
	mov	ebx,dword[esp]				; Obtengo el valor de IP (dirección de retorno)
	mov	dword[esp + 0x0C],ebx		; Guardo el valor de IP arriba de todo en la pila
	add 	esp,0x0C				; Apunto el esp
	mov	edx,0						; Retorno que fue correcto el agregado de la tarea
	
	ret								; Retorno de la función
	
TablaLlena:

	; Termino la función de listar la tarea devolviendo por edx 1 -No pudo agregar tarea a la lista
	mov	esp,ebp						; Cargo en esp la dirección apuntada por puntero a base
	pop	ebp							; Recupero la posición del ebp
	mov	ebx,dword[esp]				; Obtengo el valor de IP (dirección de retorno)
	mov	dword[esp + 0x0C],ebx		; Guardo el valor de IP arriba de todo en la pila
	add 	esp,0x0C				; APunto el esp, limpiando la pila (pusheos que ya no necesito en el retorno)
	mov	edx,1						; Retorno error por tabla llena
	
	ret								; Retorno de la función
	
;################################################################################
;	Función: Inicialización de la tabla de tareas
;################################################################################

; Info:			La función inicializa la tabla de tareas en todos sus campos
; Retorna:		Nada
; Argumentos:	Nada
; Nota: 		STRUC TareaTabla:   IdCr3|Prioridad|TSleep|Contexto

InitializaTableTask:

	mov edx, (MaxNumTareas - 1)		; Cargo la máxima cantidad de tareas a cargar
									; en la tabla de tareas (-1 debido a que la IDLE cuenta)
	mov ebx, PuntInicioTablaTareas	; Me posiciono al inicio de la tabla de tareas
	
InitTablaTarea:
	
	; Inicializo la estructura sin datos
	mov byte[ebx + TareaTabla.Prioridad], Libre 	; Indico que está libre (Prioridad)
	mov dword[ebx + TareaTabla.TSleep], Libre		; Indico que está libre (Sleep)
	mov dword[ebx + TareaTabla.IdCr3], NullCr3		; Indico que está libre (selector CR3)
	mov dword[ebx + TareaTabla.rContexto], Libre		; Indico que está libre	(Contexto de tarea)
	
	add ebx,TareaTablaTam	; Paso a la siguiente tarea de la tabla de tareas que voy a tener
	dec edx					; Disminuyo la cantidad de tareas que me faltan agregar para Máx Cant Tareas
	cmp edx,0				; Verifico que todavía no alcance la cantidad de tareas a inicializar
	jne InitTablaTarea		; Si no es igual inicializo la siguiente estructura para futura tarea
	
	call AgregarTareaIDLE	; Cargo la tarea IDLE en la última posición de la tabla
	
	ret						; Retorno de la función			

;################################################################################
;	Función: Inicializa la tarea IDLE en la última posición de la tabla
;################################################################################	

; Info:			La función agrega la tarea IDLE en la última posición de la tabla inicializada
; Retorna:		Nada
; Argumentos:	Nada
; Nota: 		STRUC TareaTabla:   IdCr3|Prioridad|TSleep|Contexto

AgregarTareaIDLE:
	
	; Inicializo la última posición de la tabla de tareas con la tarea IDLE
	mov dword[ebx + TareaTabla.Prioridad], PrioridadIdle	; Cargo prioridad de la tarea IDLE
	mov dword[ebx + TareaTabla.TSleep], 0 					; Cargo el timpo en Sleep (ticks)
	mov dword[ebx + TareaTabla.IdCr3], DirPDPTE				; Dirección CR3 de la tarea inicial (IDLE)
	mov dword[ebx + TareaTabla.rContexto], ContextoIDLE		; Contexto de la tarea inicial (IDLE)
	
	ret														; Retorno de la función

;################################################################################
;	Función: CargarContexto
;################################################################################

; Info:			La función carga el contexto de la tarea 
; Retorna:		Nada
; Argumentos:	Por registro eax: CR3 & Por registro ebx: Contexto
; Nota: 		STRUC TareaTabla:   ESP0|posterior_esp0|CR3|ESP|SS|SS0|

CargarContextoTarea:
	
	mov dword[ebx + Contexto.CR3],eax 														; Cargo el PDPT de la tarea IDLE (CR3)
	mov dword[ebx + Contexto.posterior_ESP0],(STACK_ADDRL_KERNEL + STACK_SIZE_TASK - 52)	; Cargo puntero a pila de privilegio 0 (Kernel) antes de INT ( popad + pop ds)
	mov dword[ebx + Contexto.ESP0],(STACK_ADDRL_KERNEL + STACK_SIZE_TASK )					; Cargo puntero a pila de privilegio 0 (Kernel)	
	mov dword[ebx + Contexto.ESP],(STACK_ADDRL_USER + STACK_SIZE_TASK)						; Cargo puntero a pila de privilegio 3 (Usuario)
	mov  word[ebx + Contexto.SS],datselUser													; Cargo el selector de pila de privilegio 3 (Usuario)
	mov  word[ebx + Contexto.SS0],datsel														; Cargo el selector de pila de privilegio 0 (Kernel)

	ret																						; Retorno de la función

;################################################################################
;	Función: CargarContextoInit
;################################################################################	

; Info:			La función carga el contexto de la tarea inicial del sistema
; Retorna:		Nada
; Argumentos:	Por registro eax: CR3 & Por registro ebx: Contexto
; Nota: 		STRUC TareaTabla:   ESP0|posterior_esp0|CR3|ESP|SS|SS0|

CargarContextoInit:

	mov dword[ContextoIDLE + Contexto.CR3], DirPDPTE								; Cargo el PDPT de la tarea IDLE (CR3)
	mov  word[ContextoIDLE + Contexto.SS],datsel									; Cargo el selector de pila de privilegio 3 (Usuario)
	mov dword[ContextoIDLE + Contexto.ESP],(STACK_ADDR + STACK_SIZE)				; Cargo puntero a pila de privilegio 3 (Usuario)
	mov dword[ContextoIDLE + Contexto.ESP0],(STACK_ADDR + STACK_SIZE)				; Cargo puntero a pila de privilegio 0 (Kernel)
	mov dword[ContextoIDLE + Contexto.posterior_ESP0],(STACK_ADDR + STACK_SIZE - 52); Cargo puntero a pila de privilegio 0 (Kernel) antes de INT ( popad + pop ds)
	
	ret																				; Retorno de la función

;################################################################################
;	Función: Cargar el contexto
;################################################################################	

; Info:			La función carga el contexto de la tarea a ejecutar
; Retorna:		ebx: Posición de ESP0 & eax: CR3 de la tarea a ejecutar
; Argumentos:	Obtiene por pila el contexto a ejecutar
; Nota: 		STRUC TareaTabla:   IdCr3|Prioridad|TSleep|Contexto

CargarContexto:
	
	mov	eax,[esp+4]									; Guardo en eax el puntero al contexto de la tarea a ejecutar
	
	; Cargo el SS en la estructura "TSS-IA32"
	mov	bp,[eax + Contexto.SS]						; Cargo el selector de pila de privilegio 3 (Usuario)
	mov	word[TSS + EstructuraTSS.reg_SS],bp			; Realizo la carga en la estructura TSS-IA32
	; Cargo el ESP en la estructura "TSS-IA32"
	mov	ebp,[eax + Contexto.ESP]					; Cargo el final de la pila de privilegio 3 (Usuario)		
	mov	dword[TSS + EstructuraTSS.reg_ESP],ebp		; Realizo la carga en la estructura TSS-IA32
	; Cargo el SS0 en la estructura "TSS-IA32"
	mov	bp,[eax + Contexto.SS0]						; Cargo el selector de pila de privilegio 0 (Kernel)
	mov	word[TSS + EstructuraTSS.reg_SS0],bp		; Realizo la carga en la estructura TSS-IA32
	; Cargo el ESP0 en la estructura "TSS-IA32"
	mov	ebp,[eax + Contexto.ESP0]					; Cargo el final de la pila de privilegio 0 (Kernel)		
	mov	dword[TSS + EstructuraTSS.reg_ESP0],ebp		; Reazlizo la carga en la estructura TSS-IA32
	; Cargo el ESP posterior y el CR3 para retornar a la función
	mov	ebx,[eax + Contexto.posterior_ESP0]			; Cargo la posición de ESP0 en EBX
	mov	eax,[eax + Contexto.CR3]					; Cargo el registro de control CR3 de la tarea a ejecutar

	; Balanceo la pila y retorno de la función
	mov	ebp,[esp]			
	add	esp,4
	mov	[esp],ebp			
	
	ret				; Retorno de la función
	
;################################################################################
;	Función: Guardar contexto 
;################################################################################	

; Info:			La función guarda el contexto de la tarea en ejecución.
; Retorna: 		Nada
; Argumentos:	Recibe por pila el contexto de la tarea a salvar
; Nota: 		STRUC TareaTabla:   IdCr3|Prioridad|TSleep|Contexto

GuardarContexto:

	mov	ecx,[esp + 4]	; Guardo en eax el puntero al contexto de la tarea actual
	
	; Guardo el ESP0 en la estructura "Contexto" de la tarea ejecutandose
	mov	ebp, dword[TSS + EstructuraTSS.reg_ESP0]	; Guardo el final de la pila de privilegio 0 (Kernel)	
	mov	[ecx + Contexto.ESP0], ebp					; Realizo el salvado de la estructura contexto de la tarea actual
	; Guardo el ESP en la estructura "Contexto" de la tarea ejecutandose
	mov	ebp, dword[TSS + EstructuraTSS.reg_ESP]		; Guardo el final de la pila de privilegio 3 (Usuario)
	mov	[ecx + Contexto.ESP], ebp					; Realizo el salvado en la estructura contexto de la tarea actual
	; Guardo el SS0 en la estructura "Contexto" de la tarea ejecutandose
	mov	bp, word[TSS + EstructuraTSS.reg_SS0]		; Guardo el selector de pila de privilegio 0 (Kernel)
	mov	[ecx + Contexto.SS0], bp					; Ralizo el salvado en la estructura contexto de la tarea actual
	; Guardo el SS en la estructura "Contexto" de la tarea ejecutandose
	mov	bp, word[TSS + EstructuraTSS.reg_SS]		; Guardo el selector de pila de privilegio 3 (Usuario)
	mov	[ecx + Contexto.SS], bp						; Realizo el salvado en la estructura contexto de la tarea actual
	
	; Dado que debe retornar como si nunca hubiera entrado en la función "GuardarContexto"
	mov	ebp, esp					
	add	ebp, 8					
	mov	[ecx + Contexto.posterior_ESP0], ebp		; Guardo el ESP0 justo antes de entrar a la función "GuardarContexto"
	
	; Balanceo la pila y retorno de la función
	mov	ebp, [esp]				 
	add	esp, 4
	mov	[esp], ebp			

	ret				; Retorno de la función

;################################################################################
;	Función: DecrementarTIempo
;################################################################################	

DecrementarTiempo:

	mov eax,PuntInicioTablaTareas	; Apunto a la tabla de tareas cargadas
	add eax,TareaTabla.TSleep		; Apunto al campo tick de la tarea
	mov ecx,MaxNumTareas			; Cargo en ecx el máximo de tareas cargadas permitidas 	
	
ProximaTarea:
	
	cmp dword[eax],0	; Comparo si tiene ticks cargadas la tarea
	jbe NoDecrementar	; Si no tiene tick ó no esta inicializada, no decremento ticks
	dec dword[eax]		; Decremento ticks de la tarea en sleep
	
NoDecrementar:	
	add eax,TareaTabla.size
	loop ProximaTarea	; Decremento ticks de la próxima tarea en la tabla de tareas cargadas
	
	ret					; Retorno de la función
	
;################################################################################
;	Función: InitPilaTarea
;################################################################################

; Info:			La función carga el contenido inicial de la pila de la tarea
; Retorna:		Nada
; Recibe:		Por registro (EAX) la dirección física donde se pagina la tarea

InitPilaTarea:
	
	mov ebx,eax					; Cargo en ebx la dirección física donde se encuentra la tarea (0x00AX0000)
	add ebx,OffsetPilaStack		; Apunto a la dirección física donde se encuentra la pila de la tarea privilegio 0 (Kernel)
								; Pila de privilegio 0 (Kernel)
								; Pila de tarea: 0xAX2000
	add ebx,STACK_SIZE_TASK		; Le doy tamaño a la pila para que pueda crecer
	
	; Registros que se pushean con la interrupción (SS, ESP, EFLAGS, CS, EIP.)
	mov  word[ebx - 0x00],datselUser + 3						; Selector de datos privilegio 3(Usuario)
	mov dword[ebx - 0x04],(STACK_ADDRL_USER + STACK_SIZE_TASK)	; Puntero a la pila privilegio 3 (Usuario) (ESP)
	mov dword[ebx - 0x08],0x202									; Registro EFLAGS
	mov  word[ebx - 0x0C],codselUser + 3						; Selector de código privilegio 3 (Usuario)
	mov dword[ebx - 0x10],CodigoTareas							; Dirección lineal donde se encuenta el inicio de la tarea
										; <- Dejo lugar para el "popad" de los registros generales
	mov word[ebx  - 0x34],datselUser + 3						; Selector de datos privilegio 3 (Usuario)
	
	ret															; Retorno de la función de inicialización de la pila correspondiente a la tarea X
	
;/* ----------- Fin del archivo ----------- */
