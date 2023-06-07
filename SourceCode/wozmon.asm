;   Name: Apple 1 Woz Monitor
;   File: wozmon.asm
;   Author: Steve Wozniak (c)1976
;           Matt Rude <matt@mattrude.com>
;   URL: https://github.com/mattrude/windemere-basic
;   Date: 2023-06-06
;   Version: 1.0.0
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
;       vasm6502_oldstyle -c02 -dotdir -Fbin wozmon.asm -o wozmon.bin
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
; Copyright (c) 1978 Steve Wozniak
;               2023 Matt Rude
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


XAML        = $24                      ; Last "opened" location Low
XAMH        = $25                      ; Last "opened" location High
STL         = $26                      ; Store address Low
STH         = $27                      ; Store address High
L           = $28                      ; Hex value parsing Low
H           = $29                      ; Hex value parsing High
YSAV        = $2A                      ; Used to see if hex value is given
MODE        = $2B                      ; $00=XAM, $7F=STOR, $AE=BLOCK XAM

IN          = $0200                    ; Input buffer
ACIA_DATA   = $5000
ACIA_STATUS = $5001
ACIA_CMD    = $5002
ACIA_CTRL   = $5003


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Start of program / Reset button pressed                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                .org $ff00
RESET:
                LDA     #$1F           ; 8-N-1, 19200 baud.
                STA     ACIA_CTRL
                LDA     #$0B           ; No parity, no echo, no interrupts.
                STA     ACIA_CMD
                LDA     #$1B           ; Begin with escape.

NOTCR:
                CMP     #$08           ; Backspace key?
                BEQ     BACKSPACE      ; Yes.
                CMP     #$1B           ; ESC?
                BEQ     ESCAPE         ; Yes.
                INY                    ; Advance text index.
                BPL     NEXTCHAR       ; Auto ESC if line longer than 127.

ESCAPE:
                LDA     #$5C           ; "\".
                JSR     ECHO           ; Output it.

GETLINE:
                LDA     #$0D           ; Send CR
                JSR     ECHO
                LDY     #$01           ; Initialize text index.
BACKSPACE:      DEY                    ; Back up text index.
                BMI     GETLINE        ; Beyond start of line, reinitialize.

NEXTCHAR:
                LDA     ACIA_STATUS    ; Check status.
                AND     #$08           ; Key ready?
                BEQ     NEXTCHAR       ; Loop until ready.
                LDA     ACIA_DATA      ; Load character. B7 will be '0'.
                STA     IN,Y           ; Add to text buffer.
                JSR     ECHO           ; Display character.
                CMP     #$0D           ; CR?
                BNE     NOTCR          ; No.
                LDY     #$FF           ; Reset text index.
                LDA     #$00           ; For XAM mode.
                TAX                    ; X=0.
SETBLOCK:
                ASL
SETSTOR:
                ASL                    ; Leaves $7B if setting STOR mode.
                STA     MODE           ; $00 = XAM, $74 = STOR, $B8 = BLOK XAM.
BLSKIP:
                INY                    ; Advance text index.
NEXTITEM:
                LDA     IN,Y           ; Get character.
                CMP     #$0D           ; CR?
                BEQ     GETLINE        ; Yes, done this line.
                CMP     #$2E           ; "."?
                BCC     BLSKIP         ; Skip delimiter.
                BEQ     SETBLOCK       ; Set BLOCK XAM mode.
                CMP     #$3A           ; ":"?
                BEQ     SETSTOR        ; Yes, set STOR mode.
                CMP     #$52           ; "R"?
                BEQ     RUN            ; Yes, run user program.
                STX     L              ; $00 -> L.
                STX     H              ;    and H.
                STY     YSAV           ; Save Y for comparison

NEXTHEX:
                LDA     IN,Y           ; Get character for hex test.
                EOR     #$30           ; Map digits to $0-9.
                CMP     #$0A           ; Digit?
                BCC     DIG            ; Yes.
                ADC     #$88           ; Map letter "A"-"F" to $FA-FF.
                CMP     #$FA           ; Hex letter?
                BCC     NOTHEX         ; No, character not hex.

DIG:
                ASL
                ASL                    ; Hex digit to MSD of A.
                ASL
                ASL
                LDX     #$04           ; Shift count.

HEXSHIFT:
                ASL                    ; Hex digit left, MSB to carry.
                ROL     L              ; Rotate into LSD.
                ROL     H              ; Rotate into MSD's.
                DEX                    ; Done 4 shifts?
                BNE     HEXSHIFT       ; No, loop.
                INY                    ; Advance text index.
                BNE     NEXTHEX        ; Always taken. Check next character for hex.

NOTHEX:
                CPY     YSAV           ; Check if L, H empty (no hex digits).
                BEQ     ESCAPE         ; Yes, generate ESC sequence.
                BIT     MODE           ; Test MODE byte.
                BVC     NOTSTOR        ; B6=0 is STOR, 1 is XAM and BLOCK XAM.
                LDA     L              ; LSD's of hex data.
                STA     (STL,X)        ; Store current 'store index'.
                INC     STL            ; Increment store index.
                BNE     NEXTITEM       ; Get next item (no carry).
                INC     STH            ; Add carry to 'store index' high order.
TONEXTITEM:
                JMP     NEXTITEM       ; Get next command item.

RUN:
                JMP     (XAML)         ; Run at current XAM index.

NOTSTOR:
                BMI     XAMNEXT        ; B7 = 0 for XAM, 1 for BLOCK XAM.

                LDX     #$02           ; Byte count.
SETADR:         LDA     L-1,X          ; Copy hex data to
                STA     STL-1,X        ;  'store index'.
                STA     XAML-1,X       ; And to 'XAM index'.
                DEX                    ; Next of 2 bytes.
                BNE     SETADR         ; Loop unless X = 0.

NXTPRNT:
                BNE     PRDATA         ; NE means no address to print.
                LDA     #$0D           ; CR.
                JSR     ECHO           ; Output it.
                LDA     XAMH           ; 'Examine index' high-order byte.
                JSR     PRBYTE         ; Output it in hex format.
                LDA     XAML           ; Low-order 'examine index' byte.
                JSR     PRBYTE         ; Output it in hex format.
                LDA     #$3A           ; ":".
                JSR     ECHO           ; Output it.

PRDATA:
                LDA     #$20           ; Blank.
                JSR     ECHO           ; Output it.
                LDA     (XAML,X)       ; Get data byte at 'examine index'.
                JSR     PRBYTE         ; Output it in hex format.
XAMNEXT:        STX     MODE           ; 0 -> MODE (XAM mode).
                LDA     XAML
                CMP     L              ; Compare 'examine index' to hex data.
                LDA     XAMH
                SBC     H
                BCS     TONEXTITEM     ; Not less, so no more data to output.
                INC     XAML
                BNE     MOD8CHK        ; Increment 'examine index'.
                INC     XAMH

MOD8CHK:
                LDA     XAML           ; Check low-order 'examine index' byte
                AND     #$07           ; For MOD 8 = 0
                BPL     NXTPRNT        ; Always taken.

PRBYTE:
                PHA                    ; Save A for LSD.
                LSR
                LSR
                LSR                    ; MSD to LSD position.
                LSR
                JSR     PRHEX          ; Output hex digit.
                PLA                    ; Restore A.

PRHEX:
                AND     #$0F           ; Mask LSD for hex print.
                ORA     #$30           ; Add "0".
                CMP     #$3A           ; Digit?
                BCC     ECHO           ; Yes, output it.
                ADC     #$06           ; Add offset for letter.

ECHO:
                PHA                    ; Save A.
                STA     ACIA_DATA      ; Output character.
                LDA     #$FF           ; Initialize delay loop.
TXDELAY:        DEC                    ; Decrement A.
                BNE     TXDELAY        ; Until A gets to 0.
                PLA                    ; Restore A.
                RTS                    ; Return.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           W65C02 Memory starting block stored at end of ROM                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                .org $FFFA
                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   $0000          ; IRQ vector