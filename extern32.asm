;################################################################################
;#	Tí­tulo: Declaración de variables externas 32 bit (Modo Protegido)			#
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
;#		2.0 | 08/01/2016 | F.POSE | extern32.asm completo (No modificar)		#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################



;################################################################################
;   32 bit (Modo Protegido)
;################################################################################


;################################################################################
;   Direcciones de offset (Tabla de interrupciones IDT) - Linker
;################################################################################

EXTERN divisionErrorHigh
EXTERN divisionErrorLow
EXTERN undefinedcodeHigh
EXTERN undefinedcodeLow
EXTERN doublefaultHigh
EXTERN doublefaultLow
EXTERN generalprotectionHigh
EXTERN generalprotectionLow
EXTERN pagefaultHigh
EXTERN pagefaultLow
EXTERN timerHigh
EXTERN timerLow
EXTERN keyboardHigh
EXTERN keyboardLow

;/* ----------- Fin del archivo ----------- */
