module Order_Book_tb();
	reg clk = 1'b1;
	//logic data_valid;
	logic [63:0] zero = 64'b0;
	//	logic [408:0] Ethernet_Message = 408'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000C0C21C023D0100006803800100017B0000000C0000000300000000000000000403C9000000;
	logic [295:0] Full_Message = 296'hC0C21C023D0100006803800100007B0000000C0000000900000000000000AE0001C9000000;
	logic [295:0] Full_Message2 = 296'hC0C21C023D0100006803800101007B0000000C0000000500000000000000050002C9000000;
	logic [295:0] Full_Message3 = 296'hC0C21C023D0100006803800100017B0000000C0000000300000000000000000403C9000000;
	logic [63:0] MESSAGE;
	logic[87:0] ASK0, ASK1, ASK2, ASK3, ASK4, ASK5, ASK6, ASK7, ASK8, ASK9;
	logic[87:0] BID0, BID1, BID2, BID3, BID4, BID5, BID6, BID7, BID8, BID9;
	logic orderbook_ready; 
	logic[7:0] NUM_ORDERS;
	logic[15:0] QUANTITY;
	logic[63:0] PRICE;
	logic[1:0] ACTION, ENTRY_TYPE;
	logic [31:0] SECURITY_ID;
	logic message_ready; //let next block know message is ready
	logic reset;
	logic ready;
	logic parser_ready;
	logic enable_order_book;
	logic[63:0] data_in;
	logic reset_n;
	logic start_packet;
	logic end_packet; 
	logic EN;
	logic writeReq;
	logic done;
	logic[63:0] data_out;
	logic not_empty; //check if FIFO is empty or not
	logic	  empty;
	assign not_empty = !empty;
	logic [63:0] TEMP;
	
	//FIFO stuff
	logic rdreq;
	logic	  full;
	//logic	[63:0]  q;
	logic	[7:0]  usedw;
	
	
	//assign data_valid = done;
	Order_Book #(123,10) book(.*);
	//Order_Book #(122, 10)book2(.*);
	//Order_Book #(121, 10)book3(.*);
	
	packetizer pack(.*);
	scfifo64x256 fifo(.data(data_out), .wrreq(done), .clock(clk), .q(MESSAGE), .*);
	MDP3_Parser parser(.parser_ready(rdreq), .not_empty(!empty), .*);
	
	always begin
		#10000 clk = !clk;
	end
	
	initial begin
		reset_n <= 1'b1;
		EN <= 1'b1;
		data_in <= zero;
		start_packet <= 1'b1;
		#120000
		start_packet <= 1'b0;
		data_in <= Full_Message[295 -: 64];
		#20000
		data_in <= Full_Message[231 -: 64];
		#20000
		data_in <= Full_Message[167 -: 64];
		#20000
		data_in <= Full_Message[103 -: 64];
		#20000
		data_in <= {Full_Message[39 -: 40], 24'b0};
		end_packet <= 1'b1;
		#20000
		end_packet <= 1'b0;
		data_in <= zero;
		start_packet <= 1'b1;
		#120000
		start_packet <= 1'b0;
		data_in <= Full_Message2[295 -: 64];
		#20000
		data_in <= Full_Message2[231 -: 64];
		#20000
		data_in <= Full_Message2[167 -: 64];
		#20000
		data_in <= Full_Message2[103 -: 64];
		#20000
		data_in <= {Full_Message2[39 -: 40], 24'b0};
		end_packet <= 1'b1;
		
	end
endmodule
