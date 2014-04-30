`timescale 1 ns / 100 ps



module packetizer(data_in,clk, reset_n, start_packet, end_packet, EN, writeReq, reset, done, data_out, ready);
	
		parameter START = 4'b0000;

	parameter DROP_PACKET = 4'b0001;

	parameter PREAMBLE = 4'b0010;

	parameter ETH_MAC = 4'b0011;

	parameter ETH_SRC_MAC = 4'b0100;

	parameter ETH_VLAN = 4'b0101;

	parameter IP_HDR_S1 = 4'b0110;

	parameter IP_HDR_S2 = 4'b0111;

	parameter IP_HDR_OPT = 4'b1000;

	parameter UDP_HDR_S1 = 4'b1001;

	parameter PAYLOAD = 4'b1010;

	parameter DONE = 4'b1011;

	

	parameter INPUT_WIDTH = 64;

	parameter BIT_WIDTH = 48; 

	
	input wire [63:0] data_in;
	input wire clk;
	input wire reset_n;
	input wire start_packet;
	input  wire end_packet; 
	input wire EN;
	output wire ready; //packetizer read to take in data
	output reg writeReq; //not in use right now
	output reg reset; 
	output logic done; //when done is high, start passing data_out, write to FIFO
	output wire [63:0] data_out;

	
	
	//-------Ethernet Header Fields----
	reg [47:0] eth_dst;
	reg [47:0] eth_src;
	reg [15:0] eth_type;
	
	
	//-------IP Header Files---------- 
	reg [3:0] ip_ver;
	reg [3:0] ip_hlen;
	reg [7:0] ip_tos;
	reg [15:0] ip_len;
	reg [15:0] ip_id;
	reg [15:0] ip_flag_frag_off; 
	reg [7:0] ip_ttl;
	reg [7:0] ip_protocol;
	reg [15:0] ip_checksum;
	reg [31:0] ip_src_addr;
	reg [31:0] ip_dst_addr;
	reg [31:0] ip_options;
	
	
	//-------UDP Header Files---------- 
	reg [15:0] udp_src_port_opt;
	reg [15:0] udp_dst_port;
	reg [15:0] udp_len;
	reg [15:0] udp_checksum_opt;
	
	
	//--------other buses and regs----
	reg [63:0] payload_data;
	reg [63:0] previous_data0;
	reg [63:0] previous_data1;
	reg [63:0] previous_data2;
	reg [63:0] data_aligned;
	reg [15:0] payload_len;
	reg [3:0] offset = 4'b00_00;
	
	
	reg [3:0] next_state;
	wire [3:0] state; 
	reg flag;
	reg done_final;
	reg write_delay;
	reg packet_ended;
	reg [63:0] packet_count = 0;
	
	initial begin 
	offset = 4'b00_00;
	
	end
	
	assign ready = 1'b1;

	
	always @ (*)  begin 
		if (offset == 0) begin
			data_aligned = data_in;
		end
		else if (offset == 2) begin 
			data_aligned [63:48] = previous_data0 [15:0];
			data_aligned [47:0] = data_in[63:16];
		end
		else if (offset == 4) begin
			data_aligned [63:32] = previous_data0 [31:0];
			data_aligned [47:0] = data_in[63:32];
		end
		else if (offset == 6) begin 
			data_aligned [63:16] = previous_data0 [47:0];
			data_aligned [15:0] = data_in[63:48];
		end
		else if (offset == 10) begin 
			data_aligned [63:48] = previous_data0 [15:0];
			data_aligned [47:0] = data_in[63:16];
		end
		else if (offset == 14) begin 
			data_aligned [63:16] = previous_data0 [47:0];
			data_aligned [15:0] = data_in[63:48];
		end
		else begin
			data_aligned = data_in;
		end
	end
	

	assign state = next_state;	
	assign data_out = payload_data;
	
	
	always @ (posedge clk) begin
		if (!reset_n) begin
			payload_data <= 'b0;
			done <= 'b0;
		end else begin
			
		if (EN) begin
			previous_data0<=data_in;
			previous_data1<=previous_data0;
			previous_data2<=previous_data1;
		end
	
		
		
		case (state)
			START: begin
				done <= 1'b0;
				if (EN) begin
					if (start_packet)begin
						packet_count <= packet_count + 1;
						packet_ended <= 1'b0;
						next_state <= ETH_SRC_MAC;
						offset <= 4'b0000;
					end 
					else begin
						next_state <= START; 
						done <=1'b0;
					end
				end
				else begin
					next_state <= START;
				end
			end
			ETH_MAC: begin //3
				
			end
			ETH_SRC_MAC: begin //4
				if (EN) begin
					done <= 0;
						next_state <= IP_HDR_S1;
				end
			end
			ETH_VLAN: begin //5
				if (EN) begin
					next_state <= IP_HDR_S1; 
				end
			end
			IP_HDR_S1: begin		//6
				if (EN) begin
						next_state <= IP_HDR_S2;
				end
			end
			IP_HDR_S2: begin //7
				if (EN) begin
					next_state <= IP_HDR_OPT;
				end
			end
			IP_HDR_OPT: begin //8
				if (EN) begin
					udp_len <= data_in[15:0];
						next_state <= UDP_HDR_S1;
				end
			end
			UDP_HDR_S1: begin //9
				if (EN) begin
					if (udp_len == 16'h0008 )begin
						payload_len <= 16'h0000;
						next_state <= DONE;
					end
					else begin
						//payload_len <= udp_len - 16'h0008;
						payload_len <= 16'd40;
						next_state <= PAYLOAD;
						//offset <= 4'd6;
					end
				end
			end
			PAYLOAD: begin //10
				if (end_packet && EN) begin
					packet_ended <= 1'b1;
				end
				if ((!packet_ended && EN) || packet_ended) begin
					if (payload_len > 16'd8) begin
						payload_data <= data_aligned;
						payload_len <= payload_len- 16'b0000_0000_0000_1000; 
						next_state <= PAYLOAD;
						done <= 1'b1;
					end
					else begin
						case (payload_len)
							16'h0001: begin
								payload_data <= {data_aligned [63:56], 56'h00000000000000};
								payload_len <= payload_len-1;
								done <= 1'b1;
							end
							16'h0002: begin
								payload_data <= {data_aligned [63:48], 48'h000000000000};
								payload_len <= payload_len-2;
								done <= 1'b1;
							end
							16'h0003: begin
								payload_data <= {data_aligned [63:40], 40'h0000000000};
								payload_len <= payload_len-3;
								done <= 1'b1;
							end
							16'h0004: begin
								payload_data <= {data_aligned [63:32], 32'h00000000};
								payload_len <= payload_len-4;
								done <= 1'b1;
							end
							16'h0005: begin
								payload_data <= {data_aligned [63:24], 24'h000000};
								payload_len <= payload_len-5;
								done <= 1'b1;
							end
							16'h0006: begin
								payload_data <= {data_aligned [63:16], 16'h0000};
								payload_len <= payload_len-6;
								done <= 1'b1;
							end
							16'h0007: begin
								payload_data <= {data_aligned [63:8], 8'h00};
								payload_len <= payload_len-7;
								done <= 1'b1;
							end
							16'h0008: begin
								payload_data <= data_aligned [63:0];
								payload_len <= payload_len-8;
								done <= 1'b1;
							end
							default: payload_data <= 64'h00000000_00000000;
						endcase
						done_final <= 1'b1;
						next_state <= START;
						offset <= 4'b0000;
					end
				end else begin
					done <= 1'b0;
				end
			end
			default: next_state <= START;
		endcase	
	end		
	end				

always @ (posedge clk) begin
	if (!reset_n) begin
		writeReq <= 1'b0;
		write_delay <= 1'b0;
	end else begin
		write_delay <= done;
		if (state == PAYLOAD) begin
			writeReq <= 1'b1;
		end else begin
			writeReq <= write_delay;
		end
	end
end

	
endmodule 
	
