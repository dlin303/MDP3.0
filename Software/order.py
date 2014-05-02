import datetime
from orderBook import *

class MDEntry:
	MDUpdateAction = 0
	SecurityID = 0
	RptSeq = 0
	MDEntryPx = 0

class order: 
    def __init__(self, s):
        self.transactTime = self.get(0, 64, s)
        self.eventTimeDelta = self.get(64, 16, s)
        self.matchEventIndicator = self.get(64+16,8, s)
        self.noMdEntries = self.get(64+16+8, 8, s)
        self.mdUpdateAction = self.get(64+16+8+8, 8, s)
        self.mdEntryType = str(None)


        self.MDE = self.getEntries(self.noMdEntries, s)


        self.mdEntrySize = self.get(64+16+8+8+8+32+32+64, 16, s) #quantity
        self.numberOfOrders = self.get(64+16+8+8+8+32+32+64+16, 8, s) 
        self.tradeID = self.get(64+16+8+8+8+32+32+64+16+8, 32, s)
        self.agressorSide = self.get(64+16+8+8+8+32+32+64+16+8+32, 8, s) #1 -> buyer, 2->seller

        self.price = self.MDE[0].MDEntryPx #until we understand how multiple orders work, going to just use a single price
        self.quantity = self.mdEntrySize
        
    def __str__(self):

#        print "TransactTime: " + self.transactTime
        print datetime.datetime.fromtimestamp(int(self.transactTime)/1000).strftime('%Y-%m-%d %H:%M:%S')

        print "eventTimeDelta: " + self.eventTimeDelta
        print "matchEventIndicator: " + self.matchEventIndicator
        print "noMdEntries: " + self.noMdEntries
        print "mdUpdateAction: " + self.mdUpdateAction
        print "mdEntryType: " + self.mdEntryType
        print "mdEntrySize: " + self.mdEntrySize
        print "numberOfOrders: " + self.numberOfOrders
        print "tradeID: " + self.tradeID
        print "agressorSide: " + self.agressorSide
        print ""
        for entry in self.MDE:
            print "New Entry:"
            print " " * 4 + "MDUpdateAction: " + entry.MDUpdateAction
            print " " * 4 + "SecurityID: " + entry.SecurityID
            print " " * 4 + "RptSeq: " + entry.RptSeq
            print " " * 4 + "MDEntryPx: " + entry.MDEntryPx
        return ""

    def get(self, start, size, s):
        substring = s[start/4:(start+size)/4]
        decoded = substring.decode('hex')
        #print "Original Little: " + repr(decoded)
        big = decoded[::-1]
        #print "Reversed Big: " + repr(big)
        #print "Hex: " + big.encode('hex')
        s = big.encode('hex')
        i = int("0x" + s, 16)
        #print "Decimal: " + str(i)
        return str(i)
        #print "Binary: " + "0" * (size - len(str(bin(i)[2:]))) + str(bin(i)[2:])
        #return "0" * (size - len(str(bin(i)[2:]))) + str(bin(i)[2:])
    
    def getEntries(self, count, s):
	fjump = 32+32+64+16+8+32+8+8
	fstart = 64+16+8+8
	sjump = 8+32+32+64
	sstart = 64+16+8+8+0+32+32+64+16+8+32+8 +sjump
	MDE = []
        
	for i in range(0, int(count)): #int(count,2)):
            MDtemp = MDEntry()
            if i == 0:
                MDtemp.MDUpdateAction = self.get(fstart, 8 ,s)
                MDtemp.SecurityID = self.get(fstart+8, 32, s)
                MDtemp.RptSeq = self.get(fstart+8+32,32,s)
                MDtemp.MDEntryPx = self.get(fstart+8+32+32,64,s)
            elif i==1:
                MDtemp.MDUpdateAction = self.get(fstart+fjump, 8 ,s)
                MDtemp.SecurityID = self.get(fstart+8+fjump, 32, s)
                MDtemp.RptSeq = self.get(fstart+8+32+fjump,32,s)
                MDtemp.MDEntryPx = self.get(fstart+8+32+32+fjump,64,s)
            else:
                MDtemp.MDUpdateAction = self.get(sstart, 8 ,s)
                MDtemp.SecurityID = self.get(sstart+8, 32, s)
                MDtemp.RptSeq = self.get(sstart+8+32,32,s)
                MDtemp.MDEntryPx = self.get(sstart+8+32+32,64,s)
                sstart = sstart +sjump
                
            MDE.append(MDtemp)

        return MDE

def main():
    s = "C0C21C023D01000068038002007B0000000C000000A0475F3B000000000C0002C900000080007B0000000D000000A0475F3B00000000"
    torder = order(s)
    #print torder

    fullOrderBook = FullOrderBook()

    print torder.agressorSide
    if torder.agressorSide == str(128): #need to figure out why buy is 128
        fullOrderBook.bidBook.addToBook(torder)

    print fullOrderBook


# def chunks(seq, n):
#     return [seq[i:i+n] for i in range(0, len(seq), n)]

# class fieldObject:
# 	TransactTime = 64
# 	EventTimeDelta = 16
# 	MatchEventIndicator = 8
# 	NoMDEntries = 8
	
# 	MDEntryType = 0

# 	MDE = []
	
# 	MDEntrySize = 16
# 	NumberOfOrders = 8
# 	TradeID = 32
# 	AggressorSide = 8

# def main():
# 	s = "C0C21C023D01000068038002007B0000000C000000A0475F3B000000000C0002C900000080007B0000000D000000A0475F3B00000000"
# 	tag = fieldObject()
# 	tag.TransactTime = get(0, 64, s)
# 	tag.NoMDEntries = get(64+16+8, 8, s)
#         tag.AggressorSide = get(64+16+8+8+8+32+32+64+16+8+32, 8, s)

# 	count = str(tag.NoMDEntries)

# 	fjump = 32+32+64+16+8+32+8+8
# 	fstart = 64+16+8+8

# 	sjump = 8+32+32+64
# 	sstart = 64+16+8+8+0+32+32+64+16+8+32+8 +sjump
	

# 	for i in range(0,int(count,2)):
# 		MDtemp = MDEntry()
# 		if i == 0:
# 			MDtemp.MDUpdateAction = get(fstart, 8 ,s)
# 			#print int(MDtemp.MDUpdateAction,2)
# 			MDtemp.SecurityID = get(fstart+8, 32, s)
# 			# print int(MDtemp.SecurityID,2)
# 			MDtemp.RptSeq = get(fstart+8+32,32,s)
# 			MDtemp.MDEntryPx = get(fstart+8+32+32,64,s)
# 			# print int(MDtemp.MDEntryPx,2)
# 		elif i==1:
# 			MDtemp.MDUpdateAction = get(fstart+fjump, 8 ,s)
# 			MDtemp.SecurityID = get(fstart+8+fjump, 32, s)
# 			MDtemp.RptSeq = get(fstart+8+32+fjump,32,s)
# 			MDtemp.MDEntryPx = get(fstart+8+32+32+fjump,64,s)
# 		else:
# 			MDtemp.MDUpdateAction = get(sstart, 8 ,s)
# 			MDtemp.SecurityID = get(sstart+8, 32, s)
# 			MDtemp.RptSeq = get(sstart+8+32,32,s)
# 			MDtemp.MDEntryPx = get(sstart+8+32+32,64,s)
# 			sstart = sstart +sjump

# 		tag.MDE.append(MDtemp)
# 	# print "---------------"
	
# 	for i in range(0,int(count,2)):
# 		print "Object " + str(i)
# 		print "		MDUpdateAction: " + str(int(tag.MDE[i].MDUpdateAction,2))
# 		print "		SecurityID: " + str(int(tag.MDE[i].SecurityID,2))
# 		print "		RptSeq: " + str(int(tag.MDE[i].RptSeq,2))
# 		print "		MDEntryPx: " + str(int(tag.MDE[i].MDEntryPx,2))



main()
