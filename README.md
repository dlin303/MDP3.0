# Group Members

Mirza Armaan Ali,
Daron Lin,
Jonathan Liu,
Giovanni Ortuno

MDP3.0
======

This is a work in progress.

Will eventually contain SystemVerilog code to create an FPGA based MDP 3.0 ticker plant reader. 
Will also contain a software protoype of our hardware implementation. 

Will also eventually contain a real README.


FLOW
----

1. Get MDP 3.0 ethernet data packet from NASDAQ
2. Strip away IP, UDP Headers
3. Process MDP 3.0 message headers
4. Read FIX message header to determine schema
5. Read FIX message body based on appropriate schema
6. Add/Delete from order book as necessary



Tasks
=====

ORDER_BOOK - Armaan, Jon
-------------------
*Inputs* : ACTION, PRICE, QUANTITY, NUMBER of ORDERS, ENTRY TYPE
*Outputs* : TBA

- Make the ORDER_BOOK.sv file with the ORDER_BOOK module
- Create a 5 deep order ask-bid order book. (10 registers total, 5 ask, 5 bid)
- Create an order 'struct' of N bits to hold information of PRICE, QUANTITY, and NUMBER of ORDERS
- Necessary Order Book Actions: 
  + Add New Price Level
  + Delete Price level
  + Modify/Change existing Price level (changing number of order and/or quantity)

  ACTION: add new (00), change existing (01), delete (02) 
  
  QUANTITY: 16 bits

  PRICE: 64 bits Floating point number with a fixed -7 exponent 
         -- If prices are rounded to nearest '?' Can we use long signed int?

  NUM ORDERS: 8 bits

  ENTRY TYPE: 0 - bid, 1 - ask

IMPLIED_ORDER_BOOK
------------------------
Will finish after Order Book is functional


PACKETIZER/PARSER - Gio, Daron
------------------------------
*Inputs* : NETWORK PACKET, MDP PACKET
*Outputs* : ACTION, PRICE, QUANTITY, NUMBER of ORDERS

// Notify order book on recieving bytes

Check out: https://4840-r.cs.columbia.edu/projects/w4840_2013_projects_itch_decoder/repository/show?rev=verilog
to see how ITCH designed their parser and packetizer

Notes: Will probably be getting network packets 4 to 8 bytes at a time...


Questions for Next Meeting with Lariviere
-----------------------------------------
- Testing with ModelSim
- How to read information from the network via ethernet
- Sample Data
  

