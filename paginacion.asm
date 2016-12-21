;################################################################################
;#	Tí­tulo: Funciones de paginación 							 				#
;#																				#
;#	Versión:		1.1									Fecha: 	19/01/2016		#
;#	Autor: 			F.POSE							            				#
;#	Compilación:	Linkear junto al proyecto principal							#
;#	Uso: 			-															#
;#	------------------------------------------------------------------------	#
;#	Descripción:																#
;#		Funciones de paginación del sistema del trabajo práctico - Año: 2015	#
;#	------------------------------------------------------------------------	#
;#	Revisiones:																	#
;#		1.0 | 19/01/2016 | F.POSE | Original									#
;#		1.0 | 20/01/2016 | F.POSE | Agregué la función que inicializa la pag.	#
;#		2.0 | 21/01/2016 | F.POSE | Funciones de paginación terminadas			#
;#		2.1 | 27/01/2016 | F.POSE | Pagino función servicio de sistema y tss	#
;#		3.0 | 03/02/2016 | F.POSE | paginacion.asm completo (No modificar)		#
;#		6.0 | 11/02/2016 | F.POSE | FUNCIONA									#
;#																				#
;################################################################################

;################################################################################
;							Sección: functions
;################################################################################

SECTION .functions

;################################################################################
;	Función: Activar paginación
;################################################################################

ActivatePaging:
	
	; Activo PAE (Bit 5 del registro CR4)
	mov	eax, cr4         
	or	eax, 0x00000020	
	mov	cr4, eax
	
	; Cargo CR3 con la dirección base de la tabla de punteros a directorio de páginas
	mov	eax, DirPDPTE
	mov	cr3, eax		
	
	; Activo paginación
	mov eax, cr0		
	or  eax, 80000000h
	mov cr0, eax		
	
	ret

;################################################################################
;	Función: Inicializar paginación
;################################################################################

InitializePage:


; Primer nivel - Tabla de Punteros a Directorio de Páginas

	mov eax, DirPDPTE			; Dirección base de la PDPTE
	; Armo el descriptor
	mov	dword[eax],DirPDE 		; Cargo la dirección de PDE 
	or	dword[eax],PermisosDTP	; 0x01 
	mov	dword[eax+4],0x00000000	; Parte alta del registro 0's
	
			
; Segundo nivel - Directorio de Tablas de Páginas

	mov eax,DirPDE	; Dirección base de la PDE (Dir. de Tablas)
	; Armo el descriptor de Tabla 1
	mov dword[eax],DirPTE1		; Cargo la dirección de TP1
	or  dword[eax],Tp1Permisos 	; 0x07
	mov dword[eax+4],0x00000000	; Parte alta del registro 0's
	
	add eax,8
	
	; Armo el descriptor de Tabla 2
	mov dword[eax],DirPTE2		; Cargo la dirección de TP2
	or  dword[eax],Tp2Permisos	; 0x07
	mov dword[eax+4],0x00000000	; Parte alta del registro 0's


; Traducción del árbol de paginación

	mov eax, DirPTE2 + 0x480
	mov dword[eax],DirPDPTE
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000
	
	add eax,8

	mov dword[eax],DirPDE
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

	add eax,8

	mov dword[eax],DirPTE1
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000
	
	add eax,8

	mov dword[eax],DirPTE2
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000


	mov eax, DirPTE1 + 0x800
	mov dword[eax],_sys_tables
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000


; 	Tercer nivel - Tablas de Páginas	

;	Tabla de páginas 1: 0x00292000
	
; Páginas: .init32 -> 0x000F4000 (0x0F4)

	mov eax, DirPTE1 + 0x7A0
	mov dword[eax],Pag1Init32
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

;	add eax,8
	
;	mov dword[eax],Pag2Init32
;	or  dword[eax],PermisosUsuario
;	mov dword[eax+4],0x00000000	
	
; 0x000F4000: sys_tables ->  0x00100000 (0x100) 

	mov eax, DirPTE1 + 0x800
	mov dword[eax],Pag1SysTables 
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

;	add eax,8
	
;	mov dword[eax],Pag2SisTables 
;	or  dword[eax],PermisosUsuario
;	mov dword[eax+4],0x00000000

; Páginas: .stackE -> 0x00140000 (0x140) 

	mov eax, DirPTE1 + 0xA00
	mov dword[eax],Pag1Stack 
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

	add eax,8
	
	mov dword[eax],Pag2Stack 
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

; Páginas: .code_main -> 0x00150000 (0x150) 

	mov eax, DirPTE1 + 0xA80
	mov dword[eax],Pag1CodeMain 
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

;	add eax,8
	
;	mov dword[eax],Pag2CodeMain 
;	or  dword[eax],PermisosUsuario
;	mov dword[eax+4],0x00000000

; Páginas: .tss1  -> 0x00190000 (0x190)

	mov eax, DirPTE1 + 0xC80
	mov dword[eax],PagTss1 
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

; Páginas: .dataE -> 0x00200000 (0x200)

	mov eax, DirPTE2  
	mov dword[eax],Pag1Data 
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

;	add eax,8
	
;	mov dword[eax],Pag2Data 
;	or  dword[eax],PermisosUsuario
;	mov dword[eax+4],0x00000000

; Páginas: .bssE -> 0x00210000 (0x210)

	mov eax, DirPTE2 + 0x80
	mov dword[eax],Pag1Bss
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

;	add eax,8
	
;	mov dword[eax],Pag2Bss 
;	or  dword[eax],PermisosUsuario
;	mov dword[eax+4],0x00000000

; Páginas: .function -> 0x00230000 (0x230)

	mov eax, DirPTE2 + 0x180
	mov dword[eax],Pag1Function
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000


; Páginas: .DEHandler -> 0x00250000 (0x250) 

	mov eax, DirPTE2 + 0x280
	mov dword[eax],Pag1DeHandler
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000
	
; Páginas: .UDHandler -> 0x00251000 (0x251) 

	mov eax, DirPTE2 + 0x288
	mov dword[eax],Pag1UdHandler
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

; Páginas: .DFHandler -> 0x00252000 (0x252) 

	mov eax, DirPTE2 + 0x290
	mov dword[eax],Pag1DfHandler
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000
	
; Páginas: .GPHandler ->  0x00253000 (0x253) 

	mov eax, DirPTE2 + 0x298
	mov dword[eax],Pag1GpHandler
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000
	
; Páginas: .PFHandler -> 0x00254000 (0x254)

	mov eax, DirPTE2 + 0x2A0
	mov dword[eax],Pag1PfHandler
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000
	
; Páginas: .TimerHandler -> 0x00270000 (0x270)

	mov eax, DirPTE2 + 0x380
	mov dword[eax],Pag1Timer
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x00000000

; Páginas: .keyboardHandler -> 0x00271000 (0x271) 

	mov eax, DirPTE2 + 0x388
	mov dword[eax],Pag1Keyboard
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x000000000
	
; Páginas: .ServicioSistema -> 0x00272000 (0x272) 

	mov eax, DirPTE2 + 0x390
	mov dword[eax],Pag1ServicioSistema
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x000000000
	
; Páginas: Buffer de video -> 0x00280000 

	mov eax, DirPTE2 + 0x400
	mov dword[eax],VGA_RAM
	or  dword[eax],PermisosUsuario
	mov dword[eax+4],0x000000000
	
; Vuelvo al programa

	ret

;/* ----------- Fin del archivo ----------- */
