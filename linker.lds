/*###############################################################################*/
/*#	TÃ­tulo: Linker Script     								 					#*/
/*#																				#*/
/*#	Versión:		1.1									Fecha: 	03/01/2016		#*/
/*#	Autor: 			F.Pose							            				#*/
/*#	Compilación:	Linkear junto al proyecto principal							#*/
/*#	Uso: 			-															#*/
/*#	------------------------------------------------------------------------	#*/
/*#	Descripción:																#*/
/*#		Linker Script del trabajo práctico - Año: 2015							#*/
/*#	------------------------------------------------------------------------	#*/
/*#	Revisiones:																	#*/
/*#		1.0 | 4/01/2016 | F.POSE | Original		     							#*/
/*#		1.1 | 7/01/2016 | F.POSE | Primera edición (Agrego tamaños de sección)	#*/
/*#		1.2 | 8/01/2016 | F.POSE | Cambio etiquetas								#*/
/*#		1.3 | 13/01/2016 | F.POSE | Agregué las direcciones VMA de IDT			#*/
/*#		2.0 | 13/01/2016 | F.POSE | Agregué las secciones de las excep. e int.	#*/
/*#		2.1 | 19/01/2016 | F.POSE | Agregué tabla de paginación y tareas.		#*/
/*#		2.2 | 26/01/2016 | F.POSE | Agregué la sección de la tss.				#*/
/*#		3.0 | 27/01/2016 | F.POSE | Linker Script terminado (No modificar)		#*/
/*#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#*/
/*#																				#*/
/*###############################################################################*/

SECTIONS
{

	/* Inicialización de 16 bits */
	
	. = 0xF0000;
	_init16 = .;  
		.init16 :
		AT ( 0xF0000 )
			{ *(.init16); }
	_init16_start = LOADADDR(.init16); 
	_init16_end   = _init16_start + SIZEOF(.init16);
	_init16_tam   = SIZEOF(.init16);	
	
	/* Inicialización de 32 bits */
	
	. = 0x000F4000;
	_init32 = .;
	.init32 :
		AT ( 0xF4000 )
			{ 	*(.init32);}
	_init32_start = LOADADDR(.init32);
	_ds_init32 = (_init32_start >> 16) & 0x0000FFFFF;      /* Etiqueta parte alta de ROM */
	_di_init32 = _init32_start & 0x0000FFFF;	     	   /* Etiqueta parte baja de ROM */
	_init32_end   = _init32_start + SIZEOF(.init32);
	_init32_tam   = SIZEOF(.init32);
	
	/* Tablas */
	
	. = 0x00100000;
	_sys_tables = .;
	.sys_tables :
		AT ( LOADADDR(.init32) + SIZEOF(.init32) )
			{ *(.sys_tables); }
	_sys_tables_start = LOADADDR(.sys_tables);
	_ds_sys_tables = (_sys_tables_start >> 16) & 0x0000FFFF;
	_di_sys_tables = _sys_tables_start & 0x0000FFFF;
	_sys_tables_end   = _sys_tables_start + SIZEOF(.sys_tables);
	_sys_tables_tam   = SIZEOF(.sys_tables);
	
	/* Pila (stack) */
	
	. = 0x00140000;
	_stack = .;
	.stackE :
		AT ( LOADADDR(.sys_tables) + SIZEOF(.sys_tables) )
			{ *(.stackE); }
	_stack_start = LOADADDR(.stackE);
	_ds_stack = (_stack_start >> 16) & 0x0000FFFF;
	_di_stack = _stack_start & 0x0000FFFF;
	_stack_end   = _stack_start + SIZEOF(.stackE);
	_stack_tam   = SIZEOF(.stackE);
	
	/* Código principal */
	
	. = 0x00150000;
	_code_main = .;
	.code_main :
		AT( LOADADDR(.stackE) + SIZEOF(.stackE) )
			{ *(.code_main);
				*(.text);  }
	_code_main_start = LOADADDR(.code_main);
	_ds_code_main = (_code_main_start >> 16) & 0x0000FFFF;
	_di_code_main = _code_main_start & 0x0000FFFF;
	_code_main_end   = _code_main + SIZEOF(.code_main);
	_code_main_tam   = SIZEOF(.code_main);
	
	/* Datos inicializados - data */
		
	. = 0x00200000;
	_data = .;
	.dataE :
		AT( LOADADDR(.code_main) + SIZEOF(.code_main) )
			{ *(.dataE1); 
			*(.dataE2); }
	_data_start = LOADADDR(.dataE);
	_ds_data = (_data_start >> 16) & 0x0000FFFF;
	_di_data = _data_start & 0x0000FFFF;
	_data_end   = _data + SIZEOF(.dataE);
	_data_tam   = SIZEOF(.dataE);
	
	/* Datos no inicializados - bss */
	
	. = 0x00210000;
	_bss = .;
	.bssE :
		AT( LOADADDR(.dataE) + SIZEOF(.dataE) )
			{ *(.bssE); }
	_bss_start = LOADADDR(.bssE);
	_ds_bss = (_bss_start >> 16) & 0x0000FFFF;
	_di_bss = _bss_start & 0x0000FFFF;
	_bss_end = _bss + SIZEOF(.bssE);
	_bss_tam   = SIZEOF(.bssE);
	
	. = 0x00230000;
	functions = .;
	.functions :
		AT( LOADADDR(.bssE) + SIZEOF(.bssE) )
			{ *(.functions); }
	_functions_start = LOADADDR(.functions);
	_ds_functions = (_functions_start >> 16) & 0x0000FFFF;
	_di_functions = _functions_start & 0x0000FFFF;
	_functions_end = functions + SIZEOF(.functions);
	_functions_tam   = SIZEOF(.functions);
	
	
	/* Excepciones */
	
	/* Parte baja y parte alta para los manejadores de excepciones e interrupciones */
	
	/* Error de división #DE - Clase Falta. */
	
	. = 0x00250000;
	divisionErrorVMA = . ;
	.DEHandler :
		AT( LOADADDR(.functions) + SIZEOF(.functions) )
			{ *(.DEHandler); }    
    _DEHandler_start = LOADADDR(.DEHandler);
	divisionErrorHigh = (divisionErrorVMA >> 16) & 0x0000FFFF;
	divisionErrorLow = divisionErrorVMA & 0x0000FFFF;
	_DEHandler_end = divisionErrorVMA + SIZEOF(.DEHandler);
	_DEHandler_tam   = SIZEOF(.DEHandler);
    
    /* Código OP no válido #UD - Clase Falta. */
	
	. = 0x00251000;
    undefinedcodeVMA = .;
	.UDHandler :
		AT( LOADADDR(.DEHandler) + SIZEOF(.DEHandler) )
			{ *(.UDHandler); }    
    _UDHandler_start = LOADADDR(.UDHandler);
	undefinedcodeHigh = (undefinedcodeVMA >> 16) & 0x0000FFFF;
	undefinedcodeLow = undefinedcodeVMA & 0x0000FFFF;
	_UDHandler_end = undefinedcodeVMA + SIZEOF(.UDHandler);
	_UDHandler_tam   = SIZEOF(.UDHandler);
 
    /* Doble falta #DF - Clase Aborto. */
    
    . = 0x00252000;
    doublefaultVMA = . ;
	.DFHandler :
		AT( LOADADDR(.UDHandler) + SIZEOF(.UDHandler) )
			{ *(.DFHandler); }    
    _DFHandler_start = LOADADDR(.DFHandler);
	doublefaultHigh = (doublefaultVMA >> 16) & 0x0000FFFF;
	doublefaultLow = doublefaultVMA & 0x0000FFFF;
	_DFHandler_end = doublefaultVMA + SIZEOF(.DFHandler);
	_UDHandler_tam   = SIZEOF(.DFHandler);

	/* Protección general #GP - Clase Falta. */
	
	. = 0x00253000;
    generalprotectionVMA = . ;
	.GPHandler :
		AT( LOADADDR(.DFHandler) + SIZEOF(.DFHandler) )
			{ *(.GPHandler); }    
    _GPHandler_start = LOADADDR(.GPHandler);
	generalprotectionHigh = (generalprotectionVMA >> 16) & 0x0000FFFF;
	generalprotectionLow = generalprotectionVMA & 0x0000FFFF;
	_GPHandler_end = generalprotectionVMA + SIZEOF(.GPHandler);
	_GPHandler_tam   = SIZEOF(.GPHandler);

	/* Fallo de página #PF - Clase Falta. */
	
	. = 0x00254000;
    pagefaultVMA = . ;
	.PFHandler :
		AT( LOADADDR(.GPHandler) + SIZEOF(.GPHandler) )
			{ *(.PFHandler); }    
    _PFHandler_start = LOADADDR(.PFHandler);
	pagefaultHigh = (pagefaultVMA >> 16) & 0x0000FFFF;
	pagefaultLow = pagefaultVMA & 0x0000FFFF;
	_PFHandler_end = pagefaultVMA + SIZEOF(.PFHandler);
	_PFHandler_tam   = SIZEOF(.PFHandler);

	
	/* Interrupciones */

	/* Interrupción de timer */
	
	. = 0x00270000;
    timerVMA = . ;
	.TimerHandler :
		AT( LOADADDR(.PFHandler) + SIZEOF(.PFHandler) )
			{ *(.TimerHandler); }    
    _TimerHandler_start = LOADADDR(.TimerHandler);
	timerHigh = (timerVMA >> 16) & 0x0000FFFF;
	timerLow = timerVMA & 0x0000FFFF;
	_TimerHandler_end = timerVMA + SIZEOF(.TimerHandler);
	_TimerHandler_tam   = SIZEOF(.TimerHandler);	
	
	/* Interrupción del teclado */

	. = 0x00271000;
    keyboardVMA = . ;    
	.keyboardHandler :
		AT( LOADADDR(.TimerHandler) + SIZEOF(.TimerHandler) )
			{ *(.keyboardHandler); }    
    _keyboardHandler_start = LOADADDR(.keyboardHandler);
	keyboardHigh = (keyboardVMA >> 16) & 0x0000FFFF;
	keyboardLow = keyboardVMA & 0x0000FFFF;
	_keyboardHandler_end = keyboardVMA + SIZEOF(.keyboardHandler);
	_keyboardHandler_tam   = SIZEOF(.keyboardHandler);   

	/* Interrupción Servicio del sistema */
	
	. = 0x00272000;
    ServicioSistemaVMA = . ;
	.ServicioSistema :
		AT( LOADADDR(.keyboardHandler) + SIZEOF(.keyboardHandler) )
			{ *(.ServicioSistema); }    
    _ServicioSistema_start = LOADADDR(.ServicioSistema);
	ServicioSistemaHigh = (ServicioSistemaVMA >> 16) & 0x0000FFFF;
	ServicioSistemaLow = ServicioSistemaVMA & 0x0000FFFF;
	_ServicioSistemaHandler_end = ServicioSistemaVMA + SIZEOF(.ServicioSistema);
	_ServicioSistemaHandler_tam  = SIZEOF(.ServicioSistema);	

	/* Paginación */

	/* Tablas de paginación */

	PageTableVMA = 0x00290000 ;    
	.PageTable :
		AT( LOADADDR(.ServicioSistema) + SIZEOF(.ServicioSistema) )
			{ *(.PageTable); }    
    _PageTable_start = LOADADDR(.PageTable);
	PageTableHigh = (PageTableVMA >> 16) & 0x0000FFFF;
	PageTableLow = PageTableVMA & 0x0000FFFF;
	_PageTable_end = PageTableVMA + SIZEOF(.PageTable);
	_PageTable_tam   = SIZEOF(.PageTable);

	/* Tareas */

	/* Tarea 1 */

	Tarea1VMA = 0x00A00000 ;    
	.Tarea1 :
		AT( LOADADDR(.PageTable) + SIZEOF(.PageTable) )
			{ *(.Tarea1); }    
    _Tarea1_start = LOADADDR(.Tarea1);
	Tarea1High = (Tarea1VMA >> 16) & 0x0000FFFF;
	Tarea1Low = Tarea1VMA & 0x0000FFFF;
	_Tarea1_end = Tarea1VMA + SIZEOF(.Tarea1);
	_Tarea1_tam   = SIZEOF(.Tarea1);  

	/* Tarea 2 */

	Tarea2VMA = 0x00A10000 ;    
	.Tarea2 :
		AT( LOADADDR(.Tarea1) + SIZEOF(.Tarea1) )
			{ *(.Tarea2); }    
    _Tarea2_start = LOADADDR(.Tarea2);
	Tarea2High = (Tarea2VMA >> 16) & 0x0000FFFF;
	Tarea2Low = Tarea2VMA & 0x0000FFFF;
	_Tarea2_end = Tarea2VMA + SIZEOF(.Tarea2);
	_Tarea2_tam   = SIZEOF(.Tarea2);

	/* Tarea 3 */

	Tarea3VMA = 0x00A20000 ;    
	.Tarea3 :
		AT( LOADADDR(.Tarea2) + SIZEOF(.Tarea2) )
			{ *(.Tarea3); }    
    _Tarea3_start = LOADADDR(.Tarea3);
	Tarea3High = (Tarea3VMA >> 16) & 0x0000FFFF;
	Tarea3Low = Tarea3VMA & 0x0000FFFF;
	_Tarea3_end = Tarea3VMA + SIZEOF(.Tarea3);
	_Tarea3_tam   = SIZEOF(.Tarea3);



	/* Descriptor de TSS */
	
	/* Parte baja, parte media y parte alta para la tss */
	
	tss1VMA = 0x00190000 ;    
	.tss1 :
		AT( LOADADDR(.Tarea3) + SIZEOF(.Tarea3) )
			{ *(.tss1); }    
    _tss1_start = LOADADDR(.tss1);
	TssIdleHigh = (tss1VMA >> 24) & 0x000000FF;
	TssIdleMed = (tss1VMA >> 16) & 0x000000FF;
	TssIdleLow = tss1VMA & 0x0000FFFF;
	_tss1_end = tss1VMA + SIZEOF(.tss1);
	_tss1_tam   = SIZEOF(.tss1);  	


	/* Vector de Reset */

	. = 0xFFFF0;       		/* Posiciono el puntero a la dir del vectro de reset.*/
	_reset_vector = .;    	/* Guardo en la etiqueta el valor en VMA */
	.reset_vector :
		AT ( 0xFFFF0 )      /* LMA a la posicion inicial */               
			{ *(.reset_vector); }
	_reset_vector_start = LOADADDR(.reset_vector);   					/* Etiqueta del inicio de la seccion */
	_reset_vector_end   = _reset_vector_start + SIZEOF(.reset_vector);  /* Etiqueta del final de la seccion */
	_reset_vector_tam   = SIZEOF(.reset_vector);						/* Etiqueta del tamaño de la seccion */

}
	
/* ----------- Fin del archivo ----------- */		
