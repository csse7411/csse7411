#include "TinyError.h"
#include "EntExtState.h"
#include "laser.h"
interface EntExtState
{
	async command void Process(tLaser_Sensor_ID, bool Blocked);
	async command void Reset();
 
	async event void EntryDetected();
	async event void ExitDetected();
}
