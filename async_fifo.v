`timescale 1ns /1ns

module async_fifo#(parameter data_size=8, parameter array_size=4)
(
input w_req, w_clk, w_rst,
input r_req, r_clk, r_rst,
input [data_size-1:0]w_data,
output [data_size-1:0]r_data,
output reg full,empty
);

reg [array_size:0] wq2_rptr, wq1_rptr, rptr;
reg [array_size:0] rq2_wptr, rq1_wptr, wptr;
wire empty_wire;
wire full_wire;
wire [array_size-1:0] rptr_nxt;
reg [array_size:0] rbin;
wire [array_size:0] rbin_nxt;
reg [array_size:0] wbin;
wire [array_size:0] wbin_nxt;
wire [array_size-1:0] wptr_nxt;
wire [array_size-1:0] r_addr;
wire [array_size-1:0] w_addr;


///generate empty condition
assign empty_wire= (rptr_nxt == rq2_wptr);


///generate full condition
assign full_wire= (wq2_rptr == {~wptr[array_size:array_size-1], wptr[array_size-2:0]});


///synchronizing rptr to w_clk
always@(posedge w_clk or negedge w_rst)
begin
    if(!w_rst)
    begin
        {wq2_rptr, wq1_rptr}= 2'b0;
        full<=0;
    end
    
    else
    begin
        {wq2_rptr, wq1_rptr}= {wq1_rptr,rptr};
        full<=full_wire;
    end
end


///synchronizing wptr to r_clk
always@(posedge r_clk or negedge r_rst)
begin
    if(!r_rst)
    begin 
        {rq2_wptr, rq1_wptr}=2'b0;
        empty <= 0;
    end
    
    else
    begin
        {rq2_wptr, rq1_wptr}= {rq1_wptr,wptr};
        empty <= empty_wire;
    end
        
end


///generating read address for fifomem
assign rbin_nxt= rbin + (r_req & ~empty); 
always@(posedge r_clk or negedge r_rst)
begin 
    if(!r_rst)
        rbin<=0;
    else
        rbin<= rbin_nxt;
end
assign r_addr = rbin[array_size-1:0];


///generating write address for fifomem
assign wbin_nxt= wbin + (w_req & ~full);
always@(posedge w_clk or negedge w_rst)
begin
    if(!w_rst)
        wbin<=0;
    else 
        wbin<= wbin_nxt;
end
assign w_addr = wbin[array_size-1:0];


///generating rptr to send it to w_clk domain(binary to gray)
assign rptr_nxt = rbin_nxt ^ (rbin_nxt>>1);
always @ (posedge r_clk or negedge r_rst)
    if (!r_rst)
        rptr <= 0;
    else 
        rptr <= rptr_nxt;


///generating wptr to send it to r_clk domain(bin to gray)
assign wptr_nxt = wbin_nxt ^ (wbin_nxt>>1);
always @ (posedge w_clk or negedge w_rst)
    if (!w_rst)
        wptr <= 0;
    else 
        wptr <= wptr_nxt;
        
        
///fifo (read and write operations)
localparam DEPTH=(1<<array_size);
reg [data_size-1:0] mem[0:DEPTH-1];

assign r_data=mem[r_addr];    

always@(posedge w_clk)
    if(w_req & ~full)
        mem[w_addr]<=w_data;


endmodule
