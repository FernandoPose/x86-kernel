;################################################################################
;#	Tí­tulo: Trabajo práctico Obligatorio - Todo  			 					#
;#																				#
;#	Versión:		1.1									Fecha: 	08/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Contiene todos los archivos del trabajo práctico - Año: 2015   			#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 08/01/2016 | F.POSE | Original									#
;#		2.0 | 30/01/2016 | F.POSE | TrabajoPractico.asm completo (No modificar)	#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################


;################################################################################
;   Estructuras
;################################################################################

%include "estructuras.asm" ; Por ahí este lo tenga que poner antes de Defines.asm

;################################################################################
;   Defines
;################################################################################

%include "Defines.asm"

;################################################################################
;   Globales
;################################################################################

%include "extern16.asm"
%include "extern32.asm"

;################################################################################
;   Macros
;################################################################################

; Este tp no contiene macros

;################################################################################
;   Archivos
;################################################################################

%include "system_call.asm"
%include "rtc.asm"
%include "FuncionesAux.asm"
%include "FuncionesTareas.asm"
%include "tareas.asm"
%include "paginacion.asm"
%include "sys_tables.asm"
%include "init32.asm"
%include "interrupciones.asm"
%include "main32.asm"
%include "excepciones.asm"

;/* ----------- Fin del archivo ----------- */
