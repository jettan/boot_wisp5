from __future__ import print_function
import argparse
import logging
import pprint
import time
from twisted.internet import reactor, defer

import sllurp.llrp as llrp

tagReport = 0
logger    = logging.getLogger('sllurp')

# Initialize RFID reader.
host          = '192.168.1.52'
port          = 5084
dur           = 60 #seconds
read_words    = None
write_words   = 1
write_content = int('0x00',16)


def finish (_):
	print("FINISH CALLED")
	logger.info('total # of tags seen: {}'.format(tagReport))
	reactor.stop()


def access (proto):
	return proto.startAccess(readWords=read_words, writeWords=write_words, writeContent=write_content)


def politeShutdown (factory):
	return factory.politeShutdown()


def tagReportCallback (llrpMsg):
	"""Function to run each time the reader reports seeing tags."""
	global tagReport
	tags = llrpMsg.msgdict['RO_ACCESS_REPORT']['TagReportData']
	
	if len(tags):
		logger.info('saw tag(s): {}'.format(pprint.pformat(tags)))
	else:
		logger.info('no tags seen')
		return
	for tag in tags:
		tagReport += tag['TagSeenCount'][0]
	

def init_logging ():
	logLevel = (logging.INFO)
	logFormat = '%(asctime)s %(name)s: %(levelname)s: %(message)s'
	formatter = logging.Formatter(logFormat)
	stderr = logging.StreamHandler()
	stderr.setFormatter(formatter)
	
	root = logging.getLogger()
	root.setLevel(logLevel)
	root.handlers = [stderr,]
	
	logger.log(logLevel, 'log level: {}'.format(logging.getLevelName(logLevel)))


### --- START MAIN ----
def main ():
	print("--- Host app started. ---\n")
	
	# Read ihex file to flash.
	print("Reading HEX file...\n")
	f = open("wisp_app.hex", 'r')
	
	# Process the image file.
	lines = f.readlines()
	
	num_packets = 0
	
	# Calculate number of packets to be sent.
	for x in range (0, len(lines)):
		num_packets = num_packets + (len(lines[x])/2)
	
	
	print(num_packets)
	
	# Send signal to WISP to go into bootloader mode.
	# TODO: send_packet(SOME_BOOTLOADER_MODE_FLAG)
	
	# Send the length of the image.
	# TODO: send_packet(SOME_INFO_ABOUT_NUM_PACKETS)
	
	# Wait for ACK.
	# TODO: wait for ACK somehow...
	
	#for x in range (0, len(lines)):
	#	for y in range (1, len(lines[x])-1, 2):
	#		print(lines[x][y] + "" + lines[x][y+1])
	
	init_logging()
	
	# will be called when all connections have terminated normally
	onFinish = defer.Deferred()
	onFinish.addCallback(finish)
	
	fac = llrp.LLRPClientFactory(
	        onFinish             = onFinish,
	        duration             = dur,
	        disconnect_when_done = True,
	        modulation           = 'WISP5',
	        tari                 = 7140,
	        start_inventory      = True,
	        tx_power             = 0,
	        report_every_n_tags  = 1,
	        tag_content_selector = {
	            'EnableROSpecID': False,
	            'EnableSpecIndex': False,
	            'EnableInventoryParameterSpecID': False,
	            'EnableAntennaID': True,
	            'EnableChannelIndex': False,
	            'EnablePeakRRSI': True,
	            'EnableFirstSeenTimestamp': False,
	            'EnableLastSeenTimestamp': True,
	            'EnableTagSeenCount': True,
	            'EnableAccessSpecID': True
	        })
	
	# tagReportCallback will be called every time the reader sends a TagReport
	# message (i.e., when it has "seen" tags).
	fac.addTagReportCallback(tagReportCallback)
	
	# start tag access once inventorying
	fac.addStateCallback(llrp.LLRPClient.STATE_INVENTORYING, access)
	
	global host
	global port
	reactor.connectTCP(host, port, fac, timeout=3)
	
	# catch ctrl-C and stop inventory before disconnecting
	reactor.addSystemEventTrigger('before', 'shutdown', politeShutdown, fac)
	
	reactor.run()

## --- END MAIN ---


if __name__ == '__main__':
	main()
