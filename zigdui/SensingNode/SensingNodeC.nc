
#include "Timer.h"
#include "common.h"
#include "lsm303.h"
#include "printf.h"

//#define DEBUG 1


module SensingNodeC @safe() {
	uses {
		interface Boot;
		interface SplitControl as RadioControl;
		interface AMSend;
		//interface Receive;
		interface Timer<TMilli>;
		interface Leds;
		interface Read<lsm303_data_t> as ReadXYZout;
		interface Read<uint8_t> as ReadSR;
		interface Set<uint8_t> as SetMode;
	
		//interface GpioInterruptPlus as PIRPin;
		interface GeneralIO as PIRPin;
	
	}
}

implementation {

	message_t sendBuf;
	AcclData_t AcclData;
	Packet_t Packet;
    Packet_t PacketPIR;
	bool PIRDetectOld = FALSE;
	bool PIRDetect = FALSE;
	bool RadioBusy = FALSE;
	bool PIREvent;
	float threshold_max = 10.5;
	float threshold_min = 7.5;
	int threshold_cnt = 4;
	int svn_cnt;
	float svn[10];
	float svn_par = 0.0;

	int time_cnt = 0;
	int event_detected;
	int Cntr = 0;


 
	// Use LEDs to report various status issues.
	void report_problem() {
		atomic{
            RadioBusy = FALSE;
        }
		//call Leds.led0Toggle();
	}
	void report_sent() {
		atomic{
			RadioBusy = FALSE;
		}
		//call Leds.led1Toggle();
	}

	//Initialise accelerometer.
	event void Boot.booted() {
		//#ifdef DEBUG
		printf("Initing...\n\r");
		printfflush();
		//#endif 

		Packet.ID = TOS_NODE_ID;
		Packet.Sensor = SENSOR_VIBRATION;
		Packet.Data = VIBRATING;
 
		PacketPIR.ID = TOS_NODE_ID;
		PacketPIR.Sensor = SENSOR_PIR;
		PacketPIR.Data = PIR_ACTIVATED;
		PIREvent = FALSE;
		if(call RadioControl.start() != SUCCESS)	
			//Startup radio.
		report_problem();

		//call PIRPin.reset();
		//call PIRPin.enableRisingEdge() ;
		call PIRPin.makeInput();
		
		call SetMode.set(LSM303_ACC100HZ);	//Set LSM303 accelerometer sampling to 100Hz 

		event_detected = 0;

		//#ifdef DEBUG
		printf("Init done\n\r");
		printfflush();
		//#endif 

	}
	//Start timer
	void startTimer() {
		call Timer.startPeriodic(10);// Set sample interval to 10ms
	}

	//Radio control start callback - start timer if radio is initialised successfully.
	event void RadioControl.startDone(error_t error) {
		startTimer();
	}

	event void RadioControl.stopDone(error_t error) {
	}

	error_t SendPacket(Packet_t * pckt)
	{
		Packet_t * msg;
		RadioBusy = TRUE;
 
 		msg = (Packet_t *)call AMSend.getPayload(&sendBuf, sizeof(Packet_t));
		if (msg == NULL) {
			RadioBusy = FALSE;
			return FAIL;
		}
		memcpy(msg, pckt, sizeof (Packet_t));
 
		call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof (Packet_t));
		return SUCCESS;
	}
	//Sample Accelerometer values periodically.
	event void Timer.fired() {
	
		PIRDetect = call PIRPin.get();
	
		if ( PIRDetectOld != PIRDetect)
		{
			PIRDetectOld = PIRDetect;	
			if (PIRDetect)
			{
				PIREvent = TRUE;
				call Leds.led1On();
			}
			else
				call Leds.led1Off();
		}
		
		if(PIREvent)
		{
			if (!RadioBusy)
			{
				if(SendPacket(&PacketPIR) == SUCCESS)
					PIREvent = FALSE;
			}
		}
	
		//If event is detected, transmit packet
		if(event_detected > 0) 
		{
			if(!RadioBusy)
			{
				if(SendPacket(&Packet) == SUCCESS)
					event_detected = 0;
			}
		}
		//Read X,Y,Z values
		if(call ReadXYZout.read() != SUCCESS) 
			report_problem();
	}

	//Packet Send Callback.
	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(error == SUCCESS) 
			report_sent();
		else 
			report_problem();

	}

	//Read X,Y,Z register callback
	event void ReadXYZout.readDone(error_t result, lsm303_data_t data) {

		float svn_avg, accx, accy, accz;
		int i;
		float svn_current;

		//Check if error has not occured.
		if(result != SUCCESS) {

			report_problem();
		}
		else {

			call Leds.led0Toggle();

			//Insert X, Y, Z readings into packet
			AcclData.readings[0] = (uint16_t) data.accel_x;
			AcclData.readings[1] = (uint16_t) data.accel_y;
			AcclData.readings[2] = (uint16_t) data.accel_z;

			//Process X, Y, Z readings
			accx = (float) data.accel_x;
			accy = (float) data.accel_y;
			accz = (float) data.accel_z;

			#ifdef DEBUG
			printf("X:%d Y:%d Z:%d\n\r", data.accel_x, data.accel_y, data.accel_z);
			printfflush();
			#endif 

			//Calculate SVN
			svn_current = (accx * accx) + (accy * accy) + (accz * accz);

			//Only keep last 10 SVN values
			for(i = 9; i > 0; i--) {
				svn[i] = svn[i - 1];
			}

			svn[0] = svn_current;
			svn_avg = 0.0;

			//Calculate average SVN
			for(i = 0; i < 10; i++) {
				svn_avg += svn[i];
			}

			svn_avg = svn_avg / 10.0;

			//Calculate Peak to Average Ratio (PAR).
			svn_par = ((float) svn_current) / svn_avg;
			svn_par = svn_par * 10.0;

			#ifdef DEBUG
			printf("svn_avg %d, svn_current %d, svn_par %d - %d:%d:%d\n\r",
					(int) svn_avg, (int) svn_current, (int) svn_par, (int) accx, (int) accy,
					(int) accz);
			printf("svn_par %d\n\r", (int) svn_par);
			printfflush();
			#endif

			//Check if PAR is above a certain threshold.
			if((svn_par >= threshold_max) || (svn_par <= threshold_min)) {
				svn_cnt++;
				time_cnt = 0;
			}
			else {
				svn_cnt = 0;
			}

			//If PAR meets thresholds, transmit packet to base.
			if(((svn_par >= threshold_max) || (svn_par <= threshold_min))&&(svn_cnt >= threshold_cnt)) {
				//#ifdef DEBUG
				printf("EVENT DETECTED - PAR: %d\n\r", (int) svn_par);
				printfflush();
				//#endif

				event_detected++;

				#ifdef DEBUG
				printf("RADIO SEND\n\r");
				printfflush();
				#endif

				svn_cnt = 0;
			}

			//Reset svn_cnt, after 2s
			time_cnt++;
			if(time_cnt >= 2000) {
				time_cnt = 0;
				svn_cnt = 0;
			}
		}
	}

	//Read Status Register callback
	event void ReadSR.readDone(error_t result, uint8_t data) {
		printf("SR %X\n\r", data);
		printfflush();
	}

}
