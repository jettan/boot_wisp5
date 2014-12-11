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
		
		# simulate a delayed result by asking the reactor to process the next line every second.
		reactor.callLater(1, self.processLine, line_index)
		self.d.addCallback(self.sendLine)
		return self.d

def printError(failure):
	import sys
	sys.stderr.write(str(failure))


"""
Here starts the main program.

"""

g = Getter()

'''
for line in lines:
	# Byte count of data in line.
	print int(line[1:3],16)
	
	# Start address to write line data.
	print line[3:7]
	
	# Record type.
	print line[7:9]
	
	# Data
	print line[9:(len(line) - 3)]
'''
d = g.sendLine(1)

#reactor.callLater(4, reactor.stop)
reactor.run()
