from mongo import *
from truth import *
from analysis import *
from plotting import *
from zone import *

class interface:
	def __init__(self):
		print "Interfacing"
		self.fig = 0

	def average(self,params):
		if(len(params) != 6):
			return
		zone = params[1][1]
		node = params[2][1]
		sensor = params[3][1]
		if(params[2][0] == "sensor" and params[3][0] == "sensortype"):
				if(sensor == "all" and node != "all"):
					s = self.a.collective_average(self.m, self.t, {node:self.m_time[node]},self.start)
				if(sensor == "all" and node == "all"):
					s = []
					for b in self.m_time.keys():
						e = self.a.collective_average(self.m, self.t, {b:self.m_time[b]},self.start)
						for d in e:
							s.append(d)
				if(sensor != "all" and node != "all"):
					s = self.a.average(self.m, self.t, sensor, {node:self.m_time[node]},self.start)
				if(sensor != "all" and node == "all"):
					s = []
					for b in self.m_time.keys():
						for c in self.m.get_sensortype({b:self.m_time[b]}):
							if(c == sensor):
								e = self.a.average(self.m, self.t, sensor, {b:self.m_time[b]},self.start)
								for d in e:
									s.append(d)
				avg = []
				avgx = []
				for b in s:
					avg.append(b[3])
					avgx.append(b[0])
				#width = (avgx[len(avgx)-1]-avgx[0])/(len(avg)*2)
				#if(width == 0):
				width = 10
				if(len(avgx) > 0):
					self.p.add_box(avgx,avg,'g',0,width,"Node:"+str(node)+ " Sensor:" +str(sensor) +" Average")
	
	def weighted_vote(self,params):
		if(len(params) != 6):
			return
		zone = params[1][1]
		node = params[2][1]
		sensor = params[3][1]
		if(params[2][0] == "sensor" and params[3][0] == "sensortype"):
			c = []
			if(node != "all" and sensor == "all"):
				c = self.a.weighted_vote(self.m,self.t,{node:self.m_time[node]},self.start)
			if(node == "all" and sensor == "all"):
				for b in self.m_time.keys():
					for d in self.a.weighted_vote(self.m,self.t,{b:self.m_time[b]},self.start):
						c.append(d)
			if(node != "all" and sensor != "all"):
				b = {node:[]}
				for d in self.m_time[node]:
					if(d[2] == sensor):
						b[node].append(d)
				c = self.a.weighted_vote(self.m,self.t,b,self.start)
			if(node == "all" and sensor != "all"):
				for b in self.m_time.keys():
					e = {b:[]}
					for d in self.m_time[b]:
						if(d[2] == sensor):
							e[b].append(d)
					if(len(e[b]) > 0):
						for f in self.a.weighted_vote(self.m,self.t,e,self.start):
							c.append(f)
			pos = []
			neg = []
			x = []
			for b in c:
				if(b[3][0] > b[3][1]):
					pos.append(b[3][0])
					neg.append(b[3][1])
					x.append(b[0])
			#width = (x[len(x)-1]-x[0])/(len(pos)+len(neg))
			#if(width > 10):
			width = 10
			if(len(x) > 0):
				self.p.add_box(x,pos,'b',0,width,"Node:"+str(node)+ " Sensor:" +str(sensor) +"Weighted Vote")
			#self.p.add_box(x,neg,'r',width,width,"Node:"+str(node)+ " Sensor:" +str(sensor) +" Neg vote")
	
	def heatmap(self,params):
		if(len(params) != 6):
			return
		start = self.start#self.a.get_time_bounds(self.m_time)[0]
		end = self.end#self.a.get_time_bounds(self.m_time)[1]
		count = 1000
		d = self.m.get_entry_exit(self.m.get_array_time(0,start,self.m.get_array()))
		pop = d[0]-d[1]
		print pop
		while start<=end:
			self.p.new(count)
			try:
				heat_array = self.m.get_array_time(start,start+15,self.m_time)
				d = self.m.get_entry_exit(heat_array)
				pop = pop + (d[0]-d[1])
				zones = self.a.heat_map(self.m,self.t,self.z,heat_array,self.start)
				total = 0.00001
				x = 3
				y = 3
				i = 1
				for a in zones.keys():
					total = total + zones[a]
				for a in zones.keys():
					if(zones[a] == 0):
						self.p.add_ellipse(x,y,1,'black',"Zone"+str(i)+":"+str((zones[a]/total)*pop))				
					elif(zones[a] <= 10):
						self.p.add_ellipse(x,y,1,'blue',"Zone"+str(i)+":"+str((zones[a]/total)*pop))
					elif(zones[a] > 10 and zones[a] <= 15):
						self.p.add_ellipse(x,y,2+(zones[a]/15),'yellow',"Zone"+str(i)+":"+str((zones[a]/total)*pop))
					elif(zones[a] > 15 and zones[a] <=20):
						self.p.add_ellipse(x,y,3+(zones[a]/20),'orange',"Zone"+str(i)+":"+str((zones[a]/total)*pop))
					else:
						self.p.add_ellipse(x,y,3+(zones[a]/20),'red',"Zone"+str(i)+":"+str((zones[a]/total)*pop))
					if(i == 1):
						x = 7
					if(i == 2):
						x = 3
						y = 7
					if(i == 3):
						x = 7
					i = i + 1
			except:
				a = 1
			start = start+15
			self.p.show_legend()
			self.p.show()
			count=count+1
	
	def call_graph(self,graph_type,params):
		self.m = mongo('10.0.0.1', 27017,'rktest','sensors')
		self.a = analysis()
		self.p = plotting()
		self.t = truth('test.txt')
		self.z = zone('zone.txt')
		print params
		dates = params[4][1].split("/")[0].split("-")
		times = params[4][1].split("/")[1].split(":")
		start = datetime.datetime(int(dates[2]),int(dates[1]),int(dates[0]),int(times[0]),int(times[1]),int(times[2]));
		dates = params[5][1].split("/")[0].split("-")
		times = params[5][1].split("/")[1].split(":")
		end = datetime.datetime(int(dates[2]),int(dates[1]),int(dates[0]),int(times[0]),int(times[1]),int(times[2]));
		start = time.mktime(start.timetuple())-36000
		end = time.mktime(end.timetuple())-36000
		self.start = start
		self.end = end
		print start
		print end
		self.m_time = self.m.get_array_time(start, end,self.m.get_array())
		if(graph_type == "occupancy"):
			self.p.new(self.fig)
			try:
				c = self.a.room_occupency(self.m, 0,start,end)
				self.p.add_line(c[0], c[1], 'b')
				self.p.show_legend()
			except:
				a = 1
			self.p.show()
		if(graph_type == "average"):
			self.p.new(self.fig)
			self.average(params)
			self.p.show_legend()
			self.p.show()
		if(graph_type == "weighted"):
			self.p.new(self.fig)
			self.weighted_vote(params)
			self.p.show_legend()
			self.p.show()
		if(graph_type == "joined"):
			self.p.new(self.fig)
			self.average(params)
			self.weighted_vote(params)
			self.p.show_legend()
			self.p.show()
		if(graph_type == "heat"):
			self.heatmap(params)
		self.fig = self.fig+1
	
	def extract_param(self,in_str):
		param = []
		function = ""
		for a in in_str.split("&"):
			param.append(a.split("="))
		if(param[0][0] == "graph"):
			self.call_graph(param[0][1],param)
		return self.fig
