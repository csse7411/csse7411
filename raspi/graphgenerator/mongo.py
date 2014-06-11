from pymongo import MongoClient
import datetime, time


# Mongo Database class for python
class mongo:
	# init addr is string, port is int, db_name is string collection_name is string
	def __init__(self,addr,port,db_name,collection_name):
		self.client = MongoClient(addr,port) #'localhost', 27017
		self.db = self.client[db_name] #'Sensors'
		self.collection = self.db[collection_name] #'mycollection'
	
	#Return the raw sensor data seperated into a dictionary
	#The dictionary keys are the sensors name
	#E.g. 'Android1' is a key for the dictionary
	def get_array(self):
		Sensor_Array = {}
		for a in self.collection.find():
			ok = 0
			for b in Sensor_Array.keys():
				if(b == a[a.keys()[2]]):
					ok = 1
					break
			if(ok == 0):
				Sensor_Array[a[a.keys()[2]]] = []
			t = time.mktime(a[a.keys()[0]].timetuple())
			Sensor_Array[a[a.keys()[2]]].append((t,a[a.keys()[4]],a[a.keys()[5]],a[a.keys()[1]]))
		return Sensor_Array


	#Return a list of the sensors in the database
	#Use this list as the keys of the dictionary for self.get_array()
	def get_nodes(self):
		Sensor_Array = []
		for a in self.collection.find():
			ok = 0
			for b in Sensor_Array:
				if(b == a[a.keys()[2]]):
					ok = 1
					break
			if(ok == 0):
				Sensor_Array.append(a[a.keys()[2]])
		return Sensor_Array
	
	#Returns the raw data as a dictionary
	# takes a start time, end time and a array to read
	def get_array_time(self, start, end, data):
		Sensor_Array = {}
		#data = self.get_array()
		for a in data.keys():
			Sensor_Array[a] = []
		for a in data.keys():
			for b in data[a]:
				if(b[0] >= start and b[0] <= end):
					Sensor_Array[a].append(b)
		return Sensor_Array

	#Returns a tuple with (entry,exit)
	#takes a dictionary of sensors.
	def get_entry_exit(self, data):
		Sensor_Array = {}
		entry = 0
		exit = 0
		for a in data['zig4']:
			if(a[2] == 'laser_on'):
				entry = entry + 1
			elif(a[2] == 'laser_off'):
				exit = exit + 1
		return (entry,exit)

	#Returns a dictionary of activation count of the selected sensor type
	#takes a string for sensor_type and a dictionary for data
	#e.g. self.get_sensortype_activation('sound',self.get_array())
	# -> {'Android1': 5, 'Door': 0}
	def get_sensortype_activation(self,sensor_type,data):
		Sensor_Array = {}
		for a in data.keys():
			Sensor_Array[a] = 0.0
		for a in data.keys():
			for b in data[a]:
				if(b[2] == sensor_type):
					Sensor_Array[a] = Sensor_Array[a] + b[3]
		return Sensor_Array

	#gets the sensortypes in the dictionary	
	#returns a list of sensortypes
	# e.g. ['accel','sound']
	def get_sensortype(self,data):
		out = []
		for a in data.keys():
			for b in data[a]:
				ok = 0
				for c in out:
					if(c == b[2]):
						ok = 1
				if(ok == 0):
					out.append(b[2])
		return out
