# Windemere Basic 6502 Computer

This is a proof of concept project to build a 65c02 computer from scratch.

This repository is broken up into 2 main sections, [Hardware](Hardware#readme) and [Software](SourceCode#readme).

## About

                 ┌───────────────────────────┐
                 │    WD65C02 Memory Map     │
                 ├───────┬───────────────────┤
                 │ $0000 │                   │
                 │       │   Zero Page RAM   │
                 │ $00ff │                   │
                 ├───────┼───────────────────┤
                 │ $0100 │///////////////////│
                 │       │////// Stack //////│
                 │ $01ff │///////////////////│
                 ├───────┼───────────────────┤
                 │ $0200 │                   │
                 │       │        RAM        │
                 │ $5fff │                   │
                 ├───────┼───────────────────┤
                 │ $6000 │                   │
                 │       │    W65C22S VIA    │
                 │ $600f │                   │
                 ├───────┼───────────────────┤
                 │ $6010 │                   │
                 │       │    (Not Used)     │
                 │ $7fff │                   │
                 ├───────┼───────────────────┤
                 │ $8000 │                   │
                 │       │        ROM        │
                 │ $ffff │                   │
                 └───────┴───────────────────┘



     ┌────────────────────────────────────────────────────────┐
     │                 Zero Page RAM Locations                │
     ├────────────────────────────────────────────────────────┤
     │ 0000: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0010: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0020: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0030: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0040: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0050: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0060: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0070: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0080: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 0090: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 00a0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 00b0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 00c0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 00d0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 00e0: -- -- -- -- -- -- -- --  -- -- -- -- -- -- -- -- │
     │ 00f0: 00 00 00 00 00 00 00 00  -- -- -- -- -- -- -- -- │
     └────────────────────────────────────────────────────────┘

## Required Tools/Software

### Software Used

* [KiCad](https://www.kicad.org/) - To create the Schematic and PCB
* [vasm](http://sun.hasenbraten.de/vasm/) - To compile the Source Code
* [miniPro](https://gitlab.com/DavidGriffith/minipro) - To upload the compiled binary to an eeprom
* [ClickCharts](https://www.nchsoftware.com/chart/index.html) - To create flowchart's for project documentation.

### Compiling from source

This source file expects the use of the vasm compiler found at: [sun.hasenbraten.de/vasm](http://sun.hasenbraten.de/vasm/)

To compile this code, run a command similer to:

    vasm6502_oldstyle -c02 -dotdir -Fbin main.asm -o main.bin

## System Images

![Schematic](Docs/windemere-basic.svg)

![PCB](Docs/windemere-basic.png)
