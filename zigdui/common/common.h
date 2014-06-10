
#ifndef _OOD_COMMON_H
#define _OOD_COMMON_H

#define RADIO_ID_BASE  0x80

#define THIS_NODE_ID ( (const int)(RADIO_ID_BASE + TOS_NODE_ID))

#define RECEIVER_ID 98
// enum __attribute__ ((__packed__)) 
typedef enum {
SENSOR_LASER = 1,
SENSOR_PIR  = 2,
SENSOR_VIBRATION = 3
}Sensor_t;

enum {
DIR_ENTER = 0xA5,
DIR_EXIT  = 0x5A
};

enum{
VIBRATING = 0xA5
};
enum{
PIR_ACTIVATED = 0x99
};

typedef nx_struct Packet {
  nx_uint16_t ID; /* THIS_NODE_ID */
  nx_uint8_t Sensor;
  nx_uint8_t Data; 
} Packet_t;

#define NREADINGS 8

//Accelerometer Data
typedef struct AcclDataType {
  uint16_t count; /* The readings are samples count * NREADINGS onwards */
  uint16_t readings[NREADINGS];
} AcclData_t;

#endif //_OOD_COMMON_H

