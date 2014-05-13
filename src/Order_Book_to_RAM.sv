/**********************************************************************************
*	Module : 
*	Description:
*
*	Authors:		Mirza Armaan Ali,	Daron Lin, Jonathan Liu, Giovanni Ortuno
*	Contact:
*
*	Last Update:	12/05/14
*
*	TODO: Fix the obnum issue since it's currently hard-coded
*
*	The current implementation direct maps the 10 bids and 10 asks into memory. It does
* not dynamically manage the available space. For example, the highest bid will always
* map to location 0 even if there are no bids (it will be garbage in that case).
*
*	It current always goes through the asks and then the bids.
*
*************************************************************************************/

// Note that there are 20 padded 0 bits in front due to size constraints
// I'm hard-coding in the order book number for now
// This module will handle one order book.

// define parameters
parameter ORDER_N_BIT = 89;
parameter OUT_BITS = 128;

module Order_Book_to_RAM(
	input clk,
	input logic en,
	input logic[88:0] ASK0, ASK1, ASK2, ASK3, ASK4, ASK5, ASK6, ASK7, ASK8, ASK9, 
	input logic[88:0] BID0, BID1, BID2, BID3, BID4, BID5, BID6, BID7, BID8, BID9, 
	
	output logic wren,
	output logic[127:0] dataout,
	output logic[1023:0] address
);

// declare variables
enum {IDLE, ADDING_ASK, ADDING_BID} state;
logic[3:0] pos;
logic full_ask;
logic full_buy;

initial begin
	state <= IDLE;
	pos = 4'd0;
end

always_ff @(posedge(clk)) begin
	case(state)
		IDLE: begin
			if (en==1) begin
				wren <= 0;
				pos <= 4'd0;
				state <= ADDING_ASK;
			end else begin
				state <= IDLE;
			end
		end
		
		ADDING_ASK: begin
			wren <= 0;
			full_ask <= {{ASK0[88:0]},{ASK1[88:0]},{ASK2[88:0]},{ASK3[88:0]},{ASK4[88:0]},{ASK5[88:0]},{ASK6[88:0]},{ASK7[88:0]},{ASK8[88:0]},{ASK9[88:0]}};
			
			if (full_ask[pos*ORDER_N_BIT-1] == 1) begin
				if (pos < 10) begin
					dataout <= {{1},39'd0,{full_ask[pos*ORDER_N_BIT-:ORDER_N_BIT]}};
					wren <=1;
					address = 0 + pos; // this is probably wrong
					pos += 1;
					state <= ADDING_ASK;
				end else begin
					pos <= 4'd0;
					state <= ADDING_BID;
				end
			end
		end
		
		ADDING_BID: begin
			wren <= 0;
			full_bid <= {{BID0[88:0]},{BID1[88:0]},{BID2[88:0]},{BID3[88:0]},{BID4[88:0]},{BID5[88:0]},{BID6[88:0]},{BID7[88:0]},{BID8[88:0]},{BID9[88:0]}};
			
			if (full_bid[pos*ORDER_N_BIT-1] == 1) begin
				if (pos < 10) begin
					dataout <= {{1},39'd0,{full_bid[pos*ORDER_N_BIT-:ORDER_N_BIT]}};
					pos += 1;
					wren <= 1;
					address = 10 + pos; // this is probably wrong
					state <= ADDING_BID;
				end else begin
					pos = 4'd0;
					state <= IDLE;
				end
			end
		end
	endcase
end
endmodule
