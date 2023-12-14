# Hardware

The file describes the layout of the board and how components are used.

## Control Logic

The control logic enables the different componints connected to the registry according to the address requested by the 65C02 CPU. We accplish this primarly by using 3 channels of a 4 channel NAND gate, the [74LS00](https://www.ti.com/lit/gpn/sn74ls00).

1. We start by flipping the bit of `A15` registry line by using two gates of a NAND gate. The inverted output is sent first to the `CS` (chip select) line of the EEPROM. This enables the ROM when the address requested on the registry bus is `$8000` or above and disables the chip when the address is below `$7FFF`.

2. The above inverted `A15` line from the NAND gate continues to one channel of a second NAND gete.  The other channel of this gate is connected to the `PHI2` clock signal, with it's output connected to the `CS` pin of the RAM chip.  The ROM chip also has it's `OE` (output enabled) pin connected to `A14`.  The `OE` pin is active low, so the RAM chip is only active between `$0000` to `$4FFF`.

3. The same inverted `A15` line from the first NAND gate is used a third time, this time in corrdination with the `A14` line.  The output from this third gate connects to the `CS` pin of the WD65C22 VIA chip, enableing access in the `$6000`

## W65C22 VIA

The [W65C22](https://www.westerndesigncenter.com/wdc/documentation/w65c22.pdf) Versatile Interface Adapter (VIA) is a flexible I/O device used to connect to the [LCD Screen](#lcd-screen), [20-Button Keypad](#20-button-keypad) and used in software for it's timers.

As described in part 3 of the control logic section above, the VIA chip is acessed within the `$6000` address block.

```armasm
lda #$ff                ; Set all pins on port "B" to output
sta $6002               ; Store to port B on the W65C22
lda #$e1                ; top 3 pins/last, port "A" to output
sta $6003               ; Store to port A on the W65C22
```

## LCD Screen

The liquid crystal display (LCD) screen module is a Hitachi [HD44780](https://www.sparkfun.com/datasheets/LCD/HD44780.pdf) LCD controller is an alphanumeric dot matrix LCD controller developed by Hitachi in the 1980s. The character set of the controller includes ASCII characters, Japanese Kana characters, and some symbols in two 40 character lines.

```avrasm
PORTB = $6000               ; W65C22 Register "B"
PORTA = $6001               ; W65C22 Register "A"
DDRB  = $6002               ; W65C22 Data Direction Register "B"
DDRA  = $6003               ; W65C22 Data Direction Register "A"
EN    = $80                 ; HD44780U LCD Starts data read/write
RW    = $40                 ; HD44780U LCD Enables Screen to read data
RS    = $20                 ; HD44780U LCD Registers Select


lcd_init:
    lda #$ff                ; Set all pins on port "B" to output
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
loop:
    jmp loop                ; INIT is now complete

lcd_config:
    sr lcd_wait             ; Jump to the lcd_wait subroutine
    sta PORTB
    lda #0                  ; Clear LCD RS/RW/EN bits
    sta PORTA
    lda #EN                 ; Set LCD EN (enable) bit
    sta PORTA
    lda #0                  ; Clear LCD RS/RW/EN bits
    sta PORTA
    rts                     ; Return from Subroutine

lcd_wait:
    pha                     ; Push Accumulator to Stack
    lda #%00000000          ; Set Port B as an input
    sta DDRB                ; Load the setting to Port "B"
lcd_busy:
    lda #RW                 ; Set port to Read/Write
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
```

## 20-Button Keypad

For the 20-button keypad we use the [MM74C923](https://mm.digikey.com/Volume0/opasdata/d220001/medias/docus/1001/MM74C922,923.pdf) 20-Key Encoder connected to the above W65C22 VIA chip.

When a button is pressed, the chip will set the output as discribed below and set the `DA` (Data Available) pin, connected to the `CA1` pin on the W65C22, to high.

| W65C22 VIA  | MM74C923   |
| ----------- | ---------- |
| PA0 (pin 2) | A (pin 19) |
| PA1 (pin 3) | B (pin 18) |
| PA2 (pin 4) | C (pin 17) |
| PA3 (pin 5) | D (pin 16) |
| PA4 (pin 6) | E (pin 15) |

Below is a Simple key map with the left hand column showing the pin id as described above and the top row is the button id pressed.

|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 |
|---|---|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|----|----|----|----|
| A | - | 1 | - | 1 | - | 1 | - | 1 | - | 1 | -  | 1  | -  | 1  | -  | 1  | -  | 1  | -  | 1  |
| B | - | - | 1 | 1 | - | - | 1 | 1 | - | - | 1  | 1  | -  | -  | 1  | 1  | -  | -  | 1  | 1  |
| C | - | - | - | - | 1 | 1 | 1 | 1 | - | - | -  | -  | 1  | 1  | 1  | 1  | -  | -  | -  | -  |
| D | - | - | - | - | - | - | - | - | 1 | 1 | 1  | 1  | 1  | 1  | 1  | 1  | -  | -  | -  | -  |
| E | - | - | - | - | - | - | - | - | - | - | -  | -  | -  | -  | -  | -  | 1  | 1  | 1  | 1  |

## Reset Circit

The reset circit consits of a [MCP102-475](https://www.microchip.com/en-us/product/mcp102) voltage supervisor device designed to keep a proccesser in reset until the system voltage has reached and stabalized at the proper level 4.75 volts for 120ms.

## References & Notes
