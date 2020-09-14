;==========================================================================;
; Name: main.asm
; Desc: Program entry point.
; 
; Ext Desc: This program is a small bootsector render demo. No graphics
; apis are used here, instead we directly play with the framebuffer &
; implement our own little graphics pipeline
;
; Author: Jeremy Lorelli jeremy.lorelli.1337@gmail.com
; Date: March 1st, 2020
;
; Stack size: 16kb
; Segments:
;  ss	-	0x0
;  ds	-	0xFFFF (64kb)
;  cs	-	0x7C00
;
; Globals:
;  depth buffer   - 2kb, 8-bit depth. Address space: 0x1000-0x17d0
;  camrot         - Camera rotation. Segment: GLOBAL_SEG. Offset: 0. Size: 3 bytes (1 byte for pitch, yaw, roll)
;  campos         - Camera position. Segment: GLOBAL_SEG. Offset: 3. Size: 6 bytes (2 bytes for x, y, z)
;  projmat        - 4x4 projection matrix. Segment: GLOBAL_SEG. Offset: 9. Size: 32 (2 bytes per element, 4x4)
;
; Other Info:
; coords -   16-bit signed integers, 0,0,0 is camera origin
; units  -   cm
;
; Depth Buffer Info:
;  The depth buffer is a 8-bit monochrome buffer that represents depth in
;  an image. The value 0xff represents the smallest distance from the cam
;  The depth buffer is the same resolution as the screen, 80x25, and it is
;  2kb in size.
;
; Revisions:
;       2020-May-28th:
;               Initial revision
;       2020-Sep-13th:
;               Rework implementation 
;       
;==========================================================================;
BITS 16

ORG 0x7C00

;==========================================================================;
; Location constants
;==========================================================================;
%define GLOBAL_SEG              0x4000
%define DEPTH_BUFFER_SEG	0x1000 
%define BACK_BUFFER_SEG		0x2000 
%define FRAME_BUFFER_SEG	0xb800 
;==========================================================================;

;==========================================================================;
; Misc. Constants
;==========================================================================;
%define FOV                     90 ; Field-of-view in degrees
%define TURN_SPEED              1  ; Number of degrees to turn when an arrow key is pressed
%define MOVE_SPEED              30 ; Movement speed when UP or DN is pressed
;==========================================================================;

;==========================================================================;
; Color Constants
;==========================================================================;
%define COLOR_BLACK     0x0 
%define COLOR_BLUE      0x1 
%define COLOR_GREEN     0x2 
%define COLOR_CYAN      0x3 
%define COLOR_RED       0x4 
%define COLOR_MAGENTA   0x5 
%define COLOR_BROWN     0x6 
%define COLOR_GRAY      0x7 
%define COLOR_DGRAY     0x8 
%define COLOR_BBLUE     0x9 
%define COLOR_BGREEN    0xA 
%define COLOR_BCYAN     0xB 
%define COLOR_BRED      0xC 
%define COLOR_BMAGENTA  0xD 
%define COLOR_YELLOW    0xE 
%define COLOR_WHITE     0xF 
%define MAKE_COLOR(bg, fg, c) ((bg << 12) | (fg << 8) | (c)) 
;==========================================================================;

_boot:
	; select stack, 16kb
	mov ax, 0x0
	mov ss, ax
	mov sp, 16384
	mov bp, 16384
	mov ds, ax

	; Flush the framebuffer with white
	mov ax, MAKE_COLOR(COLOR_BBLUE,COLOR_WHITE,' ')
	mov bx, FRAME_BUFFER_SEG 
	mov cx, 80*25*2
	call flush_buffer
	
	; Flush the depth buffer with black
	mov ax, MAKE_COLOR(COLOR_BLACK,COLOR_WHITE,' ')
	mov bx, DEPTH_BUFFER_SEG 
	mov cx, 2000
	call flush_buffer

.render_loop: 

	; Update the projection matrix, used to apply transforms to the verticies
        call build_proj_matrix 



	jmp .render_loop 

;==========================================================================;
; Draws a quad centered at the specified position with the specified size
; Params:
;   bp-2 - origin x
;   bp-4 - origin y
;   bp-6 - origin z
;   bp-8 - length/width/height
;   bp-10 - rotational position, bits 0-4: rotation x, bits 5-9: rotation y, bits 10-14: rotation z
;   bp-12 - color, lowest bit used, see vga colors table
;   bp-14 - draw mode, 1 for tris, 0 for wireframe 
;==========================================================================;
draw_quad:
	push bp
	mov bp, sp 

	pop bp
	ret 


;==========================================================================;
; Builds the projection matrix which is used to transform all verticies
; Params:
;       None
;==========================================================================;
build_proj_matrix:
        push bp
        mov bp, sp
        
        ; Switch to the globals segment 
        mov bx, GLOBAL_SEG
        mov ds, bx 

        ; 


        pop bp 
        ret 

;==========================================================================;
; Flushes the buffer with the value in ax
; Params:
;   bx - buffer base addr (must be aligned to 2-byte bounds!) 
;   cx - buffer size
;==========================================================================;
flush_buffer:
	pusha 
	xor si, si 
	mov ds, bx 
	.flush_screen_loop:
	mov word [ds:si], ax 
	add si, 2
	cmp si, cx 
	jle .flush_screen_loop 
	popa
	ret

;==========================================================================;
; Dot product between two vectors
; Params:
;   ax - x1
;   bx - y1
;   cx - z1
;   dx - x2
;   si - y2
;   di - z2
; returns:
;   ax - dot product
;==========================================================================;
dot_product:
	imul ax, dx
	imul bx, si
	imul cx, di
	add ax, bx
	add ax, cx
	ret 

;==========================================================================;
; Integral linear interpolation.
; This will clobber ax, bx and cx
; Params:
;  ax - i1
;  bx - i2
;  cx - bias
;==========================================================================;
lerpf:
	sub bx, ax
	imul cx, bx
	add ax, cx 
	ret 

;==========================================================================;
; Quick and dirty sine implementation. Not accurate at all. 
; Implemented by means of taylor series, as it doesn't require any translation
; tables or anything along those lines
; Params:
;  ax - Number to take the sine of. In degrees
;==========================================================================;
sin:
        ret 


;==========================================================================;
; Quick and dirty cosine implementation. Not accurate at all. 
; Implemented by means of taylor series, as it doesn't require any translation
; tables or anything along those lines
; Params:
;  ax - Number to take the cosine of. In degrees
;==========================================================================;
cos:
        ret 


;==========================================================================;
; Quick and dirty tangent implementation. Not accurate at all. 
; Implemented by means of taylor series, as it doesn't require any translation
; tables or anything along those lines
; Params:
;  ax - Number to take the tangent of. In degrees
;==========================================================================;
tan:
        ret 


;==========================================================================;
; Multiply a vector by a 4x4 matrix. This function will not modify the segment
; pointers.
; NOTE: This isn't actually mathematically "correct". Instead, we assume the magnitude
; of the 1x3 input vector to be 1.
; Params:
;  bx - Pointer to a 6 byte vector, or a 1x3 matrix.
;  dx - Pointer to a 4x4 matrix, which is 32 bytes in size. 
;==========================================================================;
mat4_mul_vec:
        push bp
        mov bp, sp 
        ; Save all registers
        pusha 
        mov [bp-2], dx 
.mul_loop:
        ; Note: 8 bytes per row
        ; COL #1
        mov cx, [bx]
        xor di, di 
.inner_mul:
        mov ax, cx 
        imul word ax, [bp-2]
        add [bx], ax 
        add word [bp-2], 2
        inc di 
        cmp di, 4
        jle .inner_mul 

        add bx, 2
        add word [bp-2], 2
        inc si 
        cmp si, 4
        jle .mul_loop  

        ; Restore previous state 
        popa 
        pop bp 
        ret 

_end:
	times 510-($-$$) db 0
	dw 0xAA55

