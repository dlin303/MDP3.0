/**********************************************************************************
*	Module : Order Book Reader
*	Description: Avalon memory-mapped peripheral for the Order Book Reader
*
*	Authors:		Mirza Armaan Ali,	Daron Lin, Jonathan Liu, Giovanni Ortuno
*	Contact:
*
*	Last Update:	11/05/2014
*
*************************************************************************************/

// can only be powers of 2
parameter ORDER_SIZE 128

module Order_Book_Reader (
	input logic clk, reset, chipselect
	input logic[6:0] address,
	input logic read,
	
	output logic[ORDER_SIZE-1:0] readdata,
);

// connect to a separate memory reading component that will feed back what I need

always_ff @posedge(clk)
	if (reset) begin
	// reset stuff here
	readdata <= 128d'0;
	end else if (read && chipselect)
		case(address)
		// memory reading stuff goes here
		
		endcase
	

endmodule
		