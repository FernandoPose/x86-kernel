;################################################################################
;#	Tí­tulo: Declaración de variables externas 16 bit (Modo Real)				#
;#																				#
;#	Versión:		1.1									Fecha: 	07/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Declaración variables externas - Año: 2015       						#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 07/01/2016 | F.POSE | Original									#
;#		1.1 | 08/01/2016 | F.POSE | Agregué los EXTERN del LinkerScript			#
;#		1.2 | 14/01/2016 | F.POSE | Agregué los EXTERN de int. y excp			#
;#		1.3 | 14/01/2016 | F.POSE | Agregué los EXTERN de tareas y paginación	#
;#		1.4 | 26/01/2016 | F.POSE | Agregué los EXTERN de la call system		#
;#		1.5 | 26/01/2016 | F.POSE | Agregué los EXTERN de la tss				#
;#		2.0 | 27/01/2016 | F.POSE | extern16.asm completo (No modificar)		#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################


;################################################################################
;   Linker Script
;################################################################################

EXTERN _reset_vector
EXTERN _reset_vector_start
EXTERN _reset_vector_end
EXTERN _reset_vector_tam
EXTERN _init16
EXTERN _init16_start
EXTERN _init16_end
EXTERN _init16_tam
EXTERN _init32
EXTERN _init32_start
EXTERN _ds_init32
EXTERN _di_init32
EXTERN _init32_end
EXTERN _init32_tam
EXTERN _sys_tables
EXTERN _sys_tables_start
EXTERN _ds_sys_tables
EXTERN _di_sys_tables
EXTERN _sys_tables_end
EXTERN _sys_tables_tam
EXTERN _stack
EXTERN _stack_start
EXTERN _ds_stack
EXTERN _di_stack
EXTERN _stack_end
EXTERN _stack_tam
EXTERN _code_main
EXTERN _code_main_start
EXTERN _ds_code_main
EXTERN _di_code_main
EXTERN _code_main_end
EXTERN _code_main_tam
EXTERN _data
EXTERN _data_start
EXTERN _ds_data
EXTERN _di_data
EXTERN _data_end
EXTERN _data_tam
EXTERN _bss
EXTERN _bss_start
EXTERN _ds_bss
EXTERN _di_bss
EXTERN _bss_end
EXTERN _bss_tam
EXTERN functions
EXTERN _functions_start
EXTERN _ds_functions
EXTERN _di_functions
EXTERN _functions_end
EXTERN _functions_tam 
EXTERN _libs
EXTERN _libs_start
EXTERN _ds_libs
EXTERN _di_libs
EXTERN _libs_end
EXTERN _libs_tam
EXTERN divisionErrorVMA
EXTERN _DEHandler_start
EXTERN divisionErrorHigh
EXTERN divisionErrorLow
EXTERN _DEHandler_end
EXTERN _DEHandler_tam
EXTERN undefinedcodeVMA
EXTERN _UDHandler_start
EXTERN undefinedcodeHigh
EXTERN undefinedcodeLow
EXTERN _UDHandler_end
EXTERN _UDHandler_tam
EXTERN doublefaultVMA
EXTERN _DFHandler_start
EXTERN doublefaultHigh
EXTERN doublefaultLow
EXTERN _DFHandler_end
EXTERN _UDHandler_tam
EXTERN generalprotectionVMA
EXTERN _GPHandler_start
EXTERN generalprotectionHigh
EXTERN undefinedcodeLow
EXTERN _GPHandler_end
EXTERN _GPHandler_tam
EXTERN pagefaultVMA
EXTERN _PFHandler_start
EXTERN pagefaultHigh
EXTERN pagefaultLow
EXTERN _PFHandler_end
EXTERN _PFHandler_tam
EXTERN timerVMA
EXTERN _TimerHandler_start
EXTERN timerHigh
EXTERN timerLow
EXTERN _TimerHandler_end
EXTERN _TimerHandler_tam
EXTERN keyboardVMA
EXTERN _keyboardHandler_start
EXTERN keyboardHigh
EXTERN keyboardLow
EXTERN _keyboardHandler_end
EXTERN _keyboardHandler_tam
EXTERN ServicioSistemaVMA
EXTERN  _ServicioSistema_start
EXTERN ServicioSistemaHigh
EXTERN ServicioSistemaLow
EXTERN _ServicioSistemaHandler_end
EXTERN _ServicioSistemaHandler_tam
EXTERN PageTableVMA
EXTERN _PageTable_start
EXTERN PageTableHigh
EXTERN _PageTable_end
EXTERN _PageTable_tam
EXTERN Tarea1VMA
EXTERN _Tarea1_start
EXTERN Tarea1High
EXTERN Tarea1Low
EXTERN _Tarea1_end
EXTERN _Tarea1_tam
EXTERN Tarea2VMA
EXTERN _Tarea2_start
EXTERN Tarea2High
EXTERN Tarea2Low
EXTERN _Tarea2_end
EXTERN _Tarea2_tam
EXTERN Tarea3VMA
EXTERN _Tarea3_start
EXTERN Tarea3High
EXTERN Tarea3Low
EXTERN _Tarea3_end
EXTERN _Tarea3_tam
EXTERN tss1VMA
EXTERN  _tss1_start
EXTERN TssIdleHigh
EXTERN TssIdleMed
EXTERN TssIdleLow
EXTERN _tss1_end
EXTERN _tss1_tam

;/* ----------- Fin del archivo ----------- */
