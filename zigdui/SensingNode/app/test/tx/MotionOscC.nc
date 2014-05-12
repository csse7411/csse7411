//Motion Sensing program for SSHNode.

#include "Timer.h"
#include "Oscilloscope.h"
#include "lsm303.h"
#include "printf.h"

//#define DEBUG 1


module MotionOscC @safe() {
	uses {
		interface Boot;
		interface SplitControl as RadioControl;
		interface AMSend;
		interface Receive;
		interface Timer<TMilli>;
		interface Leds;
		interface Read<lsm303_data_t> as ReadXYZout;
		interface Read<uint8_t> as ReadSR;
		interface Set<uint8_t> as SetMode;
	}
}

implementation {

	message_t sendBuf;

	float threshold_max = 15.5;	//10.5
	float threshold_min = 9.5;	//9.5
	int threshold_cnt = 4;
	int svn_cnt;
	float svn[10];
	float svn_par = 0.0;

	int time_cnt = 0;
	int event_detected;
	int Cntr = 0;

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
		//#ifdef DEBUG
		printf("Initing...\n\r");
		printfflush();
		//#endif 

		local.interval = 10; //Set sample interval to 10ms.
		local.id = TOS_NODE_ID;
		if(call RadioControl.start() != SUCCESS)	
			//Startup radio.
		report_problem();

		call SetMode.set(LSM303_ACC100HZ);	//Set LSM303 accelerometer sampling to 100Hz 

		event_detected = 0;

		//#ifdef DEBUG
		printf("Init done\n\r");
		printfflush();
		//#endif 

	}

	//Start timer
	void startTimer() {
		call Timer.startPeriodic(local.interval);
	}

	//Radio control start callback - start timer if radio is initialised successfully.
	event void RadioControl.startDone(error_t error) {
		startTimer();
	}

	event void RadioControl.stopDone(error_t error) {
	}

	//Handler for receiving packets from base.
	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		oscilloscope_t * omsg = payload;

		report_received();

		#ifdef DEBUG
		printf("Packet received\n\r");
		printfflush();
		#endif 

		return msg;
	}

	//Sample Accelerometer values periodically.
	event void Timer.fired() {
		//If event is detected, transmit packet
		if(event_detected > 0) {
		  oscilloscope_t * omsg;
		  omsg = (oscilloscope_t *)call AMSend.getPayload(&sendBuf, sizeof(local));
		  if (omsg == NULL) {
		  return;
      }
			memcpy(omsg, &local, sizeof (local));
			printf("X:%d Y:%d Z:%d\n\r",  omsg-> readings[0], 
			                              omsg-> readings[1],
			                              omsg-> readings[2]);
			printfflush();
			
			Cntr++;
			omsg->count = (nx_uint16_t)Cntr;
			call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof (local));
			event_detected = 0;
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
			local.readings[0] = (uint16_t) data.accel_x;
			local.readings[1] = (uint16_t) data.accel_y;
			local.readings[2] = (uint16_t) data.accel_z;

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
