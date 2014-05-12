//AMRx demo

#include "Timer.h"
#include "Oscilloscope.h"

#include "printf.h"

//#define DEBUG 1


module MotionOscC @safe() {
	uses {
		interface Boot;
		interface SplitControl as RadioControl;
		interface Receive;
		interface Leds;
	}
}

implementation {


	/* Current local state - interval, version and accumulated readings */
	oscilloscope_t local;

	// Use LEDs to report various status issues.
	void report_problem() {
		call Leds.led0Toggle();
	}
	void report_sent() {
		call Leds.led1Toggle();
	}
	void report_received() {
		call Leds.led2Toggle();
	}

	//Initialise accelerometer.
	event void Boot.booted() {
		printf("Initing...\n\r");
		printfflush();

		local.interval = 10; //Set sample interval to 10ms.
		local.id = TOS_NODE_ID;
		if(call RadioControl.start() != SUCCESS)	
    //Startup radio.
		report_problem();
		printf("Init done\n\r");
		printfflush();

	}
	oscilloscope_t OscData;
	task void ProcessPacket(){ 
	  uint8_t i; 
    
    for(i=0; i < 3/*NREADINGS*/; i++){
      printf("%d,", OscData.readings[i]);
    } 
    
    printf("\n\r");
		printfflush();
  }

	//Radio control start callback 
	event void RadioControl.startDone(error_t error) {
	}

	event void RadioControl.stopDone(error_t error) {
	}

	//Handler for receiving packets from base.
	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
			
			if (len != sizeof(oscilloscope_t)) 
        // do nothing - just return
			  return msg;
			
			else 
			{
			  oscilloscope_t* Src = (oscilloscope_t*)payload;
			  memcpy(&OscData, Src, sizeof(oscilloscope_t));
        report_received();
        post ProcessPacket();
      }
		return msg;
	}
}
