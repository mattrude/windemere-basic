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

## LCD Screen

The liquid crystal display (LCD) screen module is a Hitachi HD44780 LCD controller is an alphanumeric dot matrix LCD controller developed by Hitachi in the 1980s. The character set of the controller includes ASCII characters, Japanese Kana characters, and some symbols in two 40 character lines.

## 20-Button Keypad

For the 20-button keypad we use the [MM74C923](https://mm.digikey.com/Volume0/opasdata/d220001/medias/docus/1001/MM74C922,923.pdf) 20-Key Encoder connected to the above W65C22 VIA chip.

| W65C22 VIA  | MM74C923   |
| ----------- | ---------- |
| PA0 (pin 2) | B (pin 18) |
| PA1 (pin 3) | C (pin 17) |


## Reset Circit

The reset circit consits of a [MCP102-475](https://www.microchip.com/en-us/product/mcp102) voltage supervisor device designed to keep a proccesser in reset until the system voltage has reached and stabalized at the proper level 4.75 volts for 120ms.

## References & Notes
