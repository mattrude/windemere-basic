# Source Code Directory README File

This directory stores the required source code for this project.  The source code must be compiled before you may use it on the computer.

Before you are able to compile the project's source code, you will need to install [vasm](http://sun.hasenbraten.de/vasm/) compiler, and [minipro](https://gitlab.com/DavidGriffith/minipro) or [XGecu](http://www.autoelectric.cn/en/download.html) to burn the compiled code to the EEPROM.

## Using the software

### WOZMON

The WOZMON firmware was part of the Apple 1 computer that started the Apple computer company.  This is a small program originally living on a 256Kb ROM chip.

The original Apple 1 did not come with a Reset circuit, which means that the user has to press the RESET button in order to get the machine started. Once you do that a back slash `\` is printed on the screen and the cursor will drop down one line. The cursor position is represented by a flashing `@` symbol.

You can now type address, data and commands which will be executed as soon as you press the Return key. The input buffer can hold up to 127 character, if you type more characters before hitting the Return key the input line will be erased and will start again from scratch. This overflow situation is indicated by a new back slash after which the cursor drops one line again.

Because of the primitive nature of the terminal there are not many line-editing features available. You can press the back arrow key to erase characters from the input buffer, but the erased characters will not be erased from the screen nor will the cursor position back-up. You'll have to keep track of the changes yourself. It's obvious that you can easily get confused when a line contains too many corrections or when an error is detected all the way at the other end of the input line. In that case it would be easiest to cancel the input and start all over again. Canceling the input is done by pressing the `ESC` key.

Address inputs are truncated to the least significant 4 hexadecimal digits. Data inputs are truncated to the least significant 2 hexadecimal digits.

Thus entering `12345678` as address will result in the address `5678` to be used.

*Tip: This can also be used to your advantage to correct typing errors, instead of using the back arrow key.*

If an error is encountered during the parsing of the input line then the rest of the line is simply ignored, without warning! Commands executed before the error are executed normally though.

## Install Needed Tools

On a Ubuntu system, run:

    sudo apt-get install build-essential pkg-config git libusb-1.0-0-dev

Once the needed packets are installed, run the below to install vasm & minipro

    cd && rm -rf vasm && wget -c http://sun.hasenbraten.de/vasm/release/vasm.tar.gz && \
    tar -xzf vasm.tar.gz && cd vasm/ && make CPU=6502 SYNTAX=oldstyle && \
    cp vasm6502_oldstyle /usr/local/bin/ && \
    cd && rm -rf minipro && git clone https://gitlab.com/DavidGriffith/minipro.git && \
    cd minipro && make && sudo make install && cd && \
    echo '' && echo "Installation Complete!"

## Compiling from Source

This source file expects the use of the [vasm compiler](http://www.compilers.de/vasm.html) found at: [user-interface.asm](sun.hasenbraten.de/vasm)

To compile this code, run a command similer to:

    vasm6502_oldstyle -c02 -dotdir -Fbin main.asm -o main.bin

## Software License

    MIT No Attribution
    
    Copyright (c) 2022 Matt Rude
    
    Permission is hereby granted, free of charge, to any person obtaining a 
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense, 
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
