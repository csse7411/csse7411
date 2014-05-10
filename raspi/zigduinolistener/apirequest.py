import urllib2, urllib

def senddata(sensortype, sensor, value):
	mydata=[('sensortype',sensortype),('sensor',sensor), ('value', value)]    #The first is the var name the second is the value
	mydata=urllib.urlencode(mydata)
	path='http://localhost:3000/api/sensors'    #the url you want to POST to
	req=urllib2.Request(path, mydata)
	req.add_header("Content-type", "application/x-www-form-urlencoded")
	page=urllib2.urlopen(req).read()
	assert(page == "Saved")
	print page

if __name__ == "__main__":
	senddata('zigduino','pir','1')