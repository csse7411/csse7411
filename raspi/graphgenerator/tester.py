from mongo import *
from truth import *
from analysis import *
from plotting import *
import pylab

t = truth('test.txt')
m = mongo('10.0.0.1', 27017,'rktest','sensors')
a = analysis()
p = plotting()

master = m.get_array()
#print m.get_nodes()
end_time = a.get_time_bounds(master)[1]
start_time = end_time-800
master = m.get_array_time(start_time,end_time,master)
#print m.get_array_time(0,end_time,master)
#print m.get_sensortype(master)
#print m.get_sensortype_activation('VC',master)
#print m.get_sensortype_activation('ACCL',master) 
#print t.get_table()
tmaster = t.parse_raw(master)
i = 0
for d in m.get_nodes():
	print d
	col = a.collective_average(m,t,{d:master[d]})
	wv = a.weighted_vote(m,t,{d:master[d]})
	#print col
	#print wv
	pos = []
	neg = []
	x = []
	for b in wv:
		pos.append(b[3][0])
		neg.append(b[3][1])
		x.append(b[0])
	p.new(i)
	i = i + 1
	p.add_box(x,pos,'b',0,2,"Pos")
	p.add_box(x,neg,'r',2,2,"Neg")
	p.show_legend()
	p.show()

	ay = []
	ax = []
	for b in col:
		ay.append(b[3])
		ax.append(b[0])
	p.new(i)
	i = i + 1
	p.add_box(ax,ay,'g',0,2,"Avg")
	p.show_legend()
	p.show()
	
	pos = []
	neg = []
	x = []
	for b in wv:
		pos.append(b[3][0])
		neg.append(b[3][1])
		x.append(b[0])
	
	ay = []
	ax = []
	for b in col:
		ay.append(b[3])
		ax.append(b[0])
	p.new(i)
	i = i + 1
	p.add_box(x,pos,'b',0,2,"Pos")
	p.add_box(x,neg,'r',2,2,"Neg")
	p.add_box(ax,ay,'g',0,2,"Avg")
	p.show_legend()
	p.show()
	
	rx = []
	ry = []
	end = a.get_time_bounds({d:master[d]})[1]
	start = a.get_time_bounds({d:master[d]})[0]
	total_time = end-start
	block = 1#a.calculate_block_activity(total_time,"andro2",master)
	if(block < 1):
		block = 1
	while start<=end:
		ry.append(len(m.get_array_time(start,start+block,{d:master[d]})[d]))
		rx.append(start)
		start = start+block
	p.new(i)
	i=i+1
	p.add_box(rx,ry,'',0,2,"Raw")
	p.show_legend()
	p.show()


def graphs_test():
	pos = []
	neg = []
	x = []
	for b in master.keys():
		#print master[b]
		print b
		c = a.weighted_vote(m,t,{b:master[b]})
	
	for b in c:
		pos.append(b[3][0])
		neg.append(b[3][1])
		x.append(b[0])
	print master['android1']
	p.new(1)
	p.add_box(x,pos,'b',0,20,"Pos vote")
	p.add_box(x,neg,'r',20,20,"Neg vote")
	p.show_legend()
	p.show()
	
	c = a.weighted_vote(m,t,{'zig1':master['zig1']})
	
	pos = []
	neg = []
	x = []
	for b in c:
		pos.append(b[3][0])
		neg.append(b[3][1])
		x.append(b[0])
	print master['zig1']
	p.new(1)
	p.add_box(x,pos,'b',0,20,"Pos vote")
	p.add_box(x,neg,'r',20,20,"Neg vote")
	p.show_legend()
	p.show()
