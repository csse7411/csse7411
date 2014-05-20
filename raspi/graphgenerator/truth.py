

class truth:
	
	#Takes a file to get the truth data from
	def __init__(self,filename):
		self.truth_table = {}
		fd=open(filename,'rb')
		for line in fd.readlines():
			tmp = line.split(",")
			ok = 0
			for a in self.truth_table.keys():
				if(tmp[0] == a):
					ok = 1
					break
			if(ok == 0):
				self.truth_table[tmp[0]] = {}
			ok = 0
			for a in self.truth_table[tmp[0]].keys():
				if(tmp[1] == a):
					ok = 1
					break
			if(ok == 0):
				self.truth_table[tmp[0]][tmp[1]] = float(tmp[2])
	
	#returns the truth table dictionary
	def get_table(self):
		return self.truth_table

	#used to apply the truth to the raw data
	#returns the new data with truth applied to it
	def parse_raw(self,data):
		out = {}
		for a in data.keys():
			out[a] = []
		for a in self.truth_table.keys():
			for b in self.truth_table[a].keys():
				try:
					for c in data[a]:
						if(c[2] == b):
							out[a].append((c[0],c[1],c[2],float(c[3])*float(self.truth_table[a][b])))
				except:
					continue
		return out