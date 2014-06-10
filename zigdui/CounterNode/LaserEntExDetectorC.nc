// PIR module configuration

#include "Timer.h"

configuration LaserEntExDetectorC {
	provides interface LaserEntExDetector as EntExtDetector;
}

implementation {
	components EntExtStateP;
	LaserEntExtDetectorP.StateProcessor -> EntExtStateP.EntExtStateMachine;
	
	components new TimerMilliC() as LaserBeamTimer;
	LaserEntExtDetectorP.LaserEmeaterTimer -> LaserBeamTimer;
	//	components new PIRP();
	components LaserEntExtDetectorP, MainC;
	MainC.SoftwareInit -> LaserEntExtDetectorP;
	EntExtDetector = LaserEntExtDetectorP.Detector;
 
	components ZigduinoDigitalPortsC;
	LaserEntExtDetectorP.Laser_Inner -> ZigduinoDigitalPortsC.Interrupt0;
	LaserEntExtDetectorP.Laser_Outter -> ZigduinoDigitalPortsC.Interrupt1;
	//components HplAtmegaPinChange;
	//LaserEntExtDetectorP.LowLevelPin -> HplAtmegaPinChange;
   
    LaserEntExtDetectorP.LaserDiod -> ZigduinoDigitalPortsC.DigitalPin[2];
	
}	
