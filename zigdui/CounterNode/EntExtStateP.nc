// PIR HPL definition

#include "Timer.h"

#include "printf.h"
#include "laser.h"
#include "EntExtState.h"

module EntExtStateP{
	provides interface EntExtState as EntExtStateMachine;
}
 

implementation {
	

	uint8_t State = 0;
	bool Sens_Status[sizeof(tLaser_Sensor_ID)];
 
	async command void EntExtStateMachine.Process(tLaser_Sensor_ID ID, bool Blocked){
		Sens_Status[ID] = Blocked;	
		switch (State){
			case 0:
			if (((ID == ID_INNER) && (Blocked)) && !Sens_Status[ID_OUTTER])
			{
	
				State = 1;
			}
			if (((ID == ID_OUTTER) && (Blocked))&& !Sens_Status[ID_INNER])
			{
				State = 4;
			}
			break;
	
			case 1:
			if (((ID == ID_OUTTER) && (Blocked))&& Sens_Status[ID_INNER])
			{
				State = 2;
			}  
			if (((ID == ID_INNER) && (!Blocked))&& !Sens_Status[ID_OUTTER])
			{
				State = 0;
			}          
			break;
 
			case 2:
			if (((ID == ID_INNER) && (!Blocked))&& Sens_Status[ID_OUTTER])
			{
				State = 3;
			}  
			if (((ID == ID_INNER) && (Blocked))&& !Sens_Status[ID_OUTTER])
			{
				State = 2;
			}  
			break;
 
			case 3:
			if (((ID == ID_OUTTER) && (!Blocked))&& !Sens_Status[ID_INNER])
			{
				State = 0;
				signal EntExtStateMachine.EntryDetected();
			} 
			if (((ID == ID_OUTTER) && (Blocked))&& Sens_Status[ID_INNER])
			{
				State = 2;
			} 
	
			break;
 
			case 4:
			if (((ID == ID_OUTTER) && (!Blocked))&& !Sens_Status[ID_INNER])
			{
				State = 0;
 
			} 	
			if (((ID == ID_INNER) && (Blocked))&& Sens_Status[ID_OUTTER])
			{
				State = 5;
 
			}   
			break;
 
			case 5:
 
			if (((ID == ID_INNER) && (!Blocked))&& Sens_Status[ID_OUTTER])
			{
				State = 4;
 
			}   
 
			if (((ID == ID_OUTTER) && (!Blocked))&& Sens_Status[ID_INNER])
			{
				State = 6;
 
			}   
			break;
 
			case 6:
			if (((ID == ID_OUTTER) && (Blocked))&& Sens_Status[ID_INNER])
			{
				State = 5;
 
			}   			
			if (((ID == ID_INNER) && (!Blocked))&& !Sens_Status[ID_OUTTER])
			{
				State = 0;
				signal EntExtStateMachine.ExitDetected();
 
			}   
			break;
		}
 
	}
 
	async command void EntExtStateMachine.Reset(){
		State = 0;
	
		Sens_Status[ID_INNER] = FALSE;// unblocked
		Sens_Status[ID_OUTTER] = FALSE;// unblocked
	
		printf("StateProcessor Int\n\r");
		printfflush();
	}
 
}
