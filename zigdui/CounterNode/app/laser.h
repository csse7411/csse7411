#ifndef _LASER_H_
#define _LASER_H_

typedef struct SensorsDataType{
	uint16_t LaserInner;
	uint16_t LaserOutter; 
}tSensorData;

typedef enum SensorType{
	LASER_INNER = 0,
	LASER_OUTTER
}tSensor;
typedef enum Laser_Sensor_ID_Type{
    ID_INNER = 0,
    ID_OUTTER
}tLaser_Sensor_ID;
typedef enum Laser_Beam_Status_Type{
    LASER_BEAM_STAT_BLOCKED = 0,
    LASER_BEAM_STAT_UNBLOCKED
}tLaser_Beam_Status;
typedef enum Movement_Dir_Type{
    Dir_Enter = 1,
    Dir_Exit
}Movement_Dir_t;
#endif
