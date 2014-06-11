import pylab
from matplotlib.patches import Ellipse
import datetime

class plotting:
	
	def __init__(self):
		print "Plotter"

	def new(self, fig):
		self.fig = fig
		self.figure = pylab.figure(fig)

	def sort_list(self,x_list, y_list):
		out_x = []
		out_y = []
		while(len(x_list) > 0):
			small = 99999999999999
			pos = 0
			for a in enumerate(x_list):
				if(a[1] <= small):
					pos = a[0]
					small = a[1]
			out_x.append(x_list.pop(pos))
			out_y.append(y_list.pop(pos))
		return (out_x, out_y)
	
	def xtodate(self,x_list):
		out = []
		for a in x_list:
			out.append(str(datetime.timedelta(seconds=a)))
		return out

	def add_ellipse(self,x,y,size,col,title):
		e = Ellipse((x,y),size,size,0,color = col)
		ax = self.figure.add_subplot(111,aspect='equal')
		e.set_clip_box(ax.bbox)
		ax.add_artist(e)
		pylab.xlim(0,10)
		pylab.ylim(0,10)
		pylab.plot([0],[0], 'white',label=title)
		
	
	def add_line(self, x_list, y_list, col):
		a = self.sort_list(x_list, y_list)
		#b = self.xtodate(a[0])
		pylab.plot(a[0],a[1], col)

	def add_box(self,x_list, y_list, col, x_offset, box_size, title):
		new_x = []
		for a in x_list:
			new_x.append(a+x_offset)
		a = self.sort_list(new_x, y_list)
		#b = self.xtodate(a[0])
		pylab.bar(a[0], a[1],box_size, alpha=0.4, color=col, yerr=0, error_kw={'ecolor': '0.3'}, label=title)

	def xlabel(self, title):
		pylab.xlabel(title)

	def ylabel(self, title):
		pylab.ylabel(title)

	def title(self, title):
		pylab.title(title)

	def show_legend(self):
		pylab.legend()

	def show(self):
		pylab.savefig("../webserver/public/images/"+str(self.fig)+".png", bbox_inches='tight')
		#pylab.show()
