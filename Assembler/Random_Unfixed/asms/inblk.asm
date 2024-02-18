
;Demo program to open and move a screen
movescreen  	equ	 -162
openscreen  	equ	 -198
openwindow	equ	 -204
closewindow	equ	 -72
closescreen 	equ	 -66
closelibrary 	equ	 -414
openlib     	equ	 -408      ;open library
execbase    	equ	  4        ;EXEC base address
availfonts	equ	 -36
opendiskfont	equ	 -30
setfont		equ	 -66
closefont	equ	 -78
scrollraster	equ	 -396
viewportaddress equ	-300 
setApen		equ	-342

text		equ 	-216

joy2        	equ	 $dff00c   ;joystick 2 Data
fire        	equ	 $bfe001   ;fire button 2:Bit 7
setrgb4     	equ 	 -288
scrollval	equ	1




run:
        bsr     openint         ;Open library
        bsr	opendflib
        bsr     scropen         ;Open Screen
	bsr	openwin

	move.l	windowhd,a0
	move.l	intbase,a6
	jsr	viewportaddress(a6)
	move.l	a0,viewport

	bsr	openfont

	

       move.l  #0,d0           ;pen
       move.l  #0,d1           ;red
       move.l  #0,d2           ;green
       move.l  #0,d3           ;blue
       move.l  viewport,a0     ;Get Pointer to View Port
       move.l  gfxbase,a6      ;get grapics base
       jsr     setrgb4(a6)     ;set a color registor

       move.l  #2,d0           ;pen
       move.l  #10,d1           ;red
       move.l  #10,d2           ;green
       move.l  #10,d3           ;blue
       move.l  viewport,a0     ;Get Pointer to View Port
       move.l  gfxbase,a6      ;get grapics base
       jsr     setrgb4(a6)     ;set a color registor

       move    joy2,d6         ;Save Joystick Info


	bsr	BlockStart
;	lea	credits(pc),a0
;	bsr	setupcoor
;	bsr	setcolor

loop:
	bsr	scrmove

	sub.l	#scrollval,d1

	cmp.w	#175,d1
	ble	gohere
;	bsr	scrolltext
gohere:
;	cmp.w	d3,d1		;check y coor with count
;	bge.s	no_notext
	
;	bsr	setupcoor
;	bsr	setcolor
	bsr	BlockStart
	cmp.w	#0,d1
	beq	ende

;	bsr	changefont

no_notext:
        tst.b   fire            ;Test Fire Button
        bpl     ende            ;Press Down:Done

        bra     loop

setupcoor:
	move.w	(a0),d0		;get x
	move.w	2(a0),d1	;get y
	move.l	4(a0),d3	;count
	move.w  8(a0),d2	;color
	move.b	d2,color
	move.l	10(a0),textname	;save name
	add.l	#14,a0	
	rts

setcolor:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d2,d0
	move.l	rastport,a1
	move.l	gfxbase,a6
	jsr	setApen(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

changefont:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	myfont24,a0
	move.l	myfont15,a1
	move.l	a1,myfont24
	move.l	a0,myfont15
	move.l	rastport,a1
	move.l	gfxbase,a6
	jsr	setfont(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

scrolltext:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	rastport,a0
	lea	mytext,a1
;	move.l	#70,d0		; x coordinates
;	move.l	ycoor,d1	; y coordinates
        move.l  intbase,a6      ;Intuition base in A6
	jsr	text(a6)
;	sub.l	#1,ycoor
	movem.l	(sp)+,d0-d7/a0-a6
	rts
scrmove:
	movem.l	d0-d7/a0-a6,-(sp)
        move.l  gfxbase,a6      ;Intuition base in A6
        move.l  rastport,a1     ;Screen Handle in A0
	move.l	#0,d2
	move.l	#0,d3
	move.l	#320,d4
	move.l	#200,d5
	move.l	#0,d0
	move.l	#scrollval,d1		;scroll amount
        jsr     scrollraster(a6)  ;And Move
	
	movem.l	(sp)+,d0-d7/a0-a6

       rts                     ;Done



*****************************************************************
*		Place Blocks  on screen	              		*
*****************************************************************
; a2 = area to place save data
; x = d5 x coordinates
; y = d6 y coordinates

BlockStart:

	move.l	#200,d5		; Set x start value
	move.l	#100,d6		; Set y start value
	move.l	#1,accros	; how many boxes to draw accross the screen
	move.l	#1,down	; how many boxes down
	move.l	#50,count	; this is just a pre-caution so there is'nt 
	lea	table,a5	; an endless loop.

PlaceBlock:

;	move.b	(a5)+,on_off	; Load value from screen table
;	cmp.b	#2,on_off	; if its a 2 it is the end of screen
;	beq	out		; so quit
;	cmp.b	#0,on_off	; if its a 0 then put the block down
;	beq	Pb2		; and continue
;	add.l	#30,d5		; if its not, skip 1 block and continue
;	sub.l	#1,accros	; subtract 1 from count of 10 accross
;	bra 	PlaceBlock	; loop back
;Pb2:
	
	movem.l d0-d7/a0-a6,-(sp)
	move.l	#2,d4
	lea 	bitplane1(pc),a3

getblock2:
	 move.l  (a3)+,a1
	movem.l	d5-d6,-(sp)

	move.l	d6,d0
        add.l   #16,d0		; how many bytes long
	move.l	d0,d3
	move.l	#16,d0

noblocking:

	move.l	d5,d7
	and.l	#7,d7
	lsr.l	#3,d5
        add.l   d5,a1
	move.w	d6,d1
	mulu.w	#40,d6
	add.l	d6,a1
        movem.l	(sp)+,d5-d6

getblock:
	move.l	#3,d3
	
	cmp.w	#158,d1
	move.w 	#16,d0

make:
	move.w 	#17,d1
        move.l  #16,d0
	
placeblock2:
        move.b  (a2)+,(a1)+      
	dbra	d3,placeblock2

	move.l	#3,d3
        add.l   #36,a1          ;move plane pointer down one scan line

	cmp.w	#0,d1
	sub.w	#1,d1
        dbra    d0,placeblock2

kickblock2:        

	clr.l	d2
	move.w	d0,d2
	lsl.w	#2,d2
	dbra	d4,getblock2
	movem.l (sp)+,d0-d7/a0-a6
	
	add.l	#30,d5		; add 30 lines to block location
	sub.l	#1,accros	; subtract 1 from count accross
	bgt	PlaceBlock	

	add.l	#19,d6		; add 19 to lines down
	move.l	#10,accros	; start of with 10 blocks again
	move.l	#5,d5		; starting location of first block
	sub.l	#1,count	; subtract 1 from count for safety
	beq	out		; if it gone to far exit
	sub.l	#1,down		; subtract from 1 line down being used
	bgt	PlaceBlock


out:
	rts			; Return



ende:
	bsr	closewin
       bsr     scrclose        ;close screen
	bsr	closeflib
       bsr     closeint        ;close intuition
	       
	rts                     ;Done !
openint:
       move.l  execbase,a6     ;EXEC base address
       lea     intname,a1      ;name of intuition library
       jsr     openlib(a6)     ;Open intuition
       move.l  d0,intbase      ;Save Intuition base address
       rts
openwin:
	move.l	intbase,a6
	lea	window(pc),a0
	jsr	openwindow(a6)
	move.l	d0,windowhd
	move.l	d0,a1
	move.l	50(a1),rastport
	rts

closewin:
	move.l intbase,a6
	move.l	windowhd,a0
	jsr 	closewindow(a6)
	rts





closeint:
       move.l  execbase,a6     ;*close Intuition
       move.l  intbase,a1      ;intuition base address in A1
       jsr     closelibrary(a6);close intuition
       rts                     ;Done
scropen:
       move.l  intbase,a6      ;Intuition base address in A6
       lea     screen_defs,a0  ;Pointer to Table
       jsr     openscreen(a6)  ;OPen
       move.l  d0,screenhd     ;Save Screen Handle
       move.l  d0,a0           ;get screen pointer ready
       move.l  $c0(a0),bitplane1       ;get pointer to bit plane # 1
       move.l  $c4(a0),bitplane2       ;get pointer to bit plane # 2
;       move.l  $2c(a0),viewport        ;get pointer to view port
       move.l  execbase,a6     ;EXEC base address
       lea     gfxname,a1      ;name of graphics library
       jsr     openlib(a6)     ;Open graphics library
       move.l  d0,gfxbase      ;Save graphics base address
       rts                     ;Return to Main Program
scrclose:
       move.l  intbase,a6      ;Intuition base address in A6
       move.l  screenhd,a0     ;Screen Handle in A0
       jsr     closescreen(a6) ;And Move
       rts                     ;Done

opendflib:
	move.l	execbase,a6
       lea     diskfname,a1      ;name of intuition library
       jsr     openlib(a6)     ;Open intuition
       move.l  d0,fontbase      ;Save Intuition base address
       rts

closeflib:
       move.l  execbase,a6     ;*close Intuition
       move.l  fontbase,a1      ;intuition base address in A1
       jsr     closelibrary(a6);close intuition
       rts                     ;Done





openfont:
	lea	textattr(pc),a0
	move.l	fontbase,a6
	jsr	opendiskfont(a6)
	move.l	d0,myfont24
	lea	textattr2(pc),a0
	move.l	fontbase,a6
	jsr	opendiskfont(a6)
	move.l	d0,myfont15
	nop
	move.l	d0,a0
	move.l	rastport,a1
	move.l	gfxbase,a6
	jsr	setfont(a6)
	rts



screen_defs:
x_pos:         dc.w    0       ;x-position
y_pos:         dc.w    0       ;y-position
width:         dc.w    320     ;width
height:        dc.w    200     ;height
depth:         dc.w    4       ;Number of Bit Planes 2
detail_pen:    dc.b    0       ;Text Colour  equ  White
block_pen:     dc.b    1       ;Background Color  equ  Red
view_modes:    dc.w    2       ;Representation Mode
screen_types:  dc.w    15      ;Screen Type:Custom Screen
font:          dc.l    0       ;Standard Character Set
title:         dc.l    0       ;Pointer to title text
gadgets:       dc.l    0       ;No gadgets
bitmap:        dc.l    0       ;No Bit Map
intbase:       dc.l    0       ;Base Address of Intuition
;screenhd:      dc.l    0       ;Screen Handle
intname:       dc.b    'intuition.library',0
       cnop 0,2
gfxname:       dc.b    'graphics.library',0
       cnop 0,2

sname:         dc.b    'Our Screen',0 ;Screen Title
       cnop 0,2
diskfname:       dc.b    'diskfont.library',0
       cnop 0,2
myfont24:		dc.l	0
myfont15:		dc.l	0

mytext:
color:		dc.b	1,0
		dc.b	1
		dc.w	16
		dc.w	2
		dc.l	0
textname:	dc.l	0
		dc.l	0

;structure font contents

textattr:
		dc.l	helvetica
		dc.w	24
		dc.b	0
		dc.b	2

textattr2:
		dc.l	helvetica
		dc.w	15
		dc.b	0
		dc.b	2

helvetica:

		dc.b	'helvetica.font',0
		dc.l	0


fontbase:	dc.l	0

rastport:      dc.l    0
viewport:      dc.l    0
gfxbase:       dc.l    0
ycoor:		dc.l	200
bitplane1:     dc.l    0
bitplane2:     dc.l    0

numc:		dc.l	13
windowhd:	dc.l	0
window:		dc.w	0,0
		dc.w	320,200
		dc.b	0,1
		dc.l	0
		dc.l	$1800		; active and borderless
		dc.l	0
		dc.l	0
		dc.l	0 ;scroll
screenhd:	dc.l	0
		dc.l	0
		dc.w	0,0
		dc.w	320,200
		dc.w	$f

scroll:		dc.b	' ',0





man:           dc.b    1,$80,2,$40,1,$80,7,$e0,$d,$b0,9,$90
               dc.b    $11,$88,3,$c0,2,$40,6,$60,$c0,$30,$18,$18

credit1:	dc.b	'Writen By',0
credit2:	dc.b	'Sean Godsell',0
credit3:	dc.b	'and',0
credit4:	dc.b	'Franco Gaetan',0
credit5:	dc.b	'See You',0
credit6:	dc.b	'Soon',0
credit7:	dc.b	'A Lab Boys',0
credit8		dc.b	' ',0
credit9		dc.b	'Production',0

credits:
		dc.w	104,200		;x,y
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit1		;title

		dc.w	60,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit2

		dc.w	120,200
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit3

		dc.w	60,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit4

		dc.w	112,200
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit5

		dc.w	115,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit6

		dc.w	104,200		;x,y
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit7		;title

		dc.w	80,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit9

		dc.w	120,200
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit8

		dc.w	83,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit8

		dc.w	104,200		;x,y
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit1		;title

		dc.w	60,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit2

		dc.w	120,200
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit3

		dc.w	60,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit4

		dc.w	112,200
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit5

		dc.w	115,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit6

		dc.w	104,200		;x,y
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit7		;title

		dc.w	80,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit9

		dc.w	120,200
		dc.l	175		;distance apart
		dc.w	2		;color setting
		dc.l	credit8

		dc.w	83,200
		dc.l	80		;distance apart
		dc.w	1		;color setting
		dc.l	credit8






		dc.l	0		;end the table
		dc.l	0

       end





