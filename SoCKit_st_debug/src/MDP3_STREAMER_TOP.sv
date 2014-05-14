module MDP3_STREAMER_TOP (
		input wire start_packet, 
		input wire end_packet, 
		input wire valid,
		input wire [63:0] data_in,		
		input wire [2:0]empty,
		input wire clk,
		input wire reset_n,
		output wire ready,
		output wire [63:0] data_out,
		output reg writeReq, //not in use right now
		output reg reset, 
		output wire [63:0] q,
		//output logic done, //when done is high, start passing data_out, write to FIFO
		
		//Parser Output
		output logic[31:0] NUM_ORDERS,
		output logic[31:0] QUANTITY,
		output logic[63:0] PRICE,
		output logic[7:0] ACTION, ENTRY_TYPE,
		output logic [31:0] SECURITY_ID,
		output logic message_ready,//let next block know message is ready
		//output logic parser_ready,
		output logic enable_order_book, //halts the reading of orderbook if low

		//FIFO output
		output logic [63:0] message_packetizer_to_fifo,
		output logic fifo_wrreq, //write request from packetizer to fifo
		output logic fifo_empty, //high if fifo is empty
		output logic read_fifo
	);

logic[127:0] ASK0, ASK1, ASK2, ASK3, ASK4, ASK5, ASK6, ASK7, ASK8, ASK9; 
logic[127:0] BID0, BID1, BID2, BID3, BID4, BID5, BID6, BID7, BID8, BID9; 
logic orderbook_ready; //let next block know message is ready might need more?

packetizer mdp3_packetizer( 
			.EN(valid), 
			.data_out(message_packetizer_to_fifo), 
			.done(fifo_wrreq),
			.*
			);
			
scfifo64x256 fifo(
			.data(message_packetizer_to_fifo), 
			.wrreq(fifo_wrreq), 
			.clock(clk),
			.q(q),
			.rdreq(read_fifo),
			.empty(fifo_empty),
			.full(),
			.usedw(),
			.*
			);
			
MDP3_Parser parser (.MESSAGE(q), .not_empty(!fifo_empty), .reset(reset_n), .parser_ready(read_fifo), .*);

Order_Book #(123,10) book(.*);

endmodule
