bits 32

%define	surface_size 	90000
%define	surface_pixel 	3
%define	surface_stride	1800
%define	surface_w		600
%define	surface_h		50
%define	header_size		54
%define	barw_limit		10
%define	barh_limit		25
%define	encode_istart	105
%define	encode_start	0x1904
%define	encode_stop		0x40A4

section .data

encode:	dd	0x1544, 0x1454, 0x554, 0x2510, 0x1610, 0x1520, 0x2150, 0x1250, 0x1160, 0x2114, 0x1214, 0x1124, 0x1940, 0x1850, 0x950, 0x1580, 0x1490, 0x590, 0x194, 0x1814, 0x914, 0x1184, 0x1094, 0x848, 0x1508, 0x1418, 0x518, 0x1148, 0x1058, 0x158, 0x2444, 0x644, 0x464, 0x2600, 0x2420, 0x620, 0x2240, 0x2060, 0x260, 0x2204, 0x2024, 0x224, 0x2840, 0xA40, 0x860, 0x2480, 0x680, 0x4A0, 0x488, 0xA04, 0x824, 0x2084, 0x284, 0x884, 0x2408, 0x608, 0x428, 0x2048, 0x248, 0x68, 0xC8, 0x314, 0x2C, 0x3500, 0x1700, 0x3410, 0x710, 0x1430, 0x530, 0x3140, 0x1340, 0x3050, 0x350, 0x1070, 0x170, 0x134, 0x3014, 0x8C, 0x1034, 0xE0, 0x1D00, 0x1C10, 0xD10, 0x11C0, 0x10D0, 0x1D0, 0x110C, 0x101C, 0x11C, 0xC44, 0x4C4, 0x44C, 0x2C00, 0xE00, 0xC20, 0x20C0, 0x2C0, 0x200C, 0x20C, 0xC80, 0x8C0, 0xC08, 0x80C, 0x1304, 0x3104, 0x1904, 0x40A4

surface:	dd 0
str_length:	dd 0
str_checks: dd 0
str_width:	dd 0

extern _debug

section .text
global encode128
global _encode128

%define arg_surface 	ebp+8
%define arg_bar_w 		ebp+12
%define arg_string		ebp+16
encode128:
_encode128:
	push    ebp
	mov     ebp, esp
	push    ebx
	push    esi
	push    edi
	
	mov		eax, [arg_surface]
	mov		[surface], eax
	
	push	dword [arg_string]
	call	prepare_string
	add		esp, 4
	test	eax, eax
	jnz		encode_return
	
	mov		eax, [str_length]
	xor		edx, edx
	mov		ecx, [arg_bar_w]
	mul		ecx
	mov		[str_width], eax
	mov		eax, 35
	xor		edx, edx
	mul		ecx
	add		[str_width], eax

	push	dword barh_limit
	push	dword [arg_bar_w]
	push	dword [arg_string]
	call	render_string
	add		esp, 12
	
	xor		eax, eax
encode_return:
	pop     edi
	pop     esi
	pop     ebx
	mov     esp, ebp
	pop		ebp
	retn



%define arg_string 		ebp+8
%define arg_bar_w 		ebp+12
%define arg_bar_h 		ebp+16
render_string:
	%define var_quiet 	ebp-4
	%define var_x 		ebp-8
	%define var_y 		ebp-12
	%define var_i 		ebp-16
	push    ebp
	mov     ebp, esp
	push    ebx
	push    esi
	push    edi
	sub		esp, 16
	
	xor		edx, edx
	mov		eax, 10
	mov		ecx, [arg_bar_w]
	mul		ecx
	mov		[var_quiet], eax
	
	mov		eax, surface_w
	shr		eax, 1
	mov		ecx, [str_width]
	shr		ecx, 1
	sub		eax, ecx
	mov		[var_x], eax
	
	mov		eax, surface_h
	shr		eax, 1
	mov		ecx, [arg_bar_h]
	shr		ecx, 1
	sub		eax, ecx
	mov		[var_y], eax
	
	mov		eax, [var_x]
	cmp		eax, [var_quiet]
	jl		render_string_error_quiet

	mov		[str_checks], dword encode_istart

	push	dword [arg_bar_h]
	push	dword [arg_bar_w]
	push	dword [var_y]
	push	dword [var_x]
	push	dword encode_start
	call	render_symbol
	add		esp, 20
	mov		[var_x], eax
	
	mov		[var_i], dword 0
render_string_loop:
	mov		eax, [var_i]
	cmp		eax, [str_length]
	jge		render_string_done
	
	push	dword [arg_bar_h]
	push	dword [arg_bar_w]
	push	dword [var_y]
	push	dword [var_x]
	mov		esi, [arg_string]
	add		esi, eax
	xor		edx, edx
	mov		dl, [esi]
	sub		edx, 32
	shl		edx, 2
	mov		eax, [encode+edx]
	push	eax
	call	render_symbol
	add		esp, 20
	mov		[var_x], eax
	
	mov		esi, [arg_string]
	add		esi, [var_i]
	xor		edx, edx
	xor		eax, eax
	mov		al, [esi]
	sub		eax, 32
	mov		ecx, [var_i]
	inc		ecx
	mul		ecx
	add		[str_checks], eax
	
	inc		dword [var_i]
	jmp		render_string_loop
render_string_done:

	push	dword [arg_bar_h]
	push	dword [arg_bar_w]
	push	dword [var_y]
	push	dword [var_x]	
	mov		eax, [str_checks]
	xor		edx, edx
	mov		ecx, 103
	div 	ecx
	shl		edx, 2
	mov		eax, [encode+edx]
	push	eax
	call	render_symbol
	add		esp, 20
	mov		[var_x], eax
	
	push	dword [arg_bar_h]
	push	dword [arg_bar_w]
	push	dword [var_y]
	push	dword [var_x]
	push	dword encode_stop
	call	render_symbol
	add		esp, 20
	mov		[var_x], eax
	
	xor		eax, eax
render_string_return:
	add		esp, 16
	pop     edi
	pop     esi
	pop     ebx
	mov     esp, ebp
	pop		ebp
	retn
render_string_error_quiet:
	mov		eax, 3
	jmp		render_string_return


%define arg_symbol 		ebp+8
%define arg_x 			ebp+12
%define arg_y			ebp+16
%define arg_bar_w 		ebp+20
%define arg_bar_h 		ebp+24
render_symbol:
	%define var_bounds 	ebp-4
	%define var_i 		ebp-8
	%define var_w 		ebp-12
	push    ebp
	mov     ebp, esp
	push    ebx
	push    esi
	push    edi
	sub		esp, 12	
	mov		eax, 6
	cmp		[arg_symbol], dword encode_stop
	jne		render_symbol_normal
	inc		eax
render_symbol_normal:
	mov		[var_bounds], eax
	mov		[var_i], dword 0
render_symbol_loop:
	mov		eax, [var_i]
	cmp		eax, [var_bounds]
	jge		render_symbol_done		
	mov		eax, [arg_symbol]
	shr		eax, 2
	mov		[arg_symbol], eax
	and		eax, 3
	inc		eax
	xor		edx, edx
	mov		ecx, [arg_bar_w]
	mul		ecx
	mov		[var_w], eax
	mov		eax, [var_i]
	and		eax, 1
	test	eax, eax
	jnz		render_symbol_skip	
	mov		eax, [arg_y]
	add		eax, [arg_bar_h]
	push	eax
	mov		eax, [arg_x]
	add		eax, [var_w]
	push	eax
	push	dword [arg_y]
	push	dword [arg_x]
	call	rectangle
	add		esp, 16
render_symbol_skip:
	mov		eax, [arg_x]
	add		eax, [var_w]
	mov		[arg_x], eax
	inc		dword [var_i]
	jmp		render_symbol_loop
render_symbol_done:
	mov		eax, [arg_x]
	add		esp, 12
	pop     edi
	pop     esi
	pop     ebx
	mov     esp, ebp
	pop		ebp
	retn


	
%define arg_x1 	ebp+8
%define arg_y1 	ebp+12
%define arg_x2	ebp+16
%define arg_y2 	ebp+20
rectangle:
	%define var_x 	ebp-4
	%define var_y 	ebp-8
	push    ebp
	mov     ebp, esp
	push    ebx
	push    esi
	push    edi
	sub		esp, 8
	mov		eax, [arg_x1]
	mov		ecx, surface_pixel
	xor		edx, edx
	mul		ecx
	mov		[arg_x1], eax
	mov		eax, [arg_x2]
	mov		ecx, surface_pixel
	xor		edx, edx
	mul		ecx
	mov		[arg_x2], eax
	mov		eax, [arg_y1]
	mov		ecx, surface_stride
	xor		edx, edx
	mul		ecx
	mov		[arg_y1], eax
	mov		eax, [arg_y2]
	mov		ecx, surface_stride
	xor		edx, edx
	mul		ecx
	mov		[arg_y2], eax
	mov		eax, [arg_y1]
	mov		[var_y], eax
rectangle_y_loop:
	mov		eax, [var_y]
	cmp		eax, [arg_y2]
	jge		rectangle_y_done
	mov		eax, [arg_x1]
	mov		[var_x], eax
rectangle_x_loop:
	mov		eax, [var_x]
	cmp		eax, [arg_x2]
	jge		rectangle_x_done
	add		eax, [var_y]
	add		eax, [surface]
	mov		[eax], byte 0
	mov		[eax+1], byte 0
	mov		[eax+2], byte 0
	add		[var_x], dword surface_pixel
	jmp		rectangle_x_loop
rectangle_x_done:
	add		[var_y], dword surface_stride
	jmp		rectangle_y_loop
rectangle_y_done:
	add		esp, 8
	pop     edi
	pop     esi
	pop     ebx
	mov     esp, ebp
	pop		ebp
	retn



%define arg_string		ebp+8
prepare_string:
	%define var_temp 	ebp-4
	push    ebp
	mov     ebp, esp
	push    ebx
	push    esi
	push    edi
	sub		esp, 4
	mov		[str_checks], dword encode_istart
	mov		esi, [arg_string]
	mov		edi, [arg_string]
prepare_string_loop:
	xor		eax, eax
	mov		al, [esi]
	test	al, al
	jz		prepare_string_done
	cmp		al, 48
	jl		prepare_error_symbols
	cmp		al, 57
	jg		prepare_error_symbols	
	sub		eax, 48
	xor		edx, edx
	mov		ecx, 10
	mul		ecx	
	mov		[var_temp], eax
	inc		esi
	xor		eax, eax
	mov		al, [esi]
	cmp		al, 48
	jl		prepare_error_symbols
	cmp		al, 57
	jg		prepare_error_symbols
	test	al, al
	jz		prepare_error_length
	sub		al, 48
	add		eax, [var_temp]
	add		eax, 32
	mov		[edi], al
	inc		esi
	inc		edi
	jmp		prepare_string_loop
prepare_string_done:
	mov		[edi], byte 0
	sub		edi, [arg_string]
	mov		[str_length], edi
	xor		eax, eax
prepare_return:
	add		esp, 4
	pop     edi
	pop     esi
	pop     ebx
	mov     esp, ebp
	pop		ebp
	retn
prepare_error_symbols:
	mov		eax, 1
	jmp		prepare_return
prepare_error_length:
	mov		eax, 2
	jmp		prepare_return