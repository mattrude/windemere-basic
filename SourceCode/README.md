# Installion

## Install Needed Tools

On a Ubuntu system, run:

    sudo apt-get install build-essential pkg-config git libusb-1.0-0-dev

Once the needed packets are installed, run the below to install vasm & minipro

    cd && rm -rf vasm && wget -c http://sun.hasenbraten.de/vasm/release/vasm.tar.gz && \
    tar -xzf vasm.tar.gz && cd vasm/ && make CPU=6502 SYNTAX=oldstyle && \
    cp vasm6502_oldstyle /usr/local/bin/ && \
    cd && rm -rf minipro && git clone https://gitlab.com/DavidGriffith/minipro.git && \
    cd minipro && make && sudo make install && cd && \
    echo '' && echo "Installion Complete!"

## Compiling from Source

This source file expects the use of the [vasm compiler](http://www.compilers.de/vasm.html) found at: http://sun.hasenbraten.de/vasm/

To compile this code, run a command similer to:

    vasm6502_oldstyle -c02 -dotdir -Fbin main.asm -o main.bin

## Software License

```
MIT No Attribution

Copyright (c) 2022 Matt Rude

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
