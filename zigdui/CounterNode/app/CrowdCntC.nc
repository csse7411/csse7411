
#include "printf.h"

module CrowdCntC{
	//uses interface PIR as PIRSensor;
	uses interface Timer<TMilli> as Timer0;
	uses interface LaserEntExDetector as EntExtDetector;
	uses interface Leds;
	uses interface Boot;	
}
implementation {

	uint16_t Cnt = 0;

	event void Boot.booted()
	{
		printf("Initing...\n\r");
		printfflush();		
		call Timer0.startPeriodic(250);
        printf("Done\n\r");
        printfflush();      
        
	}
	async event void EntExtDetector.EntryDetected()
	{
		printf("Welcome\n\r");
		printfflush();
	}
	async event void EntExtDetector.ExitDetected()
	{
		call Leds.led2Toggle();
		printf("Bye\n\r");
		printfflush();		
	}
	
	event void Timer0.fired()
	{
		call Leds.led0Toggle();
	}   	
	
}
