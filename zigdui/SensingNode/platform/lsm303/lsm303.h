/*
* Copyright (c) 2012
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
* - Redistributions of source code must retain the above copyright
* notice, this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above
* copyright notice, this list of conditions and the following
* disclaimer in the documentation and/or other materials provided
* with the distribution.
* - Neither the name of University of Szeged nor the names of its
* contributors may be used to endorse or promote products derived
* from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
* FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
* COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
* STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*
* Author: M. D'Souza
*/

#ifndef LSM303_H
#define LSM303_H

typedef struct lsm303_data {
  int16_t accel_x;
  int16_t accel_y;
  int16_t accel_z;
} lsm303_data_t;

//Constants for accessing sensor values
#define LSM303_ACC_X	1
#define LSM303_ACC_Y	2
#define LSM303_ACC_Z	3
#define LSM303_MAG_X	4
#define LSM303_MAG_Y	5
#define LSM303_MAG_Z	6

#define LSM303_MODE				32
#define LSM303_CONTINUOUS		1
#define LSM303_SINGLE			0

// The Arduino two-wire interface uses a 7-bit number for the address, 
// and sets the last bit correctly based on reads and writes
#define ACC_ADDRESS_WRITE 		0x30
#define ACC_ADDRESS_READ 		0x31

#define ACC_ADDRESS				0x18	//0x18
#define MAG_ADDRESS				0x1E

#define MAG_ADDRESS_WRITE 		0x3C
#define MAG_ADDRESS_READ 		0x3D

#define CONTINUOUS_READ			0x80

#define CTRL_REG1_A 		0x20
#define CTRL_REG2_A 		0x21
#define CTRL_REG3_A 		0x22
#define CTRL_REG4_A			0x23
#define CTRL_REG5_A 		0x24
#define HP_FILTER_RESET_A 	0x25
#define REFERENCE_A 		0x26
#define STATUS_REG_A 		0x27

#define OUT_X_L_A  			0x28
#define OUT_X_H_A  			0x29
#define OUT_Y_L_A  			0x2A
#define OUT_Y_H_A  			0x2B
#define OUT_Z_L_A  			0x2C
#define OUT_Z_H_A  			0x2D

#define INT1_CFG_A  		0x30
#define INT1_SOURCE_A  		0x31
#define INT1_THS_A  		0x32
#define INT1_DURATION_A  	0x33
#define INT2_CFG_A  		0x34
#define INT2_SOURCE_A  		0x35
#define INT2_THS_A  		0x36
#define INT2_DURATION_A  	0x37

#define CRA_REG_M  			0x00
#define CRB_REG_M  			0x01
#define MR_REG_M  			0x02

#define OUT_X_H_M  			0x03
#define OUT_X_L_M  			0x04
#define OUT_Y_H_M  			0x05
#define OUT_Y_L_M  			0x06
#define OUT_Z_H_M  			0x07
#define OUT_Z_L_M  			0x08

#define SR_REG_M   			0x09
#define IRA_REG_M   		0x0A
#define IRB_REG_M   		0x0B
#define IRC_REG_M   		0x0C

/*
 * LSM303 register addresses  
 */
#define LSM303_ACC50HZ	0x27		//Enable accelerometer - 50Hz sampling rate. See page of LSM303 datasheet
#define LSM303_ACC100HZ	0x3F		//Enable accelerometer - 50Hz sampling rate. See page of LSM303 datasheet


#endif

