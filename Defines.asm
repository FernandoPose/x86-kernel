;################################################################################
;#	Tí­tulo: Defines - Trabajo Práctico						 					#
;#																				#
;#	Versión:		1.1									Fecha: 	10/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Defines utilizados en el trabajo práctico - Año: 2015					#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 10/01/2016 | F.POSE | Original									#
;#		1.0 | 19/01/2016 | F.POSE | Agregué defines de paginación.				#
;#		1.0 | 23/01/2016 | F.POSE | Agregué defines de tareas (aplicación).		#
;#		2.0 | 08/01/2016 | F.POSE | Defines.asm completo (No modificar)			#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################

;################################################################################
;	Defines - Varios
;################################################################################

%define 	_UMAGIC xchg bx,bx
%define		NULL			0
%define 	DEBUG_MAGIC 	1

;%if DEBUG_MAGIC
;	_UMAGIC
;%endif

;################################################################################
;	Defines - Stack
;################################################################################

%define	STACK_ADDR	0x00140000	; Direccion fisica para la pila
%define	STACK_SIZE	4*1024		; 4kB

;################################################################################
;	Defines - Video
;################################################################################

; Características de la pantalla - Simulador - Dirección
%define	VGA_RAM					0xB8000
%define VGA_RAM_VIRTUAL 	    0x280000
%define	MAX_COLUMNAS_PANTALLA	80
%define	MAX_FILAS_PANTALLA		25
%define TAM_VIDEO_CARACTERES    (MAX_FILAS_PANTALLA * MAX_COLUMNAS_PANTALLA)
%define TAM_VIDEO_BYTES			(2 * TAM_VIDEO_CARACTERES)

; Colores de fuente
%define	RED_F	0x04
%define	GREEN_F	0x02
%define	BLUE_F	0x01

; Colores de fondo
%define	RED_B	0x40
%define	GREEN_B	0x20
%define	BLUE_B	0x10

; Parpadeo
%define	BLINK	0x80

; Intensidad
%define	INTENSE	0x08

; Varios
%define CARACTER_NULO 0x00

;################################################################################
;	Defines - Excepciones
;################################################################################

; No puse ningún define de excepciones en el código

;################################################################################
;	Defines - Paginación
;################################################################################

%define	PG_TAM 4096 ; Tamaño de cada página

; Ubicación en memoria de las tablas (Diapositiva 35 de paginación)

%define DirPDPTE 0x00290000 			; Dirección de la tabla de punteros a directorios de páginas
%define	DirPDE   DirPDPTE + 0x1000	 	; Dirección del directorio de tablas de páginas 
%define	DirPTE1  DirPDE   + 0x1000 		; Dirección de la tabla de páginas 1
%define	DirPTE2  DirPTE1  + 0x1000 		; Dirección de la tabla de páginas 2

%define BaseTablaPaginacion (DirPTE2 + 0x1000)	; A partir de esta posición se agregan las nuevas entradas al PDTP y DTP
												; Se utiliza en la función que pagina las tareas.
												
; Ubicación en memoria de las páginas de las secciones

%define Pag1Init32		0x000F4000
;%define Pag2Init32		(Pag1Init32 + 0x1000)     	; No la utilizo para la conmutación de tarea
%define Pag1SysTables	0x00100000;
;%define Pag2SisTables	(Pag1SysTables + 0x1000)	; No la utilizo para la conmutación de tarea
%define Pag1Stack		0x00140000
%define Pag2Stack		(Pag1Stack + 0x1000)		; No la utilizo para la conmutación de tarea
%define Pag1CodeMain	0x00150000
;%define Pag2CodeMain	(Pag1CodeMain + 0x1000)		; No la utilizo para la conmutación de tarea
%define PagTss1 		0x00190000
%define Pag1Data		0x00200000
;%define Pag2Data		(Pag1Data + 0x1000)			; No la utilizo para la conmutación de tarea
%define Pag1Bss			0x00210000
;%define Pag2Bss		(Pag1Bss + 0x1000)			; No la utilizo para la conmutación de tarea
%define Pag1Function	0x00230000
%define Pag1DeHandler	0x00250000
%define Pag1UdHandler	0x00251000
%define Pag1DfHandler	0x00252000
%define Pag1GpHandler	0x00253000
%define Pag1PfHandler	0x00254000
%define Pag1Timer		0x00270000
%define Pag1Keyboard	0x00271000
%define Pag1ServicioSistema 0x00272000  

; Dirección lineal de las tareas pedidas (dato del ejercicio)

%define Pag1Tar1		0x00A00000
%define Pag1Tar2		0x00A10000
%define Pag1Tar3		0x00A20000

%define OffsetPagTar	0x10000
						
;################################################################################
;	Defines - Pila de tareas
;################################################################################

; Dirección lineal de las pilas 

%define STACK_ADDRL_USER	0x00121000		; Dirección lineal de la pila de privilegio 3 (Usuario)
%define STACK_ADDRL_KERNEL	0x00124000		; Dirección lineal de la pila de privilegio 0 (Kernel)

; Dirección física donde se ubican las pilas

%define	STACK_ADDRF1	0x00A04000	; Direccion física para la pila de tarea 1 privilegio 0 (Kernel)
%define	STACK_ADDRF2	0x00A14000	; Direccion física para la pila de tarea 2 privilegio 0 (Kernel)
%define	STACK_ADDRF3	0x00A24000	; Direccion física para la pila de tarea 3 privilegio 0 (Kernel)

%define	STACK_SIZE_TASK	0x500		; Tamaño de la pila de las tareas

%define OffsetPilaStack 0x4000		; Offset que utilizo en la función InitPilaTarea (FuncionesTareas.asm)

; NOTA: El trabajo práctico pide 2 páginas por sección.
; Las secciones de excepciones las realice de una sola página,
; estas se podrían haber implementado todas en una misma 
; sección, queda como una mejora para futuro en caso de tener
; tiempo.  

%define	PermisosUsuario 0x07
%define PermisosKernel  0x05
%define	PermisosDTP 	0x01

%define Tp1Permisos 0x07
%define Tp2Permisos 0x07

;################################################################################
;	Defines - Interrupciones
;################################################################################

; No puse ningún define de interrupciones en el código

;################################################################################
;	Defines - System Call
;################################################################################

%define TextoEspacio 10

; Los utilizo para identificar que servicio requiero

%define PrintFecha		0
%define PrintHora		1
%define PrintContador	2
%define PrintSleep		3

; Posiciones de líneas para Hora y Fecha

%define HorasDecena		17	
%define	HorasUnidad		18
%define MinutosDecena	20
%define	MinutosUnidad	21
%define SegundosDecena	23
%define SegundosUnidad	24

%define AnoDecena		24
%define AnoUnidad		25
%define	MesDecena		21
%define MesUnidad		22
%define DiaDecena		18
%define DiaUnidad		19
%define FechaDecena		27
%define	FechaUnidad		28

; Para el contador

%define Unidad			0xF
%define Decena			0xF0
%define Centena			0xF00
%define m_unidad		0xF000
%define EspacioTexto	10

;################################################################################
;	Defines - Conmutación de tareas
;################################################################################

; Varios utilizados en la conmutación de tareas

%define MaxNumTareas	10	; Máxima catnidad de tareas que puedo tener en la tabla de tareas
%define NullCr3			0	; Para cargar el selector CR3 nulo al inicio de carga de tabla de tareas

; Variables varias utilizadas en paginación de tareas

%define CodigoTareas 		0x00110000		; Dirección lineal donde va a estar todo el código de las tareas
%define CantPagTask			5				; Cantidad de páginas por tarea

; Tamaños de las estructuras utilizadas

%define ContextoTam			Contexto.size		; Tamaño de la estructura de contexto tarea
%define TareaTablaTam		TareaTabla.size		; Tamaño de la estructura de la tabla de tarea
%define EstructuraTssTam	EstructuraTSS.size	; Tamaño de la estructura de la TSS-IA32

%define TablaTareasTam		(TareaTablaTam * MaxNumTareas) ; Tamaño total de la tabla contenedora de tareas 

; Tiempo de ejecución de cada tarea (SleepTimer)

%define TicksTar1		1000	; 1000 mSeg (Tarea de hora del sistema)
%define TicksTar2		1000	; 1000 mSeg (Tarea de fecha del sistema)
%define TicksTar3		5000	; 1000 mSeg (Tarea contador)

; Prioridades de las tareas

%define PrioridadMaxima	9	; Máxima prioridad (Según enunciado)
%define PrioridadSleep	0  	; Mínima prioridad (Según enunciado)
%define PrioridadIdle	1  	; Prioridad de la tarea IDLE
%define Libre			-1	; Lo utilizo para indicar que no hay datos cargadas

; Niveles de privilegio de las tareas

%define PrivilegioUser		0x03	; Privilegios nivel 3
%define PrivilegioKernel	0x00	; Privilegios nivel 0
%define	PrivPresIDLE		0x04	; Privilegios + Bit de presencia tarea IDLE

;################################################################################
;	Defines - Niveles de privilegio
;################################################################################

; Los define de privilegio de usuario y kernel los definí en otras secciones de este archivo

;/* ----------- Fin del archivo ----------- */
