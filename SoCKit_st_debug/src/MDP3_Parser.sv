module MDP3_Parser(
	input clk,
	input reset,
	input logic not_empty, //tells parser when to start reading
	input logic [63:0] MESSAGE, //assume each message is 8 bytes
	output logic[31:0] NUM_ORDERS,
	output logic[31:0] QUANTITY,
	output logic[63:0] PRICE,
	output logic[7:0] ACTION, ENTRY_TYPE,
	output logic [31:0] SECURITY_ID,
	output logic message_ready,//let next block know message is ready
	output logic parser_ready,
	output logic enable_order_book //halts the reading of orderbook if low
	);
	
	int bus_count = 0;
	logic data_valid;
	int entries_seen = 0;
	logic test = 1'b0;
	logic [63:0] PRICE_TEMP, SendingTime, SendingTimeTemp, RawTransactTime, temp;
	logic [31:0] SECURITY_ID_TEMP, MsgSeqNum, RptSeq, EntrySize, NumOrdersTemp;
	logic processing = 1'b0;
	logic [15:0] MsgSize, BlockLength, Version, BlockLengthEntry;
	logic [7:0] TemplateID, SchemaID, MatchEventIndicator, NumMdEntries, priceLevel;
	logic [215:0] buffer; 
	int offset = 0;
	//if reset, reset all data
	initial begin
		message_ready <= 1'b0;
		bus_count = 0;
		parser_ready <= 1'b1;
	end
	
	always_ff @(posedge clk) begin
	
		if(not_empty && parser_ready)begin
			data_valid <= 1'b1;
		end else begin
			data_valid <= 1'b0;
		end
	
		if(data_valid && parser_ready || data_valid && processing) begin
			enable_order_book <= 1'b1;
			
			case(bus_count)
				0: begin
					bus_count += 1;
					processing <= 1'b1;
					parser_ready <= 1'b1; //right now parser is ready for next input each clock cycle
					message_ready <= 1'b0;
					MsgSeqNum <= changeEndian32(MESSAGE[63-:32]);
					SendingTimeTemp[63-:32] <= MESSAGE[31-:32];
				end
				1: begin
					SendingTimeTemp[31-:32] <= MESSAGE[63-:32];
					MsgSize <= changeEndian16(MESSAGE[31-:16]);
					BlockLength <= changeEndian16(MESSAGE[15-:16]);
					bus_count += 1;
				end
				2: begin 
					SendingTime <= changeEndian64(SendingTimeTemp);
					TemplateID <= MESSAGE[63-:8];
					SchemaID <= MESSAGE[55-:8];
					Version <= changeEndian16(MESSAGE[47-:16]);
					RawTransactTime[63-:32] <= MESSAGE[31-:32];
					bus_count += 1; 
				end
				3: begin
					RawTransactTime[31-:32] <= MESSAGE[63-:32];
					MatchEventIndicator <= MESSAGE[31-:8];
					BlockLengthEntry <= changeEndian16(MESSAGE[23-:16]);
					NumMdEntries <= MESSAGE[7-:8];
					if(MESSAGE[7-:8] > 0)
						bus_count += 1;
					else begin
						message_ready <= 1'b0;
						processing <= 1'b0;
						parser_ready <= 1'b1;
						bus_count = 0;
					end
				end
				4: begin // Start processing entriesa
					RawTransactTime <= changeEndian64(RawTransactTime);
					buffer[(215-offset)-:64] <= MESSAGE;
					bus_count = 5;
				end
				5: begin
					message_ready <= 1'b0;
					buffer[(151-offset)-:64] <= MESSAGE;
					if(87 - offset < 64)
						bus_count = 7;
					else
						bus_count = 6;
				end
				6: begin
					buffer[(87-offset)-:64] <= MESSAGE;
					bus_count = 8;
				end
				7: begin
					case(offset)
						24: begin
							buffer[63-:64] <= MESSAGE;
						end
						32: begin
							buffer[55-:56] <= MESSAGE[63-:56];
							temp[63-:8] <= MESSAGE[7-:8];
						end
						40: begin
							buffer[47-:48] <= MESSAGE[63-:48];
							temp[63-:16] <= MESSAGE[15-:16];
						end
						48: begin
							buffer[39-:40] <= MESSAGE[63-:40];
							temp[63-:24] <= MESSAGE[23-:24];
						end
						56: begin
							buffer[31-:32] <= MESSAGE[63-:32];
							temp[63-:32] <= MESSAGE[31-:32];
						end
					endcase
					offset <= (offset+40)%64;
					bus_count = 9;
				end
				8: begin
					case(offset)
						0: begin
							buffer[23-:24] <= MESSAGE[63-:24];
							temp[63-:40] <= MESSAGE[39-:40];
						end
						8: begin
							buffer[15-:16] <= MESSAGE[63-:16];
							temp[63-:48] <= MESSAGE[47-:48];
						end
						16: begin
							buffer[7-:8] <= MESSAGE[63-:8];
							temp[63-:56] <= MESSAGE[55-:56];
						end
					endcase
					offset <= (offset+40)%64;
					bus_count = 9;
				end
				9: begin
					// OUTPUT ALL values
					ACTION <= buffer[215 -: 8];
					ENTRY_TYPE <= buffer[207 -: 8];
					SECURITY_ID <= changeEndian32(buffer[199-:32]);
					RptSeq <= changeEndian32(buffer[167-:32]);
					priceLevel <= buffer[135-:8];
					PRICE <= changeEndian64(buffer[127 -: 64]);
					QUANTITY <= changeEndian32(buffer[63-:32]);
					NUM_ORDERS <= changeEndian32(buffer[31-:32]);
					message_ready <= 1'b1;
					
					if(NumMdEntries - 1> 0) begin
						NumMdEntries <= NumMdEntries - 1;
						entries_seen <= entries_seen + 1;
						case(offset)
							8:
								buffer[215-:8] <= temp[63-:8];
							16:
								buffer[215-:16] <= temp[63-:16];
							24:
								buffer[215-:24] <= temp[63-:24];
							32:
								buffer[215-:32] <= temp[63-:32];
							40:
								buffer[215-:40] <= temp[63-:40];
							48:
								buffer[215-:48] <= temp[63-:48];
							56:
								buffer[215-:56] <= temp[63-:56];
						endcase
						buffer[(215-offset)-:64] <= MESSAGE;
						bus_count = 5;
					end
					else begin
						processing <= 1'b0;
						parser_ready <= 1'b1;
						bus_count = 0;
					end
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
