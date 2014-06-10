/*
 * Copyright (c) 2012
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holder nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Author: M. D'Souza
 */

configuration HplLsm303C {
	
	provides interface I2CPacket<TI2CBasicAddr> ;//TI2CBasicAddr:TEP117: basic (7-bit) addressing mode
	provides interface Resource;
	provides interface BusPowerManager;
}
implementation {
	// Atm128I2CMasterC:
	// The basic client abstraction of the I2C on the Atmega128. 
	// I2C device drivers should instantiate one of these to ensure exclusive access to the I2C bus.  
	components new Atm128I2CMasterC() as I2CBus;
 
	I2CPacket = I2CBus.I2CPacket;//perform an I2C Master mode Read/write operation 
	Resource  = I2CBus.Resource;//to gain access to shared resources - see TEP108(Resource Arbitration))
	//components I2CBusPowerManagerC; //new DummyBusPowerManagerC();
	//components new DummyBusPowerManagerC() as dbpm;
	//BusPowerManager = I2CBusPowerManagerC;
	components new DummyBusPowerManagerC() as dbpm;
 
	BusPowerManager = dbpm;
}
