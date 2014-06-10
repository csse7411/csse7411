#include "TinyError.h"

interface LaserEntExDetector
{
	// is fired when an entracnce to the room is detected
	async event void EntryDetected();
    // is fired when someone has left the room
    async event void ExitDetected();
	

}
