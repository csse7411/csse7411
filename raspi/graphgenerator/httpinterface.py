from mongo import *
from truth import *
from analysis import *
from plotting import *

class interface:
	def __init__(self):
		print "Interfacing"
		self.fig = 0

	def average(self,params):
		if(len(params) != 5):
			return
		node = params[3][1]
		sensor = params[4][1]
		if(params[3][0] == "node" and params[4][0] == "sensor"):
				if(sensor == "all" and node != "all"):
					s = self.a.collective_average(self.m, self.t, {node:self.m_time[node]})
				if(sensor == "all" and node == "all"):
					s = []
					for b in self.m_time.keys():
						e = self.a.collective_average(self.m, self.t, {b:self.m_time[b]})
						for d in e:
							s.append(d)
				if(sensor != "all" and node != "all"):
					s = self.a.average(self.m, self.t, sensor, {node:self.m_time[node]})
				if(sensor != "all" and node == "all"):
					s = []
					for b in self.m_time.keys():
						for c in self.m.get_sensortype({b:self.m_time[b]}):
							if(c == sensor):
								e = self.a.average(self.m, self.t, sensor, {b:self.m_time[b]})
								for d in e:
									s.append(d)
				avg = []
				avgx = []
				for b in s:
					avg.append(b[3])
					avgx.append(b[0])
				self.p.add_box(avgx,avg,'g',0,20,"Node:"+str(node)+ " Sensor:" +str(sensor) +" Average")
	
	def weighted_vote(self,params):
		if(len(params) != 5):
			return
		node = params[3][1]
		sensor = params[4][1]
		if(params[3][0] == "node" and params[4][0] == "sensor"):
			c = []
			if(node != "all" and sensor == "all"):
				c = self.a.weighted_vote(self.m,self.t,{node:self.m_time[node]})
			if(node == "all" and sensor == "all"):
				for b in self.m_time.keys():
					for d in self.a.weighted_vote(self.m,self.t,{b:self.m_time[b]}):
						c.append(d)
			if(node != "all" and sensor != "all"):
				b = {node:[]}
				for d in self.m_time[node]:
					if(d[2] == sensor):
						b[node].append(d)
				c = self.a.weighted_vote(self.m,self.t,b)
			if(node == "all" and sensor != "all"):
				for b in self.m_time.keys():
					e = {b:[]}
					for d in self.m_time[b]:
						if(d[2] == sensor):
							e[b].append(d)
					if(len(e[b]) > 0):
						for f in self.a.weighted_vote(self.m,self.t,e):
							c.append(f)
			pos = []
			neg = []
			x = []
			for b in c:
				pos.append(b[3][0])
				neg.append(b[3][1])
				x.append(b[0])
			self.p.add_box(x,pos,'b',0,20,"Node:"+str(node)+ " Sensor:" +str(sensor) +" Pos vote")
			self.p.add_box(x,neg,'r',20,20,"Node:"+str(node)+ " Sensor:" +str(sensor) +" Neg vote")
	
	
	def call_graph(self,graph_type,params):
		self.m = mongo('localhost', 27017,'Sensors','mycollection')
		self.a = analysis()
		self.p = plotting()
		self.t = truth('test.txt')
		self.m_time = self.m.get_array_time(float(params[1][1]), float(params[2][1]),self.m.get_array())
		self.p.new(self.fig)
		if(graph_type == "occupency"):
			c = self.a.room_occupency(self.m, 10,float(params[1][1]),float(params[2][1]))
			self.p.add_line(c[0], c[1], 'b')
		if(graph_type == "average"):
			self.average(params)
		if(graph_type == "weighted"):
			self.weighted_vote(params)
		if(graph_type == "joined"):
			self.average(params)
			self.weighted_vote(params)
		self.p.show_legend()
		self.p.show()
		self.fig = self.fig+1
	
	def extract_param(self,in_str):
		param = []
		function = ""
		for a in in_str.split("&"):
			param.append(a.split("="))
		if(param[0][0] == "graph"):
			self.call_graph(param[0][1],param)
		return self.fig
