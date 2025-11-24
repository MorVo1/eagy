kbd equ $d010
kbdcr equ $d011
echo equ $ffef
datalow equ $002c
datahigh equ $002d
inslow equ $002e
inshigh equ $002f

	* = $d014

start		cld
	ldy #0
	lda #$00
	sta datalow
	lda #$10
	sta datahigh	; Initialize the data pointer to $1000
	lda #$80
	sta inslow
	lda #$02
	sta inshigh	; Initialize the instruction pointer to $0280
	lda #$8d	; CR
	jsr echo	; Output it
	lda #$23	; "#"
	jsr echo	; Display the prompt
read	bit kbdcr	; Key pressed?
	bpl read	; No, keep waiting
	lda kbd		; Yes, load the key to A
	cmp #$bb	; ";"?
	beq exec	; Execute the program
	cmp #$be	; ">"?
	beq append	; Yes, append the key to the buffer
	cmp #$bc	; "<"?
	beq append	; Yes, append the key to the buffer
	cmp #$ab	; "+"?
	beq append	; Yes, append the key to the buffer
	cmp #$ad	; "-"?
	beq append	; Yes, append the key to the buffer
	cmp #$ae	; "."?
	beq append	; Yes, append the key to the buffer
	cmp #$ac	; ","?
	beq append	; Yes, append the key to the buffer
	cmp #$db	; "["?
	beq append	; Yes, append the key to the buffer
	cmp #$dd	; "]"?
	beq append	; Yes, append the key to the buffer
	jmp read	; Unrecognized character, skip it
append	jsr echo	; Display the pressed key
	sta (inslow),y	; Store the key in the address pointed to by the instruction pointer
	clc
	lda inslow
	adc #1
	sta inslow
	lda inshigh
	adc #0
	sta inshigh	; Increment the instruction pointer
	jmp read	; Read the next character
exec	jmp *
