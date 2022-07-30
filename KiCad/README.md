# Hardware

## Buzzer

The buzzer uses the 6522's PB7 and free-running T1 to output a modulation needed to create sound.[[1](#ref1)][[2](#ref2)]

```
You can use the 6522's PB7 and free-running T1 to output a beep signal,
or clock out an exact number of cycles from an arbitrary waveform generator,
while leaving the µP free to do other things at the same time.

You'll need the 2 msb's of the 6522's ACR to be 11. You might use a timer
interrupt to turn off the beep, or a cycle-counting interrupt to stop
the arb at the right time.
```

A code example from Jeff Tranter:[[1](#ref1)]

```
  COUNT = $4119
      
  LDA #$00
  STA IER             ; disable all interrupts
  LDA #%11000000
  STA ACR             ; Set to T1 free running PB7 enabled
  LDA #<COUNT
  STA T1CL            ; Low byte of count
  LDA #>COUNT
  STA T1CH            ; High byte of count
  RTS
```

## LCD Screen

## LED Lights

## 20-Button Keypad

## Reset Circit

## References & Notes

* <span id="ref1"/>[1] - [6522 VIA Experiment #2](http://jefftranter.blogspot.com/2012/03/6522-via-experiment-2.html)
* <span id="ref2"/>[2] - [Tip of the day #17](http://forum.6502.org/viewtopic.php?f=7&t=342&start=17)
