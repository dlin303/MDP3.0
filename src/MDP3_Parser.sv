module MDP3_Parser(
	input clk,
	input reset,
	input logic data_valid, //tells parser when to start reading
	input logic [63:0] MESSAGE, //assume each message is 8 bytes
	output logic[7:0] NUM_ORDERS,
	output logic[15:0] QUANTITY,
	output logic[63:0] PRICE,
	output logic[1:0] ACTION, ENTRY_TYPE,
	output logic message_ready,//let next block know message is ready
	output logic parser_ready,
	output logic enable_order_book //halts the reading of orderbook if low
	);
	
	int bus_count = 0;
	logic test = 1'b0;
	logic [63:0] PRICE_TEMP;
	logic processing = 1'b0;
	//if reset, reset all data
	initial begin
		message_ready <= 1'b0;
		bus_count = 0;
		parser_ready <= 1'b1;
	end
	
	always_ff @(posedge clk) begin
		if(data_valid && parser_ready || data_valid && processing) begin
			enable_order_book <= 1'b1;
			
			case(bus_count)
				0: begin
					bus_count += 1;
					processing <= 1'b1;
					parser_ready <= 1'b0;
					message_ready <= 1'b0;
				end
				1: begin
					ACTION <= MESSAGE[25 -: 1];
					ENTRY_TYPE <= MESSAGE[17 -: 1];
					bus_count += 1;
				end
				2: begin 
					PRICE_TEMP[63 -: 16] <= MESSAGE[15 -: 16];
					bus_count += 1; 
				end
				3: begin 
					PRICE_TEMP[47 -: 48] <= MESSAGE[63 -:48];
					QUANTITY <= changeEndian16(MESSAGE [15 -: 16]);
					bus_count += 1;
				end
				4: begin 
					NUM_ORDERS <= MESSAGE[63 -: 8];
					PRICE <= changeEndian64(PRICE_TEMP);
					message_ready <= 1'b1;
					processing <= 1'b0;
					parser_ready <= 1'b1;
					bus_count = 0;
				end
			endcase
		end else if(data_valid == 1'b0) begin //end if
			enable_order_book <= 1'b0;
		end //end else if
	end //end always_ff
	
	function [15 : 0] changeEndian16;
		input [15:0] value;
		changeEndian16 = {value[7 -: 8], value[15 -: 8]};
	endfunction	
	
	function [23:0] changeEndian24;
		input [23:0] value;
		changeEndian24 = {value[7 -: 8], value[15 -: 8], value[23 -: 8]};
	endfunction	
	
	function [31:0] changeEndian32;
		input [31:0] value;
		changeEndian32 = {value[7 -: 8], value[15 -: 8], value[23 -: 8], value[31 -: 8]};
	endfunction	
	
	function [39:0] changeEndian40;
		input [39:0] value;
		changeEndian40 = {value[7 -: 8], value[15 -: 8], value[23 -: 8], value[31 -: 8], value[39 -: 8]};
	endfunction	
	
	function [47:0] changeEndian48;
		input [47:0] value;
		changeEndian48 = {value[7 -: 8], value[15 -: 8], value[23 -: 8], value[31 -: 8], value[39 -: 8], value [47 -: 8]};
	endfunction	
	
	function [55:0] changeEndian56;
		input [55:0] value;
		changeEndian56 = {value[7 -: 8], value[15 -: 8], value[23 -: 8], value[31 -: 8], value[39 -: 8], value [47 -: 8], value[55 -: 8]};
	endfunction
	
	function [63:0] changeEndian64;
		input [63:0] value;
		changeEndian64 = {value[7 -: 8], value[15 -: 8], value[23 -: 8], value[31 -: 8], value[39 -: 8], value [47 -: 8], value[55 -: 8], value[63 -: 8]};
	endfunction	
	
endmodule
