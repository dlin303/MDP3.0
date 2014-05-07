variable infile 0
variable s_path ""
set s_path [lindex [get_service_paths master] 0]
open_service master $s_path
#set infile [open packet_data.txt "r"]
set infile [open mdp3_tcl.txt "r"]
set outfile [open packet_data_out.txt "w"]

set stream_base 0x0
set ready_base 0x8
set mmst_base 0x10

# Set register "ready_reg" in Avalon ST simulator to 0, buffer data in the fifo "sc_fifo_in"
master_write_8 $s_path $ready_base 0x0

# Send packet data in packet_data.txt
set line 64
set wait 1000		
set precursor "0x"

set packet_byte [gets $infile]
if {$packet_byte eq "sop"} {
# Send special characters: 7a00_0000_0000_0000 indicate "startofpacket"
master_write_32 $s_path $stream_base 0x44332211
puts "sop"
set j 0
set inframe 1
set payload_line "7a7a7a55"
while {[expr $j < 1000] && $inframe} {
   incr j
	for {set i 0} {$i < 4} {incr i} {
		set packet_byte [gets $infile]
		if {$packet_byte eq "7a"} {
			 set packet_byte "5a7d"
			 set payload_line $packet_byte$payload_line
			 incr i
		} elseif {$packet_byte eq "7b" || $packet_byte eq "7B"} {
			 set packet_byte "5b7d"
			 set payload_line $packet_byte$payload_line
			 incr i
		} elseif {$packet_byte eq "7c"} {
			 set packet_byte "5c7d"
			 set payload_line $packet_byte$payload_line
			 incr i
		} elseif {$packet_byte eq "7d"} {
			 set packet_byte "5d7d"
			 set payload_line $packet_byte$payload_line
			 incr i
		} elseif {$packet_byte == "eop"} {
			 set packet_byte "7b"
			 set inframe 0
			 set payload_line "[string range $payload_line 0 1]$packet_byte[string range $payload_line 2 end]"
			 puts "eop"
		} else {
		    set payload_line $packet_byte$payload_line
		}
	
	}
	puts "payload_line: $payload_line"
	set data_to_stream $precursor[string range $payload_line end-7 end]
	set payload_line [string range $payload_line 0 end-8]
	puts "data_to_stream: $data_to_stream"
	master_write_32 $s_path $stream_base $data_to_stream
}
	set data_to_stream $precursor[string range "000000$payload_line" end-7 end]
	set payload_line [string range $payload_line 0 end-8]
	puts "data_to_stream: $data_to_stream"
	master_write_32 $s_path $stream_base $data_to_stream
}

master_write_8 $s_path $ready_base 0x1
for {set i 0} {$i < [expr $wait]} {incr i} {
   #puts "[master_read_32 $s_path $mmst_base 1]"
}
master_write_8 $s_path $ready_base 0x0


