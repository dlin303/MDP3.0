/**********************************************************************************
*	Module : Implied Order Book
*	Description: This module generates an implied order book based upon the data stored
*	in our own order books.
*	
*	CURRENT ITERATION: Works only with two order books tracking one stock
*
*	TODO: Implied OUT generation
*	TODO: Will it overflow when negative?
*	TODO:	Create a standardized NULL_ORDER
*
*	TODO: Ask prof if we need to scale into infinity contracts/books/..etc?
*
*	Authors:		Mirza Armaan Ali,	Daron Lin, Jonathan Liu, Giovanni Ortuno
*	Contact:
*
*	Last Update:	02/05/2014	(DD/MM/YYYY)
*
*************************************************************************************/

// Parameters
parameter N_BOOKS = 5;
parameter ORD_PER_BOOK = 10;
parameter ORD_SIZE = 80;
parameter NULL_ORDER = 80'd1;
parameter MAX_CONTRACTS = 10;

module Implied_Order_Book(
	input clk,
	input update,
	input reset_n,
	//input logic[ORD_SIZE*N_BOOKS:0] books_in,
	
	input logic[87:0] U_ASK0, U_ASK1, U_ASK2, U_ASK3, U_ASK4, U_ASK5, U_ASK6, U_ASK7, U_ASK8, U_ASK9
	input logic[87:0] U_BID0, U_BID1, U_BID2, U_BID3, U_BID4, U_BID5, U_BID6, U_BID7, U_BID8, U_BID9,
	input logic[87:0] V_ASK0, V_ASK1, V_ASK2, V_ASK3, V_ASK4, V_ASK5, V_ASK6, V_ASK7, V_ASK8, V_ASK9,
	input logic[87:0] V_BID0, V_BID1, V_BID2, V_BID3, V_BID4, V_BID5, V_BID6, V_BID7, V_BID8, V_BID9,
	
	output logic[87:0] U_V_ASK0, U_V_ASK1, U_V_ASK2, U_V_ASK3, U_V_ASK4, U_V_ASK5, U_V_ASK6, U_V_ASK7, U_V_ASK8, U_V_ASK9,
	output logic[87:0] U_V_BID0, U_V_BID1, U_V_BID2, U_V_BID3, U_V_BID4, U_V_BID5, U_V_BID6, U_V_BID7, U_V_BID8, U_V_BID9,
);
// ADD CHANGE DELETE

/*************************************************************************************
* Incoming message structure:
*
* 87-:16 -> Quantity; 71-:8 -> NUM_ORDERS; 63-:64 -> PRICE;
*
**************************************************************************************/

//logic[ORD_SIZE:0] ask [N_BOOKS:0];
//logic[ORD_SIZE:0] ask [N_BOOKS:0];

typedef struct packed{
	logic[16:0] quantity;
	logic[63:0] price;
} order_struct;

// parameters
logic [87:0] UB [MAX_CONTRACTS-1:0];
logic [87:0] UA [MAX_CONTRACTS-1:0];
logic [87:0] VB [MAX_CONTRACTS-1:0];
logic [87:0] VA [MAX_CONTRACTS-1:0];
logic [87:0] UVA [MAX_CONTRACTS-1:0];
logic [87:0] UVB [MAX_CONTRACTS-1:0];

// INPUT

assign UB[0] = U_BID0;
assign UB[1] = U_BID1;
assign UB[2] = U_BID2;
assign UB[3] = U_BID3;
assign UB[4] = U_BID4;
assign UB[5] = U_BID5;
assign UB[6] = U_BID6;
assign UB[7] = U_BID7;
assign UB[8] = U_BID8;
assign UB[9] = U_BID9;

assign UA[0] = U_ASK0;
assign UA[1] = U_ASK1;
assign UA[2] = U_ASK2;
assign UA[3] = U_ASK3;
assign UA[4] = U_ASK4;
assign UA[5] = U_ASK5;
assign UA[6] = U_ASK6;
assign UA[7] = U_ASK7;
assign UA[8] = U_ASK8;
assign UA[9] = U_ASK9;

assign VA[0] = V_ASK0;
assign VA[1] = V_ASK1;
assign VA[2] = V_ASK2;
assign VA[3] = V_ASK3;
assign VA[4] = V_ASK4;
assign VA[5] = V_ASK5;
assign VA[6] = V_ASK6;
assign VA[7] = V_ASK7;
assign VA[8] = V_ASK8;
assign VA[9] = V_ASK9;

assign VB[0] = V_BID0;
assign VB[1] = V_BID1;
assign VB[2] = V_BID2;
assign VB[3] = V_BID3;
assign VB[4] = V_BID4;
assign VB[5] = V_BID5;
assign VB[6] = V_BID6;
assign VB[7] = V_BID7;
assign VB[8] = V_BID8;
assign VB[9] = V_BID9;

// OUTPUT

assign U_V_ASK0 = UVA[0];
assign U_V_ASK1 = UVA[1];
assign U_V_ASK2 = UVA[2];
assign U_V_ASK3 = UVA[3];
assign U_V_ASK4 = UVA[4];
assign U_V_ASK5 = UVA[5];
assign U_V_ASK6 = UVA[6];
assign U_V_ASK7 = UVA[7];
assign U_V_ASK8 = UVA[8];
assign U_V_ASK9 = UVA[9];

assign U_V_BID0 = UVB[0];
assign U_V_BID1 = UVB[1];
assign U_V_BID2 = UVB[2];
assign U_V_BID3 = UVB[3];
assign U_V_BID4 = UVB[4];
assign U_V_BID5 = UVB[5];
assign U_V_BID6 = UVB[6];
assign U_V_BID7 = UVB[7];
assign U_V_BID8 = UVB[8];
assign U_V_BID9 = UVB[9];

/*************************************************************************************
* Incoming message structure:
*
* 87-:16 -> Quantity; 71-:8 -> NUM_ORDERS; 63-:64 -> PRICE;
*
**************************************************************************************/

initial begin

// right now we are only checking V_ASK0, and V_BUY0
always_ff(@posedge clk) begin

	if(update)begin
		// Generate Implied bid
		for (int i=0; i<MAX_CONTRACTS-1; i++) begin
			if ((UB[i] != NULL_ORDER) && (VA[i] != NULL_ORDER) begin
				UVB[i][87-:16] = UB[i][87-:16] - VA[i][87-:16]; // quantity
				UVB[i][63-:64] = UB[i][63-:64] - VA[i][63-:64]; // price
			end
			// Generate Implied ask
			if ((UA[i] != NULL_ORDER) && (VB[i] != NULL_ORDER) begin
				UVA[i][87-:16] = UA[i][87-:16] - VB[i][87-:16];	// quantity
				UVA[i][63-:64] = UA[i][63-:64] - VB[i][63-:64]; // price
			end
			// Generate Implied out ???
		end
	end
end

endmodule 