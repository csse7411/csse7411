class analysis:
	
	def __init__(self):
		print "Analysis Started!"

	def get_time_bounds(self, data):
		start = 9999999999999
		end = 0
		for a in data.keys():
			for b in data[a]:
				if(b[0] < start):
					start = b[0]
				if(b[0] > end):
					end = b[0]
		return (start,end)
	
	def calculate_time_split(self, mon, data):
		end = self.get_time_bounds(data)[1]
		start  = self.get_time_bounds(data)[0]
		count = 0
		largest = 0
		avg = []
		while start <= end:
			time_data = mon.get_array_time(start,start+1,data)
			activity = 0
			for a in time_data.keys():
				p = {a:time_data[a]}
				if(len(mon.get_sensortype(p)) > 0):
					activity = 1
			if(activity == 0):
				count = count + 1
				if(count > largest):
					largest = count
			else:
				if(count > 0):
					avg.append(count)
				count = 0
			start = start + 1
		count = 0
		for a in avg:
			count = a + count
		if(len(avg) == 0):
			return 1
		else:
			p = count/len(avg)
		count = 0
		out = []
		for a in avg:
			if((a > p-p) and (a < p+p)):
				out.append(a)
				count = count + a
		return count/len(out)

	def sum_vote(self, data):
		out = 0
		for a in data:
			out = out + a
		return out

	def average_activation(self, mon, data):
		time_split = self.calculate_time_split(mon, data)
		end = self.get_time_bounds(data)[1]
		start  = self.get_time_bounds(data)[0]
		node = data.keys()[0]
		sensors = mon.get_sensortype(data)
		time_blocks = 0
		avg = {}
		while start <= end:
			time_blocks = time_blocks + 1
			start = start + time_split
		for a in sensors:
			avg[a] = mon.get_sensortype_activation(a,data)[node]/time_blocks
		return avg

	def weighted_vote(self, mon, truth, data, start_true):
		#print "Weighted Vote"
		time_split = self.calculate_time_split(mon, data)
		if(time_split < 1):
			time_split = 1
		end = self.get_time_bounds(data)[1]
		start  = self.get_time_bounds(data)[0]
		node = data.keys()[0]
		sensors = mon.get_sensortype(data)
		avg = self.average_activation(mon, data)
		truth_value = truth.get_table()[node]
		out = [(0,'none','weighted_vote', (0,0))]
		while start <= end:
			#print "### Start: "+str(start)+" End: "+str(start+time_split)
			sub_array = mon.get_array_time(start, start+time_split, data)
			truth_array = truth.parse_raw(sub_array)
			pos = []
			neg = []
			for a in sensors:
				s = mon.get_sensortype_activation(a,sub_array)[node]
				t = mon.get_sensortype_activation(a,truth_array)[node]
				if(s == 0):
					pos.append(avg[a]*(1-truth_value[a]))
					neg.append(avg[a]*truth_value[a])
				else:
					pos.append(t)
					neg.append(s-t)
			out.append((start-start_true, 'none', 'weighted_vote', (self.sum_vote(pos),self.sum_vote(neg))))
			start = start + time_split
		#print "Done!"
		return out

	def calculate_block_activity(self, time,node,data):
		count = len(data[node])
		return time/(count*1.0)
	
	def seperate_sensors(self, node, sensor, data):
		out = []
		for a in data[node]:
			if(a[2] == sensor):
				out.append(a)
		return {node: out}
	
	def average(self, mon, truth, sensor, data, start_true):
		#print "Average Vote"
		node = data.keys()[0]
		data = self.seperate_sensors(node, sensor, data)
		end = self.get_time_bounds(data)[1]
		start  = self.get_time_bounds(data)[0]
		total_time = end-start
		truth_array = truth.parse_raw(data)
		truth_value = truth.get_table()[node]
		activity_sum = truth_value[sensor]
		block = self.calculate_block_activity(total_time, node, truth_array) #one activity every x seconds
		if(block < 1):
			block = 1
		out = [(0,'none','average_vote',0)]
		while start <= end:
			activity = 0
			for a in truth_array[node]:
				if((a[0] >= start) and (a[0] <= (start+block))):
					activity = activity + activity_sum
			if(activity > (1+(1*activity_sum)-activity_sum)):#blah
				 out.append((start-start_true, 'none', 'average_vote', activity))
			start = start + block
		return out

	def sort(self, data):
		out = []
		old_data = data
		pos = 0
		while len(old_data) > 0:
			small = 99999999999
			for a in enumerate(old_data):
				if(a[1][0] < small):
					pos = a[0]
					small = a[1][0]
			out.append(old_data.pop(pos))
		return out

	def collective_average(self, mon, truth, data,start_true):
		sensors = mon.get_sensortype(data)
		out = []
		for a in sensors:
			for b in self.average(mon, truth, a, data, start_true):
				out.append(b)
		return self.sort(out)

	def room_occupency(self, mon, init,start,end):
		data = mon.get_array()
		node = 'zig4'
		data = {node: data[node]}
		#start = self.get_time_bounds(data)[0]
		#end = self.get_time_bounds(data)[1]
		out_x = [start-1,start]
		out_y = [0,init]
		block = self.calculate_block_activity(end-start, node, data) #one activity every x seconds		
		while start <= end:
			a = mon.get_entry_exit(mon.get_array_time(start, start+block,data))
			print a
			if(a[0]>0 or a[1]>0):
				out_x.append(start)
				out_y.append(out_y[len(out_y)-1]+(a[0]-a[1]))
			start = start + block
		return (out_x, out_y)

	def heat_map(self, mon, truth, zones, data,start_true):
		#end = self.get_time_bounds(data)[1]
		#start  = self.get_time_bounds(data)[0]
		#total_time = end-start
		zone_mag = {}
		zone_dict = zones.get_zones()
		total = 0
		for z in zones.get_zones().keys():
			mag = 0
			for node in zone_dict[z]:
				try:
					col = self.collective_average(mon, truth, {node:data[node]},start_true)
					#wv = self.weighted_vote(mon,truth,{node:data[node]},start_true)
					mag = mag+len(col)#+len(wv)
				except:
					mag = mag + 0
			zone_mag[z] = mag
			total = total + mag
		return zone_mag
