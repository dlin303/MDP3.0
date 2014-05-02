module MDP3_Parser_tb();
	reg clk = 1'b1;
	logic [295:0] Full_Message = 296'hC0C21C023D0100006803800100007B0000000C000000A0475F3B000000000F0002C9000000;
	logic 		done;
	logic 		message_ready;
	logic [63:0] MESSAGE;
	logic[7:0] NUM_ORDERS;
	logic[15:0] QUANTITY;
	logic[63:0] PRICE;
	logic[1:0] ACTION, ENTRY_TYPE;
	int count;
	
	MDP3_Parser parser(.*);

	always begin
		#10000 clk = !clk;
	end
	
	initial begin
		MESSAGE <= Full_Message[295 -: 64];
		#30000
		MESSAGE <= Full_Message[231 -: 64];
		#20000
		MESSAGE <= Full_Message[167 -: 64];
		#20000
		MESSAGE <= Full_Message[103 -: 64];
		#20000
		MESSAGE <= {Full_Message[39 -: 40], 24'b0};
		 
	end
endmodule
