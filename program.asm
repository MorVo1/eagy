kbd equ $d010
kbdcr equ $d011
echo equ $ffef
wozmon equ $ff00
datalow equ $2c
datahigh equ $2d
inslow equ $2e
inshigh equ $2f
dmaxlow equ $30
dmaxhigh equ $31

	* = $d014

start	cld
	ldy #0
	ldx #0
	lda #$00
	sta datalow
	sta dmaxlow
	lda #$10
	sta datahigh
	sta dmaxhigh	; Initialize the data pointer and its max value to $1000
	lda #0
	sta (datalow),y	; Initialize the first data cell to 0
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
exec	lda #$8d	; CR
	jsr echo	; Output it
	lda #0
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
	beq toopen	; Yes, enter a loop
	cmp #$dd	; "]"?
	beq toclos	; Yes, jump to the opening bracket
	lda #$8d	; CR
	jsr echo	; Output it
	jmp wozmon	; Reached the end, jump back to wozmon
toopen	jmp openbra
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
	sec
	lda dmaxlow
	sbc datalow
	lda dmaxhigh
	sbc datahigh	; Compare the current data pointer to the highest ever reached
	bcc zero	; The current data pointer is higher, initialize the cell
	jmp advance
zero	lda #0
	sta (datalow),y
	lda datalow
	sta dmaxlow
	lda datahigh
	sta dmaxhigh
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
display	lda (datalow),y
	jsr echo
	jmp advance
input	bit kbdcr	; Key pressed?
	bpl input	; No, keep waiting
	lda kbd		; Yes, load it to the A register
	sta (datalow),y	; Store it in the data cell
	jmp advance
toclos	jmp closbra
toadv	jmp advance
openbra	lda (datalow),y
	bne advance	; Byte at the data pointer is not 0, jump to the next instruction
oloop	lda (inslow),y
	cmp #$db	; "["?
	beq obalp	; Yes, increment the balance
	cmp #$dd	; "]"?
	beq obalm	; Yes, decrement the balance
oret	lda inslow
	clc
	adc #1
	sta inslow
	lda inshigh
	adc #0
	sta inshigh	; Increment the instruction pointer
	jmp oloop
obalp	inx
	jmp oret
obalm	dex
	beq osave
	jmp oret
osave	jmp advance
closbra	lda (datalow),y
	beq toadv	; Byte at the data pointer is 0, jump to the next instruction
cloop	lda (inslow),y
	cmp #$dd	; "]"?
	beq cbalp	; Yes, increment the balance
	cmp #$db	; "["?
	beq cbalm	; Yes, decrement the balance
cret	lda inslow
	sec
	sbc #1
	sta inslow
	lda inshigh
	sbc #0
	sta inshigh	; Decrement the instruction pointer
	jmp cloop
cbalp	inx
	jmp cret
cbalm	dex
	beq csave
	jmp oret
csave	jmp advance
