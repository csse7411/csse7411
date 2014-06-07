
#include "printf.h"
#include "common.h"
#include "laser.h"
#define __DEBUG 1

module CrowdCntC @safe(){
	//uses interface PIR as PIRSensor;
	uses interface Timer<TMilli> as Timer0;
	uses interface LaserEntExDetector as EntExtDetector;
	uses interface Leds;
	uses interface Boot;
	uses interface SplitControl as RadioControl;	
	uses interface AMSend;	
}
implementation {

	uint16_t Cnt = 0;
	message_t sendBuf;
	Packet_t Packet;
	// Use LEDs to report various status issues.
	void report_problem() {
		//        call Leds.led0Toggle();
	}
	void report_sent() {
		call Leds.led1Toggle();
	}
	void report_received() {
		//        call Leds.led2Toggle();
	}

	event void Boot.booted()
	{
		printf("Initing...\n\r");
		printfflush();		
		Packet.ID = TOS_NODE_ID;
		Packet.Sensor = SENSOR_LASER;
	
		if(call RadioControl.start() != SUCCESS)  
		{
			report_problem();
			printf("Failed to init radio\n\r");
			printfflush(); 
		}	
		printf("Done\n\r");
		printfflush();      
 
	}
	//Radio control start callback - start timer if radio is initialised successfully.
	event void RadioControl.startDone(error_t error) {
		call Timer0.startPeriodic(250);
	}

	event void RadioControl.stopDone(error_t error) {
	}

	event void Timer0.fired()
	{
		call Leds.led0Toggle();
	}
	
	void SendPacket(){
		memcpy(call AMSend.getPayload(&sendBuf, sizeof(Packet)), &Packet,
				sizeof Packet);
		call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof Packet);
	} 
 
	
	//Packet Send Callback.
	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(error == SUCCESS) 
			report_sent();
		else 
			report_problem();
 
	}
	
    
    task void TransmitPacket()
    {
        SendPacket();
    }   
    async event void EntExtDetector.EntryDetected()
    {
        atomic{
            Packet.Data = DIR_ENTER;
        }
        post TransmitPacket();
        printf("Welcome\n\r");
        printfflush();
    }
    async event void EntExtDetector.ExitDetected()
    {
        atomic{
            Packet.Data = DIR_EXIT;
        }
        post TransmitPacket();
        printf("Bye\n\r");
        printfflush();      
    }
    
	
	
	
}
