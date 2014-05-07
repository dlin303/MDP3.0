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
		output logic done //when done is high, start passing data_out, write to FIFO
	);

packetizer mdp3_packetizer( .EN(valid), .*);

endmodule