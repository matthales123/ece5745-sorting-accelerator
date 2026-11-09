//=========================================================================
// Sorting Accelerator Implementation
//=========================================================================
// Sort array in memory containing positive integers.
// Accelerator register interface:
//
//  xr0 : go/done
//  xr1 : base address of array
//  xr2 : number of elements in array
//
// Accelerator protocol involves the following steps:
//  1. Write the base address of array via xr1
//  2. Write the number of elements in array via xr2
//  3. Tell accelerator to go by writing xr0
//  4. Wait for accelerator to finish by reading xr0, result will be 1
//

`ifndef LAB2_SORT_SORT_XCEL_V
`define LAB2_SORT_SORT_XCEL_V

`include "vc/trace.v"

`include "vc/mem-msgs.v"
`include "vc/xcel-msgs.v"
`include "vc/queues.v"

//=========================================================================
// Sorting Accelerator Implementation
//=========================================================================

module lab2_xcel_SortXcel
(
  	input  logic         clk,
  	input  logic         reset,

  	input  xcel_req_t    xcel_reqstream_msg,
  	input  logic         xcel_reqstream_val,
  	output logic         xcel_reqstream_rdy,

  	output xcel_resp_t   xcel_respstream_msg,
  	output logic         xcel_respstream_val,
  	input  logic         xcel_respstream_rdy,

  	output mem_req_4B_t  mem_reqstream_msg,
  	output logic         mem_reqstream_val,
  	input  logic         mem_reqstream_rdy,

  	input  mem_resp_4B_t mem_respstream_msg,
  	input  logic         mem_respstream_val,
  	output logic         mem_respstream_rdy
);

  	// 4-state sim fix: force outputs to be zero if invalid

  	xcel_resp_t  xcel_respstream_msg_raw;
  	mem_req_4B_t mem_reqstream_msg_raw;

  	assign xcel_respstream_msg = xcel_respstream_msg_raw & {33{xcel_respstream_val}};
  	assign mem_reqstream_msg   = mem_reqstream_msg_raw & {78{mem_reqstream_val}};

  	// Extra state registers
  	logic [31:0] idx,         idx_in;
  	logic [31:0] idx_temp;
  	logic [31:0] size,        size_in;
  	logic [31:0] base_src,    base_src_in;
  	logic        result,      result_in;      //result = 1: accelerator finished
  	logic        swap_flag,   swap_flag_in;   //swap_flag = 1:swap a[i] and a[i+1]
  	logic        read1_flag_in, read2_flag_in, read3_flag_in, read4_flag_in, write0_flag_in, write1_flag_in, write2_flag_in;
	logic        read1_flag, read2_flag, read3_flag, read4_flag, write0_flag, write1_flag, write2_flag;

  	logic [10:0] mem_respstream_val_reg;
	
	logic [31:0] value_1,     value_1_in;
  	logic [31:0] value_2,     value_2_in;
  	logic [31:0] counter,     counter_in;

  	always @(posedge clk) begin
    	idx         <= idx_in;
    	size        <= size_in;
    	base_src    <= base_src_in;
    	result      <= result_in;
    	swap_flag   <= swap_flag_in;
    	value_1     <= value_1_in;
    	value_2     <= value_2_in;
    	counter     <= counter_in;
		read1_flag	<= read1_flag_in;
		read2_flag	<= read2_flag_in;
		read3_flag	<= read3_flag_in;
		read4_flag	<= read4_flag_in;
		write0_flag	<= write0_flag_in;
		write1_flag	<= write1_flag_in;
		write2_flag	<= write2_flag_in;
		mem_respstream_val_reg = {mem_respstream_val_reg[9:0],mem_respstream_val};
  	end

  	//======================================================================
  	// State Update
  	//======================================================================
  	typedef enum logic [$clog2(10)-1:0] {
    	STATE_RESET,
		STATE_XCFG,
    	STATE_M_RD_START,
		STATE_M_RD_1,
    	STATE_M_RD_2,
		STATE_M_RD_3,
    	STATE_M_RD_4,
		STATE_M_WD_0,
    	STATE_M_WD_1,
    	STATE_M_WD_2
    }state_t;
    state_t state_reg;
    logic go;

  	always @(posedge clk)
	begin
    	if ( reset )
    	  	state_reg <= STATE_RESET;
    	else 
		begin
    	  	state_reg <= state_reg;
    	  	case ( state_reg )
			STATE_RESET:
				state_reg <= STATE_XCFG;
    		STATE_XCFG:
    	  	    if ( go && xcel_respstream_rdy )
    	  	      	state_reg <= STATE_M_RD_START;

    	  	 STATE_M_RD_START:
				if ( mem_reqstream_rdy )
    	  	      	state_reg <= STATE_M_RD_1;

			STATE_M_RD_1:
				if (result)
    	  	      	state_reg <= STATE_XCFG;
				else if ( mem_reqstream_rdy && read1_flag_in )
					state_reg <= STATE_M_RD_2;

    	  	STATE_M_RD_2:
    	  	    if ( mem_reqstream_rdy && read2_flag_in ) 
    	  	      	state_reg <= STATE_M_RD_3;

    	  	STATE_M_RD_3:
				if ( mem_reqstream_rdy && read3_flag_in ) 
    	  	      	state_reg <= STATE_M_RD_4;
			
			STATE_M_RD_4:
				if( read4_flag_in )
				begin
    	  	    	if ( swap_flag_in )        
    	  	    	begin
    	  	    	  	if( mem_reqstream_rdy ) 
    	  	    	    	state_reg <= STATE_M_WD_0;                
    	  	    	end
    	  	    	else if ( !swap_flag_in )   
    	  	    	  	state_reg <= STATE_M_RD_1;
				end

			STATE_M_WD_0:
    	  	    if( mem_reqstream_rdy && write0_flag_in )
    	  	      	state_reg <= STATE_M_WD_1;

    	  	STATE_M_WD_1:
    	  	    if( mem_reqstream_rdy && write1_flag_in )
    	  	      	state_reg <= STATE_M_WD_2;

    	  	STATE_M_WD_2:
    	  	    if ( write2_flag_in &&mem_reqstream_rdy )
    	  	      	state_reg <= STATE_M_RD_1;

    	  	default:
    	  	    state_reg <= STATE_RESET;
    	  	endcase
    	end
  	end

  	always @(*) begin
  	  	xcel_reqstream_rdy 	= 0;
  	  	xcel_respstream_val = 0;
  	  	go                  = 0;
  	  	base_src_in    		= base_src;
  	  	size_in        		= size;

  	  	//--------------------------------------------------------------------
  	  	// STATE: RESET
  	  	//--------------------------------------------------------------------
		if ( state_reg == STATE_RESET ) begin
				mem_reqstream_val = 0;
				mem_respstream_rdy = 0;
				mem_reqstream_msg_raw = 0;
		end

		//--------------------------------------------------------------------
  	  	// STATE: XCFG
  	  	//--------------------------------------------------------------------
  	  	else if ( state_reg == STATE_XCFG ) begin
  	  	  	xcel_reqstream_rdy = xcel_respstream_rdy;
  	  	  	xcel_respstream_val    = xcel_reqstream_val;
			
  	  	  	if ( xcel_reqstream_val ) 
				begin
  	  	  	  	// Send xcel response message, obviously you only want to
  	  	  	  	// send the response message when accelerator is done
				
  	  	  	  	if ( xcel_reqstream_msg.type_ == `VC_XCEL_REQ_MSG_TYPE_READ ) 
  	  	  	  	begin
  	  	  	  	  	xcel_respstream_msg_raw.type_ = `VC_XCEL_REQ_MSG_TYPE_READ;
  	  	  	  	  	xcel_respstream_msg_raw.data  = result;
  	  	  	  	end
  	  	  	  	else 
					begin
  	  	  	  	  	if ( xcel_reqstream_msg.addr == 0 ) 
						begin
  	  	  	  	  	  	go           = 1;
  	  	  	  	  	  	idx_in       = 0;
  	  	  	  	  	  	result_in    = 0;
  	  	  	  	  	  	swap_flag_in = 0;
  	  	  	  	  	  	counter_in   = 0;
						read1_flag_in	 = 0;
  	  	  	  	  	  	read2_flag_in	 = 0;
						read3_flag_in	 = 0;
						read4_flag_in	 = 0;
						write0_flag_in  = 0;
						write1_flag_in  = 0;
						write2_flag_in  = 0;
						  	  	  	  	  	end
  	  	  	  	  	else if ( xcel_reqstream_msg.addr == 1 )
  	  	  	  	  	  	base_src_in = xcel_reqstream_msg.data;
  	  	  	  	  	else if ( xcel_reqstream_msg.addr == 2 )
  	  	  	  	  	  	size_in = xcel_reqstream_msg.data;
  	  	  	  	  	xcel_respstream_msg_raw.type_ = `VC_XCEL_REQ_MSG_TYPE_WRITE;
  	  	  	  	  	xcel_respstream_msg_raw.data  = 0;
  	  	  	  	end
  	  	  	end
  	  	end

		else if ( state_reg == STATE_M_RD_START)
		begin
			mem_reqstream_val = 0;
		end

  	  	//--------------------------------------------------------------------
  	  	// STATE: M_RD_1
  	  	//--------------------------------------------------------------------
		
  	  	else if ( state_reg == STATE_M_RD_1 )
  	  	begin
			if( mem_respstream_val_reg[3:0] == 0 && !mem_respstream_val )
			begin
				read1_flag_in = 1;
  	  	  		mem_respstream_rdy = 1;
				write2_flag_in = 0;
  	  	  		read4_flag_in = 0;
  	  	  		mem_reqstream_val = 1;
  	  	  		mem_reqstream_msg_raw.type_ = `VC_MEM_REQ_MSG_TYPE_READ;
  	  	  		mem_reqstream_msg_raw.addr  = base_src + (idx << 2);
  	  	  		mem_reqstream_msg_raw.len   = 0;
			end
			else begin
				read1_flag_in = 0;
				mem_reqstream_val = 0;
			end
  	  	end

  	  	//--------------------------------------------------------------------
  	  	// STATE: M_RD_2
  	  	//--------------------------------------------------------------------

  	  	else if ( state_reg == STATE_M_RD_2 )
  	  	begin
  	  	  	mem_respstream_rdy = 1;
			read1_flag_in = 0;

  	  	  	if ( mem_respstream_val ) 
			begin
				value_1_in = mem_respstream_msg.data;
		  	  	mem_reqstream_val = 0;
  	  	  	  	read2_flag_in = 1;  
				read3_flag_in = 0;  
				read4_flag_in = 0;
  	  	  	end
  	  	end

 		//--------------------------------------------------------------------
  	  	// STATE: M_RD_3
  	  	//--------------------------------------------------------------------

		else if ( state_reg == STATE_M_RD_3 )
  	  	begin
  	  	  	mem_respstream_rdy = 1;
			read2_flag_in = 0;

  	  	  	if ( mem_respstream_val_reg[3:0] == 0 && !mem_respstream_val ) 
			begin
  	  	  	  	
  	  	  	  	mem_reqstream_val = 1;
  	  	  	  	read3_flag_in = 1;  
				read4_flag_in = 0;

  	  	  	  	mem_reqstream_msg_raw.type_ = `VC_MEM_REQ_MSG_TYPE_READ;
  	  	  	  	mem_reqstream_msg_raw.addr  = base_src + ((idx+1) << 2);
  	  	  	  	mem_reqstream_msg_raw.len   = 0;
  	  	  	end

			else 
			begin
				read3_flag_in = 0;
				mem_reqstream_val = 0;
			end
  	  	end

  	  	//--------------------------------------------------------------------
  	  	// STATE: RD_4
  	  	//--------------------------------------------------------------------
  	  	
  	  	else if ( state_reg == STATE_M_RD_4 )
  	  	begin
			write1_flag_in = 0;
			write2_flag_in = 0;
  	  	  	if ( mem_respstream_val && !read4_flag ) 
			begin
  	  	  	  	value_2_in = mem_respstream_msg.data;
  	  	  	  	read3_flag_in = 0; 
				read4_flag_in = 1;
				write0_flag_in = 0;
				
				mem_reqstream_val = 0;
  	  	  	  	// if value 2 < value, swap
  	  	  	  	if (value_2_in < value_1_in)
				begin    
  	  	  	  	  	swap_flag_in = 1;
  	  	  	  		// send write memory request
  	  	  	  	  	mem_reqstream_msg_raw.type_ = `VC_MEM_REQ_MSG_TYPE_WRITE;
  	  	  	  	  	mem_reqstream_msg_raw.addr  = base_src + (idx << 2);       
  	  	  	  	  	mem_reqstream_msg_raw.data  = value_2_in;
  	  	  	  	  	mem_reqstream_msg_raw.len   = 0;
  	  	  	  	end
  	  	  	  	else begin
  	  	  	  	  	swap_flag_in = 0;
  	  	  	  	end
  	  	  	  	idx_in = idx + 1;
  	  	  	  	if(idx >= size - counter -2) 
  	  	  	  	begin
  	  	  	  	  	counter_in = counter + 1;
  	  	  	  	  	if (!swap_flag_in) idx_in = 0;
  	  	  	  	  	if (counter >= size - 2) result_in  = 1;
  	  	  	  	end
  	  	  	end
  	  	end

  		//--------------------------------------------------------------------
  	  	// STATE: M_WD_0
  	  	//--------------------------------------------------------------------
		
		else if ( state_reg == STATE_M_WD_0 )
  	  	begin
			if ( !mem_respstream_val ) 
			begin
				mem_reqstream_val = 1;
				read4_flag_in = 0;
				write0_flag_in = 1;
				write1_flag_in = 0;
			end
		end

  	  	//--------------------------------------------------------------------
  	  	// STATE: M_WD_1
  	  	//--------------------------------------------------------------------

  	  	else if ( state_reg == STATE_M_WD_1 )
  	  	begin
  	  	  	read4_flag_in = 0;
  	  	  	mem_respstream_rdy = 1;
  	  	  	if ( mem_respstream_val ) 
			begin
				write1_flag_in = 1;
				write2_flag_in = 0;
  	  	  	  	mem_reqstream_val = 1;
  	  	  	  	mem_reqstream_msg_raw.type_ = `VC_MEM_REQ_MSG_TYPE_WRITE;
  	  	  	  	mem_reqstream_msg_raw.addr  = base_src + (idx << 2);
  	  	  	  	mem_reqstream_msg_raw.data  = value_1_in;
  	  	  	  	mem_reqstream_msg_raw.len   = 0;
  	  	  	end  	
  	  	end

  	  	//--------------------------------------------------------------------
  	  	// STATE: M_WD_2
  	  	//--------------------------------------------------------------------

  	  	else if ( state_reg == STATE_M_WD_2 )
  	  	begin
  	  	  	if ( mem_respstream_val ) 
			begin
				read1_flag_in = 0;
				write1_flag_in = 0;
				write2_flag_in = 1;
  	  	  	    value_1_in   = 0;
  	  	  	    value_2_in   = 0;
				mem_reqstream_val = 0;
  	  	  	    mem_reqstream_msg_raw.type_ = `VC_MEM_REQ_MSG_TYPE_READ;
  	  	  	    if(idx >= size - counter) 
  	  	  	      	idx_in = 0;
  	  	  	end
  	  	end
  	end

//----------------------------------------------------------------------
// Line Tracing
//----------------------------------------------------------------------

  	`ifndef SYNTHESIS

  	vc_XcelReqMsgTrace xcel_reqstream_msg_trace
  	(
  	  	.clk (clk),
  	  	.reset (reset),
  	  	.val   (xcel_reqstream_val),
  	  	.rdy   (xcel_reqstream_rdy),
  	  	.msg   (xcel_reqstream_msg)
  	);

  	vc_XcelRespMsgTrace xcel_respstream_msg_trace
  	(
  	  	.clk (clk),
  	  	.reset (reset),
  	  	.val   (xcel_respstream_val),
  	  	.rdy   (xcel_respstream_rdy),
  	  	.msg   (xcel_respstream_msg)
  	);

  	logic [`VC_TRACE_NBITS-1:0] str;
  	`VC_TRACE_BEGIN
  	begin
    	xcel_reqstream_msg_trace.line_trace( trace_str );

    	vc_trace.append_str( trace_str, "(" );

    	// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    	// Define line trace here
    	// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    	// Display state

    	case ( state_reg )
    	  	STATE_XCFG:              vc_trace.append_str( trace_str, "X " );
    	  	STATE_M_RD_START:        vc_trace.append_str( trace_str, "RS" );
			STATE_M_RD_1:			 vc_trace.append_str( trace_str, "R1" );
    	  	STATE_M_RD_2:            vc_trace.append_str( trace_str, "R2" );
			STATE_M_RD_3:			 vc_trace.append_str( trace_str, "R3" );
    		STATE_M_RD_4:			 vc_trace.append_str( trace_str, "R4" );
			STATE_M_WD_0:			 vc_trace.append_str( trace_str, "W0" );
    	  	STATE_M_WD_1:            vc_trace.append_str( trace_str, "W1" );
    	  	STATE_M_WD_2:            vc_trace.append_str( trace_str, "W2" );

    	  	default:                      vc_trace.append_str( trace_str, "? " );

    	endcase

    	// $sformat( str, "|%x|", swap_flag_in );
    	// vc_trace.append_str( trace_str, str );

    	// $sformat( str, "|%x|", base_src );
    	// vc_trace.append_str( trace_str, str );


    	// $sformat( str, "|%x|", mem_reqstream_msg_raw);
    	// vc_trace.append_str( trace_str, str );
	
    	// $sformat( str, "|%x|%x|", mem_reqstream_msg_raw.addr,mem_reqstream_msg_raw.data);
    	// vc_trace.append_str( trace_str, str );

    	// $sformat( str, "|%x|%x|", mem_reqstream_val,mem_respstream_rdy );
    	// vc_trace.append_str( trace_str, str );

    	// $sformat( str, "|%x|%x|%x|", mem_respstream_val,mem_reqstream_rdy,swap_flag_in );
    	// vc_trace.append_str( trace_str, str );

    	// $sformat( str, "|%x|%x|", idx_in, idx );
    	// vc_trace.append_str( trace_str, str );
    	// $sformat( str, "|%x|%x|", counter_in, counter );
    	// vc_trace.append_str( trace_str, str );

    	//request memory signals
    	$sformat( str, "|%x|%x|val_reg:%x|req_rdy:%x|  ", mem_reqstream_msg_raw.addr,mem_reqstream_msg_raw.data,mem_respstream_val_reg,mem_reqstream_rdy );
    	vc_trace.append_str( trace_str, str );

    	case ( state_reg )
    	  	STATE_XCFG:              vc_trace.append_str( trace_str, "X " );
    	  	STATE_M_RD_START:        vc_trace.append_str( trace_str, "RS" );
			STATE_M_RD_1:			 vc_trace.append_str( trace_str, "R1" );
    	  	STATE_M_RD_2:            vc_trace.append_str( trace_str, "R2" );
			STATE_M_RD_3:			 vc_trace.append_str( trace_str, "R3" );
    		STATE_M_RD_4:			 vc_trace.append_str( trace_str, "R4" );
			STATE_M_WD_0:			 vc_trace.append_str( trace_str, "W0" );
    	  	STATE_M_WD_1:            vc_trace.append_str( trace_str, "W1" );
    	  	STATE_M_WD_2:            vc_trace.append_str( trace_str, "W2" );
	   	  	default:                      vc_trace.append_str( trace_str, "? " );

    	endcase

    	//receice memory data
    	$sformat( str, "|in:%x|req_val:%x|resp_vld:%x|", mem_respstream_msg.data,mem_reqstream_val,mem_respstream_val );
    	vc_trace.append_str( trace_str, str );

    	$sformat( str, "|%x|%x|", value_1_in, value_2_in );
    	vc_trace.append_str( trace_str, str );
    	vc_trace.append_str( trace_str, ")" );

    	xcel_respstream_msg_trace.line_trace( trace_str );
  	end
  	`VC_TRACE_END

  	`endif /* SYNTHESIS */
endmodule

`endif /* LAB2_XCEL_SORT_XCEL_V */
