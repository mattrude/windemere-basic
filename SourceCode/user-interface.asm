;   File: user-interface.asm
;   Author: Matt Rude <matt@mattrude.com>
;   URL: https://github.com/mattrude/windemere-basic
;   Date: 2022-01-22
;   Version: 0.1.0a
;
;------------------------------------------------------------------------------
;   Program Summary
;
;
;   The below code is written for a W65C02 connected to a W65C22 (VIA)
;
; -----------------------------------------------------------------------------
;   Compiling from source
;
;
;   This source file expects the use of the vasm compiler found at:
;       http://sun.hasenbraten.de/vasm/
;
;   To compile this code, run a command similer to:
;       vasm6502_oldstyle -c02 -dotdir -Fbin main.asm -o main.bin
;
;       cd C:\Users\Owner\OneDrive\Documents\Eletrontics\6502\Projects\
;           windemere-basic\SourceCode
;       ..\..\..\Tools\vasm6502\vasm6502_oldstyle.exe -c02 -dotdir
;       -Fbin user-interface_short.asm -o user-interface_short.bin
;
; -----------------------------------------------------------------------------
;   Memory
;
;                 ┌───────────────────────────┐
;                 │    WD65C02 Memory Map     │
;                 ├───────┬───────────────────┤
;                 │ $0000 │                   │
;                 │       │  Zero Page (RAM)  │
;                 │ $00ff │                   │
;                 ├───────┼───────────────────┤
;                 │ $0100 │///////////////////│
;                 │       │////// Stack //////│
;                 │ $01ff │///////////////////│
;                 ├───────┼───────────────────┤
;                 │ $0200 │                   │
;                 │       │        RAM        │
;                 │ $5fff │                   │
;                 ├───────┼───────────────────┤
;                 │ $6000 │                   │
;                 │       │    W65C22S VIA    │
;                 │ $600f │                   │
;                 ├───────┼───────────────────┤
;                 │ $6010 │                   │
;                 │       │    (Not Used)     │
;                 │ $7fff │                   │
;                 ├───────┼───────────────────┤
;                 │ $8000 │                   │
;                 │       │        ROM        │
;                 │ $ffff │                   │
;                 └───────┴───────────────────┘
;
;
;
;     ┌────────────────────────────────────────────────────────┐
;     │                 Zero Page RAM Locations                │
;     ├────────────────────────────────────────────────────────┤
;     │ 0000: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0010: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0020: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0030: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0040: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0050: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0060: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0070: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0080: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 0090: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 00a0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 00b0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 00c0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 00d0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 00e0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
;     │ 00f0: 00 00 00 00 00 00 00 00  -- -- -- -- -- -- -- -- │
;     └────────────────────────────────────────────────────────┘
;
; -----------------------------------------------------------------------------
;   License
;
; MIT No Attribution License
;
; Copyright (c) 2022 Matt Rude
; 
; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files
; (the "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
; DEALINGS IN THE SOFTWARE.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Staic RAM Locations                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ticks    = $f0              ; 6-bytes
tocks    = $f6              ; 1-byte
cpu_type = $f7              ; 1-byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           W65C22 Versatile Interface Adapter (VIA)                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PORTB = $6000               ; W65C22 Register "B"
PORTA = $6001               ; W65C22 Register "A"
DDRB  = $6002               ; W65C22 Data Direction Register "B"
DDRA  = $6003               ; W65C22 Data Direction Register "A"
TCL1  = $6004               ; W65C22 T1 Low-Order Counter
TCH1  = $6005               ; W65C22 T1 High-Order Counter
TLL1  = $6006               ; W65C22 T1 Low-Order Latches
TLH1  = $6007               ; W65C22 T1 High-Order Latches
TCL2  = $6008               ; W65C22 T2 Low-Order Counter
TCH2  = $6009               ; W65C22 T2 High-Order Counter
SR    = $600a               ; W65C22 Shift Register
ACR   = $600b               ; W65C22 Auxiliary Control Register
PCR   = $600c               ; W65C22 Peripheral Control Register
IFR   = $600d               ; W65C22 Interrupt Flag Register
IER   = $600e               ; W65C22 Interrupt Enable Register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           HD44780U LCD Display Controller                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EN = $80                    ; HD44780U LCD Starts data read/write
RW = $40                    ; HD44780U LCD Enables Screen to read data
RS = $20                    ; HD44780U LCD Registers Select


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Start of program / Reset button pressed                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                .org $8000              ; Start at memory location 8000 hex
boot:           ldx #$ff                ; Set the stack pointer
                txs
reset:          sei                     ; Disable CPU Interrupts
                cld                     ; clear decimal mode
                clc                     ; clear carry bit
                ldx #0                  ; Start the Index X at zero
                ldy #0                  ; Start the Index Y at zero
Initialize_LCD: lda #$ff                ; Set all pins on port "B" to output
                sta DDRB
                lda #$e1                ; top 3 pins/last, port "A" to output
                sta DDRA
                lda #$38                ; 8-bit mode; 2-line display; 5x8 font
                jsr lcd_config
                lda #$c                 ; Display on; cursor on; blink off
                jsr lcd_config
                lda #$6                 ; Increment and shift cursor
                jsr lcd_config
                lda #$11                ; Clear the LCD display
                jsr lcd_config
                lda #$2                 ; Send cursor to line 1
                jsr lcd_config
print_boot:     lda boot_message, x     ; load the first/next character into A
                beq t1_timer            ; Jump to loop, if accumulator is $00
                jsr print_char          ; If not, jump to print_char
                inx                     ; Increment the Index X
                jmp print_boot          ; jump back to the top of print_boot
t1_timer:       ldx #0                  ; Zero out the X index
                lda #0                  ; Zero out the accumulator
                sta ticks               ; Zero out the ticks memory location
                sta ticks + 1           ; Zero out the ticks-1 memory location
                sta ticks + 2           ; Zero out the ticks-2 memory location
                sta ticks + 3           ; Zero out the ticks-3 memory location
                sta ticks + 4           ; Zero out the ticks-4 memory location
                sta ticks + 5           ; Zero out the ticks-5 memory location
                sta tocks               ; Zero out the tocks memory location
                lda #%01000000          ; Set the Timer 1 to Continuous mode
                sta ACR                 ; Store timer 1 to Aux Control Register
                lda #$0e                ; Set timer 1 to trigger every
                sta TCL1                ;   0.25 seconds.
                lda #$27
                sta TCH1
enable_irq:     lda #%11000000          ; Enable IRQs & Timer 1 on w65c02
                sta IER                 ; Store to Interrupt Enable Register
cpu_checker:    sed                     ; set decimal mode
                clc                     ; clear carry for add
                lda #$99                ; actually 99 decimal in this case   
                adc #$01                ; +1 gives 00 and sets Zb on 65C02
                cld                     ; exit decimal mode
                bne mos6502             ; Break (Jump) if MOS 6502 CPU
                lda #$c2                ; WDC 65c02
                sta cpu_type
                jsr ready
mos6502:        lda #02                 ; MOS 6502
                sta cpu_type
ready:          lda #%00000001          ; Clear the LCD display
                jsr lcd_config          ; Jump to the lcd_config subroutine
                lda #%00000010          ; Send cursor to line 1; home position
                jsr lcd_config          ; Jump to the lcd_config subroutine
                ldx #0                  ; Set the X Index to zero
lcd_ready:      lda ready_message, x    ; load the first/next character into A
                beq reset_end           ; Jump to loop, if accumulator is $00
                jsr print_char          ; If not, jump to print_char
                inx                     ; Increment the Index X
                jmp lcd_ready           ; jump back to the top of lcd_ready
reset_end:      cli                     ; Enable CPU Interupts


                lda #<loop              ; Load the low byte of the function
                sta $00                 ; Store the bit to the zero page
                lda #>loop              ; Load the high byte of the function
                sta $01                 ; Store the bit to the zero page
                jmp ($00)               ; Run an indrect jump


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           The forever / primary loop                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loop:           jmp loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   LCD Subroutines                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------------------------------------
;   LCD Store instruction subroutine
lcd_config:     jsr lcd_wait            ; Jump to the lcd_wait subroutine
                sta PORTB               ; Store the above to Port "B"
                lda #0                  ; Clear LCD RS/RW/EN bits
                sta PORTA               ; Store the above to Port "A"
                lda #EN                 ; Set LCD EN (enable) bit
                sta PORTA               ; Store the above to Port "A"
                lda #0                  ; Clear LCD RS/RW/EN bits
                sta PORTA               ; Store the above to Port "A"
                rts                     ; Return from Subroutine


;------------------------------------------------------------------------------
;   LCD Print Character subroutine
print_char:     jsr lcd_wait            ; Jump to the lcd_wait subroutine
                sta PORTB               ; Store the above to Port "B"
                lda #RS                 ; Set LCD RS; Clear RW/EN bits
                sta PORTA               ; Store the above to Port "A"
                lda #(RS | EN)          ; Set LCD EN (enable) bit
                sta PORTA               ; Store the above to Port "A"
                lda #RS                 ; Clear LCD EN (enable) bits
                sta PORTA               ; Store the above to Port "A"
                rts                     ; Return from Subroutine


;------------------------------------------------------------------------------
;   LCD Wait / Busy subroutine
lcd_wait:       pha                     ; Push Accumulator to Stack
                lda #%00000000          ; Set Port B as an input
                sta DDRB                ; Load the setting to Port "B"
lcd_busy:       lda #RW                 ; Set port to Read/Write
                sta PORTA               ; Load the setting to Port "A"
                lda #(RW | EN)          ; Set port to Read/Write & Enable
                sta PORTA               ; Load the setting to Port "A"
                lda PORTB               ; Load Accumulator with Port "B"
                and #%10000000          ; Combine the above with $80
                bne lcd_busy            ; Jump back to the top of lcd_busy
                lda #RW                 ; Set port to Read/Write
                sta PORTA               ; Load the setting to Port "A"
                lda #%11111111          ; Port B is output
                sta DDRB                ; Load the setting to Port "B"
                pla                     ; Pull Accumulator from Stack
                rts                     ; Return from Subroutine


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           The messages to be be displayed on the LCD screen                 ;
;                  16x2 Character Limit                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 16x2 Character Limit  |----------------|
boot_message:   .asciiz "Booting"
ready_message:  .asciiz "Ready"
; 16x2 Character Limit  |----------------|


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           IRQ subroutine                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tcl1_runner:    bit TCL1                ; Zero the TCL1 flag
                inc ticks
                bne tcl1_runner_2
                inc ticks + 1
                bne tcl1_runner_2
                inc ticks + 2
                bne tcl1_runner_2  
                inc ticks + 3
                bne tcl1_runner_2
                inc ticks + 4
                bne tcl1_runner_2
                inc ticks + 5
                bne tcl1_runner_2
tcl1_runner_2:  sec                     ; Set Carry Flag (enable subtraction)
                lda ticks
                sbc tocks
                cmp #25                 ; Have 250ms elapsed?
                bcc tcl1_end            ; Branch on Carry Clear
                lda #$01
                eor PORTA               ; xor the value from PORTA to $01
                sta PORTA               ; Toggle the hartbeat LED
                lda ticks
                sta tocks               ; Return from Subroutine
tcl1_end:       rts

tcl2_runner:    lda #$12
                sta $ff
                rts

cb1_runner:     rts

cb2_runner:     rts

sr_runner:      rts

ca1_runner:     lda #$a1
                sta $ff
                rts

ca2_runner:     lda #$a2
                sta $ff
                rts

irq:            sei
                pha                     ; Save accumulator
                txa
                pha                     ; Save X-register
                tya
                pha                     ; Save Y-register
                cld                     ; Enable binary mode/clear decimal flag
                lda IFR
                bpl irq_end             ; Exit if the VIA didn't create the IRQ
                asl 
                bmi tcl1_runner         ; Timer CA 1 
                asl 
                bmi tcl2_runner         ; Timer CA 2
                asl 
                bmi cb1_runner          ; Peripheral B Control Line 1
                asl 
                bmi cb2_runner          ; Peripheral B Control Line 2
                asl 
                bmi sr_runner           ; Shift Register
                asl 
                bmi ca1_runner          ; Peripheral A Control Line 1
                asl 
                bmi ca2_runner          ; Peripheral A Control Line 2
irq_end:        pla
                tay                     ; restore Y-register
                pla
                tax                     ; restore X-register
                pla                     ; restore accumulator
                cli
                rti                     ; resume interrupted task


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           W65C02 Memory starting block stored at end of ROM                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                .org $fffc
                .word boot
                .word irq