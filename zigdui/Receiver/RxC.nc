
#include "Timer.h"
#include "common.h"
#include "printf.h"

//#define DEBUG 1


module RxC @safe() {
	uses {
		interface Boot;
		interface SplitControl as RadioControl;
		interface Receive;
		interface Leds;
	}
}

implementation {

	Packet_t LocalPacket;

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
	
		if(call RadioControl.start() != SUCCESS)	
			//Startup radio.
		report_problem();
		printf("Init done\n\r");
		printfflush();

	}

	task void ProcessPacket(){
		printf("%X:%X:%X\n\r",LocalPacket.ID, LocalPacket.Sensor,LocalPacket.Data);
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
	
		if (len != sizeof(Packet_t)) 
			// do nothing - just return
		return msg;
	
		else 
		{
			Packet_t* Src = (Packet_t*)payload;
			memcpy(&LocalPacket, Src, sizeof(Packet_t));
			report_received();
			post ProcessPacket();
		}
		return msg;
	}
}
