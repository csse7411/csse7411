/*
 * Copyright (c) 2012
 * All rights reserved.
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
 * Author: W. Hu
 */

//NOTE: Only implements Accelerometer reading, not Magnetometer.

#include "lsm303.h"
#include "printf.h"
//#define DEBUG_LSM303 

//#define DEBUG
//TODO: norace or atomic (state, i2cBuffer)
//TODO: testing: SetPrecision
module Lsm303P {
	provides interface Read<lsm303_data_t> as ReadXYZout;
	provides interface Read<uint8_t> as ReadSR;
	provides interface Set<uint8_t> as SetMode;
	provides interface Init;
	uses 
	{
		interface I2CPacket<TI2CBasicAddr>;
		interface Resource as I2CResource;
		interface BusPowerManager;
	}
}

implementation {

	enum  {
		LSM303_TIMEOUT_4096=10,
		LSM303_TIMEOUT_2048=5,
		LSM303_TIMEOUT_1024=3,
		LSM303_TIMEOUT_512=2,
		LSM303_TIMEOUT_256=1,
		LSM303_TIMEOUT_RESET=3,
	} LSM303_timeout; //in ms
 
	enum {
		S_OFF = 0,
		S_IDLE = 1,
		S_MODE_CMD = 2,
		S_READ_SR_CMD = 3,
		S_READ_XYZOUT_CMD = 4
	};
 
	norace uint8_t state=S_OFF;
	norace uint8_t i2cBuffer[2];
	norace int16_t xoutValue, youtValue, zoutValue;
	norace uint8_t modeValue, srValue; 
	norace lsm303_data_t xyzoutValue;
	norace error_t lastError;
 
	//Initialise I2C bus 
	command error_t Init.init() {
		#ifdef DEBUG
		printf("Initing lsm303p\n\r");
		printfflush();
		#endif  
		call BusPowerManager.configure(LSM303_TIMEOUT_RESET, LSM303_TIMEOUT_RESET);
		#ifdef DEBUG
		printf("lsm303p init done\n\r");
		printfflush();
		#endif  

		return SUCCESS;
	}
 
	//Set Mode Register Command
	command void SetMode.set(uint8_t mode_setting) {
		modeValue = mode_setting;
		state = S_MODE_CMD;
		call BusPowerManager.requestPower();
		call I2CResource.request();
	}
 
	//Process I2C read done signal
	//Pass I2C read values to event handlers
	task void signalReadDone() {

		switch(state){
	
			case S_READ_XYZOUT_CMD:{
				state=S_IDLE;
				call BusPowerManager.releasePower();

				#ifdef DEBUG_LSM303
				printf("LSM303P DEBUG: xyzoutValue %d %d %d\n\r", xyzoutValue.accel_x, xyzoutValue.accel_y, xyzoutValue.accel_z); 
				printfflush();
				#endif
				//Return X Y Z values
				signal ReadXYZout.readDone(lastError, (lsm303_data_t) xyzoutValue);
			}break;
			case S_READ_SR_CMD:{
				state=S_IDLE;
				call BusPowerManager.releasePower();
				#ifdef DEBUG
				printf("LSM303P DEBUG: srValue RD %X\n\r", srValue);
				printfflush();
				#endif
				signal ReadSR.readDone(lastError, srValue);
			}break;
		}
	}
 
	//Read ACC XYZ
	command error_t ReadXYZout.read() {
		uint8_t prevState=state;
		if(state > S_IDLE)
			return EBUSY;
 
		state=S_READ_XYZOUT_CMD;
		call BusPowerManager.requestPower();
		if(prevState==S_IDLE)
			call I2CResource.request();
		return SUCCESS;
	}

	//Read Status Register
	command error_t ReadSR.read() {
		uint8_t prevState=state;
		if(state > S_IDLE)
			return EBUSY;
 
		state=S_READ_SR_CMD;
		call BusPowerManager.requestPower();
		if(prevState==S_IDLE)
			call I2CResource.request();
		return SUCCESS;
	}  

	event void BusPowerManager.powerOn() {
		if(state==S_OFF)
			state=S_IDLE;
		else
			call I2CResource.request();
	}
 
	event void BusPowerManager.powerOff() {
		state=S_OFF;
	}
 
	//I2C granted event
	event void I2CResource.granted() {
		uint8_t i2cCond=0;
		uint8_t writeLength=1;
	
		switch(state){
			case S_READ_XYZOUT_CMD:{
				i2cCond=I2C_START;
				i2cBuffer[0]=OUT_X_L_A | CONTINUOUS_READ;
			} break;
			case S_READ_SR_CMD:{
				i2cCond=I2C_START;
				i2cBuffer[0]=CTRL_REG1_A;
			} break;
			case S_MODE_CMD:{
				i2cCond=I2C_START|I2C_STOP;
				i2cBuffer[0]= CTRL_REG1_A; //MR_REG_M;
				i2cBuffer[1] = modeValue;			//Set to active mode.
				writeLength = 2;
			} break;

		}

		if (state != S_IDLE) {

			lastError = call I2CPacket.write(i2cCond, ACC_ADDRESS, writeLength, i2cBuffer) ;
	
			if( lastError != SUCCESS) {
				//call I2CResource.release();
				//post signalReadDone();
			}
		}
	}
 
	//I2C Write done event
	async event void I2CPacket.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data) {
		uint8_t readLength=1;

		if(error!=SUCCESS){
			lastError=error;
			call I2CResource.release();
			post signalReadDone();
			return;
		}

		switch(state){

			//Read states
			case S_READ_SR_CMD:
			readLength = 1;
			break;
			case S_READ_XYZOUT_CMD:
			readLength = 6;
			break;

			//Write state
			case S_MODE_CMD:{
				readLength = 1;
				state = S_IDLE;
				call I2CResource.release();
				return;
			}break; 
		}

		//Initiate I2C read
		if ((state != S_MODE_CMD) && (state > S_IDLE)) {
			lastError = call I2CPacket.read(I2C_START|I2C_STOP, ACC_ADDRESS, readLength, i2cBuffer);
			if( lastError != SUCCESS) {
				call I2CResource.release();
				lastError=FAIL;
				post signalReadDone();
			}
		}
	}	
 
	//Read done event
	async event void I2CPacket.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data) {

	
		uint8_t val[6];
		lastError=error;
		if(error!=SUCCESS){
			call I2CResource.release();
			post signalReadDone();
			return;
		}

		switch(state) {

			//Extract X,Y,Z values
			case S_READ_XYZOUT_CMD:{
				call I2CResource.release();
				memcpy(val, data, sizeof(val));
				xyzoutValue.accel_x = val[1] << 8 | val[0];	//X
				xyzoutValue.accel_y = val[3] << 8 | val[2];	//Y
				xyzoutValue.accel_z = val[5] << 8 | val[4];	//Z	
				post signalReadDone();
	
			} break;
			case S_READ_SR_CMD:{
				call I2CResource.release();
				srValue = data[0];
				post signalReadDone();
			} break;
		}
	}
 
}

