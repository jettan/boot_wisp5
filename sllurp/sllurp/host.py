#!/usr/bin/python
from twisted.internet import reactor, defer

# Read the hex file.
f = open("wisp_app.hex", 'r')
lines = f.readlines()

index = 0
current_line = lines[0]

class Getter:
	
	def processLine(self, line_index):
		if self.d is None:
			print "No callback given!"
			return
		
		global current_line
		
		d = self.d
		self.d = None
		
		print current_line[line_index:line_index+2]
		
		if line_index < len(current_line) - 5:
			d.callback(line_index + 2)
		else:
			global lines
			global index
			if (index + 1) < len(lines):
				print "Going to next line...\n"
				index = index + 1
				current_line = lines[index]
				d.callback(1)
			else:
				print "Finished"
				return
	
	def sendLine(self, line_index):
		self.d = defer.Deferred()
		
		reactor.callLater(1, self.processLine, line_index)
		self.d.addCallback(self.sendLine)
		return self.d

def printError(failure):
	import sys
	sys.stderr.write(str(failure))

g = Getter()
d = g.sendLine(1)

#reactor.callLater(4, reactor.stop)
reactor.run()
