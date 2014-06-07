#!/usr/bin/python
import urllib
import urllib2

url = 'http://10.0.0.1:3000/api/sensors'

import serial
import threading
import time

sensor = ["","LASER","PIR","ACL"]
# read loop for serial port
def read_loop():

  output = ''
  while read_data:
    try:
      data = s.read();
      if len(data) > 0:
        output += data
        if (data[-1]=='\n'):
		d = data.split(":")
		if(str(d[2]) == "A5"):
			values = {'sensortype' : 'zig'+str(d[0]),'sensor' : 'laser_on','value' : '1' }
			data = urllib.urlencode(values)
		elif(str(d[2]) == "5A"):
			values = {'sensortype' : 'zig'+str(d[0]),'sensor' :'laser_off','value' : '1' }
			data = urllib.urlencode(values)
		else:
			values = {'sensortype' : 'zig'+str(d[0]),'sensor' : str(sensor[d1]),'value' : '1' }
			data = urllib.urlencode(values)
		urllib2.Request(url, data)

    except Exception, e:
      print "Exception:", e

  # close serial port
  print "close serial port"
  s.close()



# ============= main application starts here ==================

# init serial port
s = serial.Serial(port = '/dev/ttyUSB0', baudrate = 115200) # Zigduino
#s = serial.Serial(port = '/dev/ttyACM0', baudrate = 115200) # UCBase
#s.open()


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

