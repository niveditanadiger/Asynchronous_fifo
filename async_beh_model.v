`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2021 09:11:01
// Design Name: 
// Module Name: async_beh_model
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module async_beh_model(rdata, full, empty, wdata, winc, wclk, w_rst, rinc, rclk, r_rst);
parameter DSIZE=8;
parameter ASIZE=4;
output [DSIZE-1:0]rdata;
output full,empty;
input [DSIZE-1:0]wdata;
input winc,rinc,wclk,rclk,w_rst,r_rst;
reg [ASIZE:0] wptr, wrptr1, wrptr2, wrptr3;
reg [ASIZE:0] rptr, rwptr1, rwptr2, rwptr3;

parameter MEMDEPTH=1<<ASIZE;

reg [DSIZE-1:0] fifo_mem[0:MEMDEPTH];

always@(posedge wclk or negedge w_rst)
    if(!w_rst)      wptr<=0;
    else if(winc && ~full)      
    begin
        fifo_mem[wptr[ASIZE-1:0]]<=wdata;
        wptr<=wptr+1;
    end

always@(posedge wclk or negedge w_rst)
    if(!w_rst)      {wrptr3,wrptr2,wrptr1}<=0;
    else            {wrptr3,wrptr2,wrptr1}<={wrptr2,wrptr1,rptr};
    
always@(posedge rclk or negedge r_rst)
    if(!r_rst)      rptr<=0;
    else if(rinc && ~empty)      
    begin
        rptr<=rptr+1;
    end

always@(posedge rclk or negedge r_rst)
    if(!r_rst)      {rwptr3,rwptr2,rwptr1}<=0;
    else            {rwptr3,rwptr2,rwptr1}<={rwptr2,rwptr1,wptr};

assign rdata=fifo_mem[rptr[ASIZE-1:0]];
assign empty=(rptr==rwptr3);
assign full=((wptr[ASIZE-1:0]==wrptr3[ASIZE-1:0]) && (wptr[ASIZE]!=wrptr3[ASIZE]));

endmodule
