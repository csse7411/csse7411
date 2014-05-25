/*
 * Copyright (c) 2012 Sapienza University of Rome.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Sapienza University of Rome nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SAPIENZA
 * UNIVERSITY OF ROME OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Author: Ugo Colesanti <colesanti@dis.uniroma1.it>
 * Philipp Sommer <philipp.sommer@csiro.au>
 */

configuration ZigduinoDigitalPortsC {

  provides interface GeneralIO as DigitalPin[uint8_t];

  provides interface GeneralIO as Digital0 ;
  provides interface GeneralIO as Digital1 ;
  provides interface GeneralIO as Digital2 ;
  provides interface GeneralIO as Digital3 ;
  provides interface GeneralIO as Digital4 ;
  provides interface GeneralIO as Digital5 ;
  provides interface GeneralIO as Digital6 ;
  provides interface GeneralIO as Digital7 ;
  provides interface GeneralIO as Digital8 ;
  provides interface GeneralIO as Digital9 ;
  provides interface GeneralIO as Digital10 ;
  provides interface GeneralIO as Digital11 ;
  provides interface GeneralIO as Digital12 ;
  provides interface GeneralIO as Digital13 ;

  provides interface GpioInterruptPlus as Interrupt0;
  provides interface GpioInterruptPlus as Interrupt1;
  provides interface GpioInterruptPlus as Interrupt2;
  provides interface GpioInterruptPlus as Interrupt3;
  // digital pins 4 and 5 do not support interrupts
  provides interface GpioInterruptPlus as Interrupt6;
  provides interface GpioInterruptPlus as Interrupt7;


  provides interface Init ;


}
implementation {
  components AtmegaGeneralIOC as IO;
  components ZigduinoDigitalPortsP;
  components AtmegaExtInterruptC;

  Init = ZigduinoDigitalPortsP ;

  Digital0 = IO.PortD2 ;
  Digital1 = IO.PortD3 ;
  Digital2 = IO.PortE6 ;
  Digital3 = IO.PortE5 ;
  Digital4 = IO.PortE2 ;
  Digital5 = IO.PortE3 ;
  Digital6 = IO.PortE4 ;
  Digital7 = IO.PortE7 ;
  Digital8 = IO.PortB4 ;
  Digital9 = IO.PortB7 ;
  Digital10 = IO.PortB6 ;
  Digital11 = IO.PortB2 ;
  Digital12 = IO.PortB3 ;
  Digital13 = IO.PortB1 ;

  DigitalPin[0] = IO.PortD2;
  DigitalPin[1] = IO.PortD3;
  DigitalPin[2] = IO.PortE6;
  DigitalPin[3] = IO.PortE5;
  DigitalPin[4] = IO.PortE2;
  DigitalPin[5] = IO.PortE3;
  DigitalPin[6] = IO.PortE4;
  DigitalPin[7] = IO.PortE7;
  DigitalPin[8] = IO.PortB4;
  DigitalPin[9] = IO.PortB7;
  DigitalPin[10] = IO.PortB6;
  DigitalPin[11] = IO.PortB2;
  DigitalPin[12] = IO.PortB3;
  DigitalPin[13] = IO.PortB1;

  Interrupt0 = AtmegaExtInterruptC.GpioInterruptPlus[2]; // INT2
  Interrupt1 = AtmegaExtInterruptC.GpioInterruptPlus[3]; // INT3
  Interrupt2 = AtmegaExtInterruptC.GpioInterruptPlus[6]; // INT6
  Interrupt3 = AtmegaExtInterruptC.GpioInterruptPlus[5]; // INT5
  Interrupt6 = AtmegaExtInterruptC.GpioInterruptPlus[4]; // INT4
  Interrupt7 = AtmegaExtInterruptC.GpioInterruptPlus[7]; // INT7

}
