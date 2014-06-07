
#include "printf.h"
#include "common.h"
configuration RxAppC { }
implementation
{
	components RxC, MainC, ActiveMessageC, LedsC;
	components new AMReceiverC(RECEIVER_ID); 
	components SerialPrintfC;

	RxC.Boot -> MainC;
	RxC.RadioControl -> ActiveMessageC;
	RxC.Receive -> AMReceiverC;
	RxC.Leds -> LedsC;

}
