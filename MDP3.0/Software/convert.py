#converts a string of fields into an MDP3.0 hex string

s = '''C0 C2 1C 02 3D 01 00 00 : Transact Time
68 03 : Event Time Delta
80 : Match Event Indicator
01 : NoMDEntries
00 : MDUpdate Action(new)
01 : MDEntryType (ask)
7B 00 00 00 : Security ID
0C 00 00 00 : RptSeq
03 00 00 00 00 00 00 00 : MDEntryPx
00 04 : MDEntrySize
03 : NumberOfOrders
C9 00 00 00 : TradeID
'''
strList = s.split('\n')
hexString = ''
for lineButt in strList:
    tupleList = lineButt.split(':')
    hexString += tupleList[0]

hexString = hexString.replace(' ', '')
print hexString






