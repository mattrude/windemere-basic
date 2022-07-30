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

## LCD Screen

## LED Lights

## 20-Button Keypad

## Reset Circit

## References & Notes

* <span id="ref1"/>[1] - [6522 VIA Experiment #2](http://jefftranter.blogspot.com/2012/03/6522-via-experiment-2.html)
* <span id="ref2"/>[2] - [Tip of the day #17](http://forum.6502.org/viewtopic.php?f=7&t=342&start=17)
