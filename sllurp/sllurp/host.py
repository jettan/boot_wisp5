#!/usr/bin/python

from twisted.internet import reactor, defer

index = 0

# Read the hex file.
f = open("wisp_app.hex", 'r')
lines = f.readlines()

class Getter:
	def processLine(self, line):
		if self.d is None:
			print "No callback given!"
			return
		
		d = self.d
		self.d = None
		
		
		global lines
		global index
		index = index + 1
		print "Processing line " + str(index)
		print line
		
		if index < len(lines):
			#d.callback(index)
		else:
			print "Finished!\n"
	
	def sendLine(self, x):
		global lines
		global index
		
		line =  lines[index]
		
		self.d = defer.Deferred()
		
		# simulate a delayed result by asking the reactor to process the next line every second.
		reactor.callLater(1, self.processLine, line)
		
		self.d.addCallback(self.sendLine)
		return self.d

def printData(d):
	print "Entered printData()"
	print d

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

d = g.sendLine(index)
#d.addCallback(printData)
#d.addErrback(printError)

#reactor.callLater(4, reactor.stop)
reactor.run()
