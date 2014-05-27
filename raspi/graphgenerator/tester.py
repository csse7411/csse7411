from mongo import *
from truth import *
from analysis import *
from plotting import *
import pylab

t = truth('test.txt')
m = mongo('localhost', 27017,'Sensors','mycollection')
a = analysis()
p = plotting()

master = m.get_array()

s = a.collective_average(m, t, {'zig1':master['zig1']})
avg = []
avgx = []
for b in s:
	avg.append(b[3])
	avgx.append(b[0])

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
p.add_box(avgx,avg,'g',0,20,"Avg")
p.show_legend()
p.show()

c = a.room_occupency(m, 30)
p.new(2)
p.add_line(c[0], c[1], 'b')
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
