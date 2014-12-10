#!/usr/bin/python

from twisted.internet import reactor, defer


index = 0

# Read the hex file.
f = open("wisp_app.hex", 'r')
lines = f.readlines()

class Getter:
    def processLine(self, line):
        """
        The Deferred mechanism provides a mechanism to signal error
        conditions.  In this case, odd numbers are bad.

        This function demonstrates a more complex way of starting
        the callback chain by checking for expected results and
        choosing whether to fire the callback or errback chain
        """
        print "Entered processLine()\n"
        if self.d is None:
            print "Nowhere to put results"
            return

        d = self.d
        self.d = None
        
        print line
        
        global lines
        global index
        index = index + 1
        
        if index < len(lines):
            d.callback(index)
        else:
            print "Finished!\n"

    def sendLine(self, x):
        """
        The Deferred mechanism allows for chained callbacks.
        In this example, the output of gotResults is first
        passed through _toHTML on its way to printData.

        Again this function is a dummy, simulating a delayed result
        using callLater, rather than using a real asynchronous
        setup.
        """

        print "Entered sendLine()\n"
        
        global lines
        global index
        
        line =  lines[index]
        
        self.d = defer.Deferred()
        
        # simulate a delayed result by asking the reactor to schedule
        # gotResults in 2 seconds time
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
