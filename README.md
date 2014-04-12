##MetalDuino: An Arduino metal detecting project for use with Processing.

I've played with metal detector circuits in the past but never got around to building anything really sophisticated. So, recently, I decided to spend a little time getting around to doing it. My goal was to build a simple detector I could connect to an Arduino circuit to send data to a Processing program on a PC or Android device. It's now working so I decided to put the project on GitHub in case anyone else needs help doing the same.

The actual metal detecting is done by the circuit included here, for which I take no credit (please see below for details of the website the circuit came from and any licensing details). It's basically an oscillator circuit that outputs a frequency dependent on the coil's inductance. As metal approaches the coil, the inductance changes together with the output frequency.

The Arduino counts the number of pulses, and measures how long it took to count them. Those data are then sent via a Bluetooth connection in my circuit, although you could use just a USB cable if you prefer. The processing program receives the data and uses them to draw an oscilloscope-like graph. I included simple image output in the Processing program, so just press the 's' key to save metalduino.png to the program's folder (I've included an example here). Also, holding the metal detector push button down for a few seconds will cause the Processing program to recalibrate, and altering the potentiometer changes the scale of the graph.

It's a fairly simple project to build with a regular Arduino board, but well worth the trouble of building into a proper soldered up circuit if you want to use it regularly outdoors (like me you could even use Bluetooth for the serial communications). Whichever way, I hope you enjoy it :-)

##Information and circuit details:

http://atmelcorporation.wordpress.com/2013/07/25/build-your-own-metal-detector-with-an-arduino/


