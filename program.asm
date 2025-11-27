kbd equ $d010
kbdcr equ $d011
echo equ $ffef
wozmon equ $ff00
datalow equ $2c
datahigh equ $2d
inslow equ $2e
inshigh equ $2f

	* = $d014

start	cld
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
exec	lda #0
	sta (inslow),y	; End the string
	lda #$80
	sta inslow
	lda #$02
	sta inshigh	; Set the instruction pointer back to $0280
nextins	lda (inslow),y	; Load the current instruction
	cmp #$be	; ">"?
	beq datainc	; Yes, increment the data pointer
	cmp #$bc	; "<"?
	beq datadec	; Yes, decrement the data pointer
	cmp #$ab	; "+"?
	beq valinc	; Yes, increment the cell value
	cmp #$ad	; "-"?
	beq valdec	; Yes, decrement the cell value
	cmp #$ae	; "."?
	beq display	; Yes, diplay the cell value
	cmp #$ac	; ","?
	beq input	; Yes, wait for a keypress
	cmp #$db	; "["?
	beq openbra	; Yes, enter a loop
	cmp #$dd	; "]"?
	beq closbra	; Yes, jump to the opening bracket
	jmp wozmon	; Reached the end, jump back to wozmon
advance	lda inslow
	clc
	adc #1
	sta inslow
	lda inshigh
	adc #0
	sta inshigh	; Increment the instruction pointer
	jmp nextins	; Jump to the next instruction
datainc lda datalow
	clc
	adc #1
	sta datalow
	lda datahigh
	adc #0
	sta datahigh	; Increment the data pointer
	jmp advance
datadec	sec
	lda datalow
	sbc #1
	sta datalow
	lda datahigh
	sbc #0
	sta datahigh	; Decrement the data pointer
	jmp advance
valinc	lda (datalow),y
	clc
	adc #1
	sta (datalow),y	; Increment the cell value
	jmp advance
valdec	sec
	lda (datalow),y
	sbc #1
	sta (datalow),y	; Decrement the cell value
	jmp advance
display	jmp *
input	jmp *
openbra	jmp *
closbra	jmp *
