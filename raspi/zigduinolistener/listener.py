"""
Listen for any incoming data on /dev/ttyUSB0
Request a POST API call and forward the data to webserver
"""
#!/usr/bin/python

import serial
import threading
import time
import sys


# read loop for serial port
def read_loop():

  output = ''
  while read_data:
    try:
      data = s.read();
      if len(data) > 0:
        output += data
        if (data[-1]=='\n'):
          print 'Mote:', output
          output = ''
    except Exception, e:
      print "Exception:", e

  # close serial port
  print "close serial port"
  s.close()

# Return automatic command or user input
def get_command(command):
  if len(sys.argv) > 2 and sys.argv[2] == 'a':
    return command
  return raw_input('Enter command:')

# ============= main application starts here ==================

# init serial port
if len(sys.argv) > 1:
  s = serial.Serial(port = sys.argv[1], baudrate = 115200)
else:
  s = serial.Serial(port = '/dev/ttyUSB0', baudrate = 115200) # Zigduino
#s = serial.Serial(port = '/dev/ttyACM0', baudrate = 115200) # UCBase

s.open()

# start read_loop in a separate thread
read_data = True
t1 = threading.Thread(target=read_loop, args=())
t1.start()

# Loop to keep the program running
while True:
  try:
    time.sleep(1)
  except KeyboardInterrupt:
    print "Shutdown"
    break

read_data = False