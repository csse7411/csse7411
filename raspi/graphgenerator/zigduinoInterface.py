#!/usr/bin/python

import serial
import threading
import time

# read loop for serial port
def read_loop():

  output = ''
  while read_data:
    try:
      data = s.read();
      if len(data) > 0:
        output += data
        if (data[-1]=='\n'):
          print 'Zig:', output
          output = ''
    except Exception, e:
      print "Exception:", e

  # close serial port
  print "close serial port"
  s.close()



# ============= main application starts here ==================

# init serial port
s = serial.Serial(port = '/dev/ttyUSB0', baudrate = 115200) # Zigduino
#s = serial.Serial(port = '/dev/ttyACM0', baudrate = 115200) # UCBase
s.open()


# start read_loop in a separate thread
read_data = True
t1 = threading.Thread(target=read_loop, args=())
t1.start()

# send loop for serial port
while True:
  try:
      time.sleep(1)
  except KeyboardInterrupt:
    print "Shutdown"
    break

read_data = False

