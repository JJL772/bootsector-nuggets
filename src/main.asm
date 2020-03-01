;
; load.asm
; Program loader
; 
; Jeremy Lorelli jeremy.lorelli.1337@gmail.com
; July 20th, 2019
;
; Stack size: 16kb
; Segments:
; ss	-	0x0
; ds	-	0xFFFF (64kb)
; cs	-	0x7C00
BITS 16

ORG 0x7C00

_boot:
	; select stack, 16kb
	mov ax, 0x0
	mov ss, ax
	mov sp, 16384
	mov bp, 16384
	mov ax, cs
	mov ds, ax

	; set video mode
	mov ah, 0
	mov al, 0x3
	int 0x10

	; set cursor pos
	mov ah, 2
	mov bh, 0
	mov dh, 0
	mov dl, 0
	int 0x10

	mov bx, 0
	mov ax, _header_string
	mov cx, 10
	call _draw_string

; Draws string pointed to by AX, length in CX
; Draws at coordinate BH (x) and BL (y)
_draw_string:
	mov si, ax
	mov bp, ax
	mov ax, cs
	mov es, ax
	mov ah, 0x13
	mov al, 0
	mov bx, 0
	mov dx, 0
	int 0x10
	ret

.loop:
	;mov si, ax
	push ax
	push bx
	push cx
	push dx

	; move cursor
	mov dx, bx
	mov ah, 2
	mov bh, 0
	int 0x10

	; draw
	mov ah, 0x0A
	lodsb
	;mov byte al, [si]
	mov bh, 0
	mov bl, 0xFF
	mov cx, 1
	int 0x10

	pop dx
	pop cx
	pop bx
	pop ax

	inc si
	inc bl
	dec cx
	cmp cx, 0
	jne .loop

	ret

_header_string: db	"Game ROM loader for 8086/8088", 0
_author_string: db	"Author: Jeremy Lorelli", 0
_date_string:	db 	"Version 1, July 2019", 0

_end:
	times 510-($-$$) db 0
	dw 0xAA55


