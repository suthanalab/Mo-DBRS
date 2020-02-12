## Requirements

# Programmable
- Raspberry Pi

  https://www.newark.com/buy-raspberry-pi?ost=raspberry+pi+3&rd=raspberry+pi+3

# Standalone
- PIC Controller PIC16F716 or PIC16F84

  https://www.digikey.com/product-detail/en/microchip-technology/PIC16F84-04-P/PIC16F84-04-P-ND/243462


# Additional Hardware

![Circuits](https://github.com/suthanalab/Mo-DBRS/blob/master/Mo-DBRS_Lite/electromagnet_circuits.png)

<br/>

<p align="justify">
Programmable electromagnet device for Mo-DBRS Lite. a, Schematic of the electrical circuit necessary for driving an electromagnet, whose pulse is sent towards the underlying implanted RNS System. The system includes power delivery from a 12 V battery, various capacitors for voltage stabilization, current limiting resistors, and LEDs that emit light when the Magnet pulse is being sent that can be used for synchronization with external cameras. The electromagnet device can be manually controlled via button presses captured by a PIC controller that can deliver pulses every 30, 60, 90, 180, or 240 s (configurable by manually setting a 4-pin DIP switch). Such a device requires the complete circuitry shown in a, with the actual device worn by the participant shown in b. c, For wireless remote control of the electromagnet device, additional circuitry (marked in yellow a) can be added around a Raspberry Pi (RP) with pins 17 and 18 from a PIC controller being interfaced with GPIOs. The modified RP is shown in figure c, and can be remotely used to trigger the electromagnet device repeatedly with programmable times and durations from within the RP or the Experimental Task Program.
</p>
