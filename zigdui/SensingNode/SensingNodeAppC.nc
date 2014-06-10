/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

#include "printf.h"
#include "lsm303.h"
#include "common.h"

configuration SensingNodeAppC { }
implementation
{
  components SensingNodeC, MainC, ActiveMessageC, LedsC,
  new TimerMilliC(), 
  new AMSenderC(RECEIVER_ID);//, new AMReceiverC(AM_OSCILLOSCOPE);
  components SerialPrintfC;
  components Lsm303C;
  
  components ZigduinoDigitalPortsC;
  //SensingNodeC.PIRPin -> ZigduinoDigitalPortsC.Interrupt0;
  SensingNodeC.PIRPin -> ZigduinoDigitalPortsC.DigitalPin[0];
  
  SensingNodeC.Boot -> MainC;
  SensingNodeC.RadioControl -> ActiveMessageC;
  SensingNodeC.AMSend -> AMSenderC;
  //MotionOscC.Receive -> AMReceiverC;
  SensingNodeC.Timer -> TimerMilliC;
  SensingNodeC.ReadXYZout -> Lsm303C.ReadXYZout;	
  SensingNodeC.ReadSR -> Lsm303C.ReadSR;
  SensingNodeC.SetMode -> Lsm303C.SetMode;  

  SensingNodeC.Leds -> LedsC;

}
