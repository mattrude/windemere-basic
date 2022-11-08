; 65c02 LCD 4-bit Demo code
;
; https://sigmaserv.fr/6502/lcd_2.s

PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %00100000
RS = %00010000

    .org $8000

reset:
	lda #%01111111 ; Set pins on port B to output
	sta DDRB
	
	lda #%00000010 ; Set LCD to 4-pins mode
	jsr lcd_instruction
	lda #%00000010
	jsr lcd_instruction
	lda #%00000000
	jsr lcd_instruction
	lda #%00000000
	jsr lcd_instruction
	lda #%00001110
	jsr lcd_instruction
	
	lda #%00010100
	jsr print_char
	lda #%00011000
	jsr print_char

loop:
    jmp loop
	
lcd_instruction:
	sta PORTB
	lda #0
	sta PORTB
	lda #E
	sta PORTB
	lda #0
	sta PORTB
	jsr delay
	rts
	
print_char: 
	sta PORTB
	lda #E
	sta PORTB
	lda #RS
	sta PORTB
	jsr delay
	rts

delay:
	ldx #200
delay2:
    ldy #0
delay1:
    dey
	bne delay1
	dex
	bne delay2
	rts
  
	.org $fffc
	.word reset
	.word $0000