// avalon_stream_simulater.v

// This file was auto-generated as a prototype implementation of a module
// created in component editor.  It ties off all outputs to ground and
// ignores all inputs.  It needs to be edited to make it do something
// useful.
// 
// This file will not be automatically regenerated.  You should check it in
// to your version control system if you want to keep it.

`timescale 1 ps / 1 ps
module avalon_stream_simulater #(
		parameter error_width       = 1,
		parameter stdata_width      = 64,
		parameter mmdata_width      = 8,
		parameter addr_width        = 3,
		parameter empty_width       = 3
	) (
		input  wire        clk,              //        clk.clk
		input  wire        reset,            //      reset.reset

		
		//Avalon ST interface (sink) --------- connected to jtag
		output wire        in_ready,         //  stream_in.ready
		input  wire        in_valid,         //           .valid
		input  wire [stdata_width-1:0] in_data,          //           .data
		input  wire        in_startofpacket, //           .startofpacket
		input  wire        in_endofpacket,   //           .endofpacket
		input  wire [empty_width-1:0]  in_empty,         //           .empty
				
		//Avalon ST interface (source) --------- connected to jtag
		input wire        out_ready,         //  stream_out.ready
		output  wire        out_valid,         //           .valid
		output  wire [stdata_width-1:0] out_data,          //           .data
		output  wire        out_startofpacket, //           .startofpacket
		output  wire        out_endofpacket,   //           .endofpacket
		output  wire [empty_width-1:0]  out_empty,         //           .empty
		
		//Avalon ST interface (sink) --------- connected to application
		output wire        sink_ready,         //  stream_in.ready
		input  wire        sink_valid,         //           .valid
		input  wire [stdata_width-1:0] sink_data,          //           .data
		input  wire        sink_startofpacket, //           .startofpacket
		input  wire        sink_endofpacket,   //           .endofpacket
		input  wire [empty_width-1:0]  sink_empty,         //           .empty
				
		//Avalon ST interface (source) --------- connected to application
		input wire          src_ready,         //  stream_out.ready
		output  wire        src_valid,         //           .valid
		output  wire [stdata_width-1:0] src_data,          //           .data
		output  wire        src_startofpacket, //           .startofpacket
		output  wire        src_endofpacket,   //           .endofpacket
		output  wire [empty_width-1:0]  src_empty,         //           .empty
		
		
		//Avalon MM interface (slave) --------- used for module controlling
		
		input  wire        write,            // control_mm.write
		input  wire [mmdata_width-1:0]  writedata,        //           .writedata
		input  wire        read,            // .read
		output  wire [mmdata_width-1:0]  readdata,        //           .readdata
		input  wire [addr_width-1:0]  address,          //           .address
		input  wire        cs                //           .chipselect
	);

		//=======================================================
		//  REG/WIRE declarations
		//=======================================================

			reg             ready_reg;
			reg [mmdata_width-1:0] control_reg1,control_reg2,control_reg3,control_reg4,control_reg5,control_reg6,control_reg7;
			reg [8:0]           cnt;
			reg [31:0]           pkincnt;
			reg [31:0]           pkoutcnt;
			reg                  in_frame;
			
			
		//=======================================================
		//  Structural coding
		//=======================================================

			assign     src_data = in_data;
			assign     src_valid = in_valid && (in_startofpacket || in_frame);
			assign     src_startofpacket= in_startofpacket; 
			assign     src_endofpacket= in_endofpacket;   
			assign     src_empty = in_empty;
			
			assign     in_ready = ready_reg && src_ready;
			assign     sink_ready = sink_ready;
			
			assign     out_data = sink_data;
			assign     out_valid = sink_valid;
			assign     out_startofpacket= sink_startofpacket; 
			assign     out_endofpacket= sink_endofpacket;   
			assign     out_empty = sink_empty;
			
			
			always_ff@(posedge clk) begin 
				if (reset) begin
					ready_reg <= 0;
					control_reg1 <= 0;
					control_reg2 <= 0;
					control_reg3 <= 0;
					control_reg4 <= 0;
					control_reg5 <= 0;
					control_reg6 <= 0;
					control_reg7 <= 0;
					cnt <= 0;
					in_frame <= 0;
				end else begin
					if (cs) begin
						if (write) begin
							case (address) 
								3'h0 : ready_reg <= writedata[0];
								3'h1 : control_reg1 <= writedata;
								3'h2 : control_reg2 <= writedata;
								3'h3 : control_reg3 <= writedata;
								3'h4 : control_reg4 <= writedata;
								3'h5 : control_reg5 <= writedata;
								3'h6 : control_reg6 <= writedata;
								3'h7 : control_reg7 <= writedata;
								default;//do nothing;
							endcase
						end 
						else if (read) begin 
							case (address)

								3'h0 : readdata <= pkincnt[7:0];
								3'h1 : readdata <= pkincnt[15:8];
								3'h2 : readdata <= pkincnt[23:16];
								3'h3 : readdata <= pkincnt[31:24];
								3'h4 : readdata <= pkoutcnt[7:0];
								3'h5 : readdata <= pkoutcnt[15:8];
								3'h6 : readdata <= pkoutcnt[23:16];
								3'h7 : readdata <= pkoutcnt[31:24];
								default;//do nothing;
							endcase;
						end
					end
					if (in_ready) begin
						if (in_valid) begin 
							if (sink_startofpacket) begin 
							    pkincnt <= pkoutcnt + 1;
							end
						end
					end
					if (src_ready) begin
						if (src_valid) begin 
							if (in_startofpacket) begin 
							    pkoutcnt <= pkincnt + 1;
								 in_frame <= 1;
							end else if (in_endofpacket) begin 
								 in_frame <= 0;
							end
						end
					end
				end
			end
	

endmodule
