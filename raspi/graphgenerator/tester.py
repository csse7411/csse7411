from mongo import *
from truth import *

t = truth('test.txt')
m = mongo('localhost', 27017,'Sensors','mycollection')

master = m.get_array()

out = t.parse_raw(master)

for a in m.get_sensortype(master):
	print a
	print m.get_sensortype_activation(a,out)