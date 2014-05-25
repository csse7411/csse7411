// PIR HPL definition

#include "Timer.h"

#include "printf.h"
#include "laser.h"
#include "atm128hardware.h"

module LaserEntExtDetectorP{
	provides interface Init;
	provides interface LaserEntExDetector as Detector;
	uses interface GpioInterruptPlus as Laser_Inner;
	uses interface GpioInterruptPlus as Laser_Outter;
	
	uses interface EntExtState as StateProcessor;
	uses interface Timer<TMilli> as LaserEmeaterTimer;
	uses interface GeneralIO as LaserDiod;
 
}
 

implementation {
	
	tLaser_Beam_Status LaserBeamStat[sizeof(tLaser_Sensor_ID)];
	uint8_t Cnt = 0;
	uint8_t LaserDiodState = 0;
	uint8_t EdgeCntr[sizeof(tLaser_Sensor_ID)];
	bool Blocked[sizeof(tLaser_Sensor_ID)];
	bool BlockedOld[sizeof(tLaser_Sensor_ID)];
	
	
	command error_t Init.init() {
		printf("Initing...\n\r");
		printfflush();
	
		EdgeCntr[ID_INNER] = 0;
		EdgeCntr[ID_OUTTER] = 0;
		Blocked[ID_INNER]  = FALSE;
		Blocked[ID_OUTTER]  = FALSE;
		BlockedOld[ID_INNER]  = FALSE;
		BlockedOld[ID_OUTTER]  = FALSE;
	
		call StateProcessor.Reset();
		call LaserEmeaterTimer.startPeriodic(10);
	
		//printfflush();
		LaserBeamStat[ID_INNER] = LASER_BEAM_STAT_UNBLOCKED;
		LaserBeamStat[ID_OUTTER] = LASER_BEAM_STAT_UNBLOCKED;
 
		// Initially the Laser sensor produces Low level on detection of a laser beam
		// so state machine should start once a rising edge is detected (laser beam is disrupted)
		call LaserDiod.makeOutput();
		// call LaserDiod.set();
	
		call Laser_Inner.reset();
		call Laser_Outter.reset();

		printf("P inited...\n\r");
		printfflush();
		return SUCCESS;
	}
	task void LogInnB(){
		printf("|");
		printfflush();
	}
	task void LogInnUnb(){
		printf("\\");
		printfflush();
	}
	task void LogOutB(){
		printf("{");
		printfflush();
	}
	task void LogOutUnb(){
		printf("=");
		printfflush();
	}
	void ProcessCntrOff(tLaser_Sensor_ID ID){
		if (EdgeCntr[ID]>0)
		{ // an expected rising edge has not happened - An obstacle detected!
			EdgeCntr[ID]  = 0;
			Blocked[ID]  = TRUE;
			if (Blocked[ID] != BlockedOld[ID])
			{
				BlockedOld[ID] = Blocked[ID];
				call StateProcessor.Process(ID, TRUE);

 
			}
		}
		else
		{
			// unblocked
			Blocked[ID]  = FALSE;
			if (Blocked[ID] != BlockedOld[ID])
			{
				BlockedOld[ID] = Blocked[ID];
				call StateProcessor.Process(ID, FALSE);

 
			}                   
		}
	
	}
	void ProcessCntrOn(tLaser_Sensor_ID ID){
		if (EdgeCntr[ID] > 0)
		{ // an expected rising edge has not happened - An obstacle detected!
			EdgeCntr[ID]  = 0;
 
			Blocked[ID]  = TRUE;
			if (Blocked[ID] != BlockedOld[ID])
			{
				BlockedOld[ID] = Blocked[ID];
				call StateProcessor.Process(ID, TRUE);

			}                   
		}
		else
		{
			// unblocked
			if (Blocked[ID] != BlockedOld[ID])
			{
				BlockedOld[ID] = Blocked[ID];
				call StateProcessor.Process(ID, FALSE);

			}                   
		}
	}
	event void LaserEmeaterTimer.fired()
	{
		// __nesc_atomic_t  temp;
		//temp = __nesc_atomic_start();
 
		// has been OFF
		atomic
		{
			if (LaserDiodState == 0 )
			{
	
				ProcessCntrOff(ID_INNER);
				ProcessCntrOff(ID_OUTTER);
	
 
				EdgeCntr[ID_INNER]++;
				EdgeCntr[ID_OUTTER]++;
				LaserDiodState = 1;
			
				call Laser_Outter.enableRisingEdge() ;
				call Laser_Inner.enableRisingEdge() ;
				call LaserDiod.set();
			}
			else
				// has been ON
			{
				ProcessCntrOn(ID_INNER);
				ProcessCntrOn(ID_OUTTER);

 
				EdgeCntr[ID_INNER] ++;
				EdgeCntr[ID_OUTTER] ++;
				LaserDiodState = 0;
				
				call Laser_Outter.enableFallingEdge() ;
				call Laser_Inner.enableFallingEdge() ;
				call LaserDiod.clr();
	
			}
		}
 
		//   __nesc_atomic_end(temp);
 
		//call LaserDiod.clr();
	}   
	
	
	async event void Laser_Outter.fired(){
	
		//atomic{
		if (LaserDiodState == 0 )
		{
			if(call Laser_Outter.getMode() == ATMEGA_EXTINT_FALLING_EDGE)
			{
				if (EdgeCntr[ID_OUTTER] >0)
				{ 
					--EdgeCntr[ID_OUTTER] ;
				}
 
			}
		}
 
		if (LaserDiodState == 1 )
		{
			if(call Laser_Outter.getMode() == ATMEGA_EXTINT_RISING_EDGE)
			{
				if (EdgeCntr[ID_OUTTER] >0)
				{ 
					--EdgeCntr[ID_OUTTER] ;
				}
			}
 
		}
		//}
	
	}
	async event void Laser_Inner.fired()
	{
		if (LaserDiodState == 0 )
		{
			if(call Laser_Inner.getMode() == ATMEGA_EXTINT_FALLING_EDGE)
			{
				if (EdgeCntr[ID_INNER] >0)
				{ 
					--EdgeCntr[ID_INNER] ;
				}
	
			}
		}
	
		if (LaserDiodState == 1 )
		{
			if(call Laser_Inner.getMode() == ATMEGA_EXTINT_RISING_EDGE)
			{
				if (EdgeCntr[ID_INNER] >0)
				{ 
					--EdgeCntr[ID_INNER] ;
				}
			}
 
		}
 
	}
	
	
	
	async event void StateProcessor.EntryDetected(){
//		printf("ENTRY\n\r");
//		printfflush();
		signal Detector.EntryDetected();
	}
	async event void StateProcessor.ExitDetected(){
//		printf("EXIT\n\r");
//		printfflush();
		signal Detector.ExitDetected();
	}
	
	

}