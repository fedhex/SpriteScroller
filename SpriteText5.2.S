
INIT:

* FONT ********************************

TXTl	equ	20	; TEXT lines

SPRh	equ	18*TXTl	; SPRITE height
SPRa	equ	8	; SPRITE amount

	include	dh2:startup.i
	incdir	cf0:

MAIN
***************************************

	move.w	#$4000,		$dff09a
	or.b	#%10000000,	$bfd100
	and.b	#%10000111,	$bfd100

	move.w	#$01a0,		$dff096

	lea.l	copperlist,	a1
	move.l	a1,		$dff080
	move.w	$dff088,	d7	
	move.w	#$81a0,		$dff096

	bsr.w	wait_raster


***************************************

	bsr.s	Set_Logo
	bsr.w	Set_Sprite
	bsr.w	Plot_Text


MAIN_loop:

;	bsr	Move_Sprite

	bsr.w	sprite_scroll

	bsr.w	Wait_raster

	btst	#6,		$bfe001
	bne.s 	MAIN_loop

***************************************

	move.w	#$0080,		$dff096

	move.l	$4,		a6
	move.l	156(a6),	a1
	move.l	38(a1),		$dff080

	move.w	#$8080,		$dff096

	move.w	#$c000,		$dff09a

	rts
	
	
***************************************


Set_Logo:

;	move.w	#$4200,		$dff100	; Number of Bitplanes	
	move.w	#$0081,		$dff08e	; Display Window Start
	move.w	#$ffc1,		$dff090	; Display Window Stop

	move.w	#$0000,		$dff102 ; Scroll register	
	move.w	#$003f,		$dff104 ; Video Priority
	move.w	#0,		$dff108 ; ODD Modulo
	move.w	#0,		$dff10a ; EVEN Modulo

	move.w	#$0038,		$dff092	; Data Fetch start
	move.w	#$00d0,		$dff094	; Data Fetch stop

	lea.l	Logo,		a1
	lea.l	BPL_pointer,	a2	

	move.l	a1,		d1
	addq.w	#2,		a2

	moveq	#4-1,		d0	; Number of Bitplanes

BPL_loop:
	swap	d1
	move.w	d1,		(a2)	; BPL High bits
	addq.w	#4,		a2

	swap	d1
	move.w	d1,		(a2)	; BPL Low bits
	addq.w	#4,		a2		

	add.l	#320/8*105,	d1
	dbf	d0,		BPL_loop
	
	rts

***************************************

Set_Sprite:

	lea.l	Spr1,		a1
	moveq	#2,		d2

	move.w	#SPRa-1,	d0		; SPRITE amount

Sprite_init:
	lea.l	Spr_Pointer,	a2
	move.l	a1,		d1

	swap	d1
	move.w	d1,		(a2,d2.w)	; SPRITE Point High bits
	addq.w	#4,		d2

	swap	d1
	move.w	d1,		(a2,d2.w)	; SPRITE Point Low bits
	addq.w	#4,		d2

	add.w	#(SPRh*32)/8+4,	a1		; Skip to next SPRITE
	dbf	d0,		Sprite_init

	sub.w	#((SPRh*32)/8)*8+4,a1		; Return to SPRITE 1	

;	add.w	#596,		a1		; 672 SPRITE Offset

	rts

***************************************

Text_Init:
	clr.w	(a3)

	lea.l	charcnt,	a3
	move.w	(a3),		d1
	addq.w	#1,		(a3)		; Next letter.

	lea.l	text,		a2
	clr.l	d2
	move.b	(a2,d1.w),	d2	 

	cmp.b	#42,		d2		; check for "*" (textend) 
	bne.s	notend

	clr.w	(a3)
;	move.b	#32,		d2		; " " after ended text.

	rts

**

Plot_Text:
	moveq	#10,		d6		; Lines of Text

Plot_TextLine:
	moveq	#SPRa-1,	d7		; Plot number of Chars. 
Plot_Char_l:

	bra.s	Text_init

notend:
	lea.l	convtab,	a3		
	move.b	(a3,d2.w),	d2		; ASCII Font offset.	
	asl.w	#1,		d2		; Shift to next Font letter.

	lea.l	font,		a3
	add.l	d2,		a3		; Point to letter.

	moveq	#18-1,		d0		; Height of Font.
Plot_Char:
	move.w	(a3),		(a1,d4.w)	; Copy Line of Font to SPRITE 
	add.l	#(32*16)/8,	a3		; Point to next Line of Font.
	add.w	#4,		d4		; Point to next Line of SPRITE.

	dbf	d0,		Plot_Char

	add.w	#(18*32/8)*(TXTl-1)+4,d4	; Next SPRITE 0,72,144,216,288

	dbf	d7,		Plot_Char_l

	sub.w	#(18*4)*8+(18*32/8)*(TXTl-1)*8+4,d4	; Return to Sprite 1

	add.w	#48,		d4		; Space Offset Between lines.

	dbf	d6,		Plot_Text

	sub.w	#48*10,		d4
	
	rts


***************************************

Sprite_Scroll:

	lea.l	scrollcnt,	a3
	cmp.w	#16,		(a3)		; Speed of text.
	bne.w	nochar


Nochar:
	sub.b	#1,		SPR1
	sub.b	#1,		SPR1+2
;	sub.b	#1,		SPR3
;	sub.b	#1,		SPR4
;	sub.b	#1,		SPR5
;	sub.b	#1,		SPR6
;	sub.b	#1,		SPR7
;	sub.b	#1,		SPR8			

	lea.l	scrollcnt,	a3
	addq.w	#1,		(a3)

	rts

Reset_Sprite:

	move.w	$0f0f,		$dff0182

	rts
	
***************************************

scrollcnt:
	dc.w	$0000

charcnt:
	dc.w	$0000

convtab:
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1f ;" "
	dc.b	$00
	dc.b	$00
	dc.b	$1b ;Ø
	dc.b	$1c ;Å
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1d ;,
	dc.b	$00 ;-
	dc.b	$1e ;.
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1a ;Æ
	dc.b	$00 ;A
	dc.b	$01 ;B
	dc.b	$02 ;C
	dc.b	$03 ;...
	dc.b	$04
	dc.b	$05
	dc.b	$06
	dc.b	$07
	dc.b	$08
	dc.b	$09
	dc.b	$0a
	dc.b	$0b
	dc.b	$0c
	dc.b	$0d
	dc.b	$0e
	dc.b	$0f
	dc.b	$10
	dc.b	$11
	dc.b	$12
	dc.b	$13
	dc.b	$14
	dc.b	$15
	dc.b	$16 ;....
	dc.b	$17 ;X
	dc.b	$18 ;Y
	dc.b	$19 ;Z
	dc.b	$00
	dc.b	$00
	dc.b	$00
	
text:
	dc.b	"ABCDEFGH"
	dc.b	"IJKLMNOP"
	dc.b	"QRSTUVWX"
	dc.b	"YZABCDEF"
	dc.b	"GHIJKLMN"
	dc.b	"OPQRSTUV"
	dc.b	"FED  HEX"
	dc.b	" EQUALS "
	dc.b	"FRIGGING"
	dc.b	"  JERK  " 
	dc.b	"********"


***************************************

TABLEl	equ	255

Move_Sprite:

	lea.l	Move_Count,	a0
	move.w	(a0),		d0
	add.w	#4,		(a0)	; Table count ( Curve Speed )
	
	cmp.w	#TABLEl,	d0	; Table length
	blt.s	Not_ended

	clr.w	d0
	clr.w	(a0)

Not_Ended:

	lea.l	CosSin_Tabel,	a0
	lea.l	Spr1,		a1

	moveq	#SPRa-1,		d7	; Number of SPRITES
.Loop:
	and.w	#TABLEl,	d0	; Table higher than 255=false
			
	move.b	(a0,d0.w),	d1
	move.b	d1,		(a1)
	add.b	#18,		d1	; Height of SPRITE
	move.b	d1,		2(a1)	
	addq.w	#4,		d0	; Offset between SPRITES.
	add.w	#76,		a1	; Skip to next SPRITE.
	dbf	d7,		.Loop	

	rts	

Move_Count:
	dc.b	$00

CosSin_tabel:
	dc.b $6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C,$6D,$6D,$6D,$6D,$6E,$6E,$6F,$6F
	dc.b $70,$70,$71,$71,$72,$72,$73,$74,$74,$75,$76,$77,$78,$78,$79,$7A
	dc.b $7B,$7C,$7D,$7E,$7F,$80,$81,$82,$83,$84,$85,$86,$87,$89,$8A,$8B
	dc.b $8C,$8D,$8F,$90,$91,$92,$94,$95,$96,$97,$99,$9A,$9B,$9C,$9E,$9F
	dc.b $A0,$A2,$A3,$A4,$A5,$A7,$A8,$A9,$AB,$AC,$AD,$AE,$B0,$B1,$B2,$B3
	dc.b $B4,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$BE,$BF,$C0,$C1,$C2,$C3,$C4,$C5
	dc.b $C5,$C6,$C7,$C8,$C9,$CA,$CA,$CB,$CC,$CD,$CD,$CE,$CF,$CF,$D0,$D0
	dc.b $D1,$D1,$D2,$D2,$D2,$D3,$D3,$D3,$D4,$D4,$D4,$D4,$D4,$D4,$D4,$D4
	dc.b $D4,$D4,$D4,$D4,$D4,$D4,$D4,$D4,$D3,$D3,$D3,$D2,$D2,$D2,$D1,$D1
	dc.b $D0,$D0,$CF,$CF,$CE,$CD,$CD,$CC,$CB,$CA,$CA,$C9,$C8,$C7,$C6,$C5
	dc.b $C5,$C4,$C3,$C2,$C1,$C0,$BF,$BE,$BC,$BB,$BA,$B9,$B8,$B7,$B6,$B4
	dc.b $B3,$B2,$B1,$B0,$AE,$AD,$AC,$AB,$A9,$A8,$A7,$A5,$A4,$A3,$A2,$A0
	dc.b $9F,$9E,$9C,$9B,$9A,$99,$97,$96,$95,$94,$92,$91,$90,$8F,$8D,$8C
	dc.b $8B,$8A,$89,$87,$86,$85,$84,$83,$82,$81,$80,$7F,$7E,$7D,$7C,$7B
	dc.b $7A,$79,$78,$78,$77,$76,$75,$74,$74,$73,$72,$72,$71,$71,$70,$70
	dc.b $6F,$6F,$6E,$6E,$6D,$6D,$6D,$6D,$6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C

	even

***************************************

Wait_raster:
	move.l	$dff004,	d7
	asr.l	#8,		d7	
	and.l	#$1ff,		d7
	cmp.w	#100,		d7
	bne.s	Wait_raster

.wait	move.l	$dff004,	d7
	asr.l	#8,		d7	
	and.l	#$1ff,		d7
	cmp.w	#100,		d7
	beq.b	.wait

	rts

***************************************
			
	section	copper,code_c

COPPERLIST:

Spr_pointer:
	dc.w	$0120,$0000
	dc.w	$0122,$0000
	dc.w	$0124,$0000
	dc.w	$0126,$0000
	dc.w	$0128,$0000
	dc.w	$012a,$0000
	dc.w	$012c,$0000
	dc.w	$012e,$0000
	dc.w	$0130,$0000
	dc.w	$0132,$0000
	dc.w	$0134,$0000
	dc.w	$0136,$0000
	dc.w	$0138,$0000
	dc.w	$013a,$0000
	dc.w	$013c,$0000
	dc.w	$013e,$0000


	dc.w	$1c07,$fffe
	dc.w	$0180,$05af
	dc.w	$0100,$4200	

BPL_pointer:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
	dc.w	$00ec,$0000
	dc.w	$00ee,$0000
	
BPL_col:dc.w 	$0182,$0111,$0184,$0222,$0186,$0333,$0188,$0444,$018a,$0555
	dc.w 	$018c,$0666,$018e,$0777,$0190,$0888,$0192,$0999,$0194,$0aaa
	dc.w	$0196,$0bbb,$0198,$0ccc,$019a,$0ddd,$019c,$0eee,$019e,$0fff

	dc.w	$8507,$fffe
	dc.w	$0100,$1200
	dc.w	$0182,$05AF

	dc.w	$ffdf,$fffe

	dc.w	$3807,$fffe
	dc.w	$0100,$0200

	dc.w	$ffff,$fffe


***************************************

Logo:	incbin	"Anubislogo320x105.raw"

	blk.b	20480,0

font:	incbin	"dh2:font"
	blk.l	$140,0

Blnk_SPRl:
	blk.l	4,%00000000000000000000000000000000

Spr1:	dc.w	$0c6c,$f200	; VstartHstart,Vstop00 (YYXX,YY+Height00)
	blk.l	SPRh,%00000000000000000000000000000000	

Spr2:
	dc.w	$0c75,$f200	; VstartHstart,Vstop00 (YYXX,YY+height00)
	blk.l	SPRh,%00000000000000000000000000000000
Spr3:
	dc.w	$0c7e,$f200	; VstartHstart,Vstop00 (YYXX,YY+height00)
	blk.l	SPRh,%00000000000000000000000000000000	

Spr4:
	dc.w	$0c87,$f200	; VstartHstart,Vstop00 (YYXX,YY+height00)
	blk.l	SPRh,%00000000000000000000000000000000	

Spr5:
	dc.w	$0c90,$f200	; VstartHstart,Vstop00 (YYXX,YY+height00)
	blk.l	SPRh,%00000000000000000000000000000000		

Spr6:
	dc.w	$0c99,$f200	; VstartHstart,Vstop00 (YYXX,YY+height00)
	blk.l	SPRh,%00000000000000000000000000000000	

Spr7:
	dc.w	$0ca2,$f200	; VstartHstart,Vstop00 (YYXX,YY+height00)
	blk.l	SPRh,%00000000000000000000000000000000	

Spr8:
	dc.w	$0cab,$f200	; VstartHstart,Vstop00 (YYXX,YY+height00)
	blk.l	SPRh,%00000000000000000000000000000000	

