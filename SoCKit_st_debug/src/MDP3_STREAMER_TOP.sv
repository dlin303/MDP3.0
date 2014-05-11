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
		output logic[7:0] NUM_ORDERS,
		output logic[15:0] QUANTITY,
		output logic[63:0] PRICE,
		output logic[1:0] ACTION, ENTRY_TYPE,
		output logic [31:0] SECURITY_ID,
		output logic message_ready,//let next block know message is ready
		//output logic parser_ready,
		output logic enable_order_book //halts the reading of orderbook if low

	//FIFO output
	);

logic [63:0] message_packetizer_to_fifo;
logic fifo_wrreq; //write request from packetizer to fifo
logic fifo_not_empty;
assign fifo_not_empty = !fifo_empty;
logic fifo_empty; //high if fifo is empty
logic read_fifo;
	
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
			
MDP3_Parser parser (.MESSAGE(data_out), .data_valid(fifo_not_empty), .reset(reset_n), .parser_ready(read_fifo), .*);


endmodule