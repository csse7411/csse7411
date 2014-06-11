from mongo import *
from truth import *
from analysis import *

class zone:
	def __init__(self, file):
		self.zones = {}
		print "zone"
		fd = open(file,'rb')
		for lines in fd:
			a = lines.split(":")
			out = []
			for b in a[1].split(","):
				out.append(b.replace('\n',""))
			self.zones[a[0]] = out
		fd.close()
	
	def get_zones(self):
		return self.zones
