module fifo_tb();
	reg clk = 1'b1;
	reg[63:0] data;
	reg rdreq;
	reg wrreq;
	reg [7:0] usedw;
	reg empty;
	reg full;
	reg[63:0] q;

	scfifo64x256 ourFifo(.clock(clk),.*);
	
	always begin
		#10000 clk = !clk;
	end
	
	initial begin
		rdreq <= 1'b0;
		#10000
		data <= 64'd1;
		wrreq <= 1'b1;
		#20000
		data <= 64'd2;
		#20000
		data <= 64'd3;
		#20000
		wrreq <= 1'b0;
		#60000
		rdreq <= 1'b1;
		#20000
		rdreq <= 1'b0;
		data <= 64'd255;
		#20000
		rdreq <= 1'b1;
	end
endmodule
