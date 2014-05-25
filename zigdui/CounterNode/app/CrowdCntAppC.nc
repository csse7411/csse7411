
// A sample program to demonstrate how to use the Laser sensor
//#include "Timer.h"

#include "printf.h"

configuration CrowdCntAppC {}

implementation {
	components MainC, CrowdCntC, LaserEntExDetectorC , LedsC;
	components new TimerMilliC() as Timer0;
	
	components SerialPrintfC;

	CrowdCntC.Boot -> MainC.Boot;

	CrowdCntC.Timer0 -> Timer0;
	CrowdCntC.Leds -> LedsC.Leds;
	CrowdCntC.EntExtDetector -> LaserEntExDetectorC.EntExtDetector; 
 
 
 
}
