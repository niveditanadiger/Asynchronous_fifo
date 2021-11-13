`timescale 1ns / 1ns

module async_fifo_tb ();

parameter data_size = 8;
parameter array_size = 4;
parameter WCLK_PERIOD = 10;
parameter RCLK_PERIOD = 40;

reg w_req, w_clk, w_rst, r_req, r_clk, r_rst;
reg [data_size-1:0] w_data;
wire [data_size-1:0] r_data;
wire full, empty;

// Instance
async_fifo#(.data_size(data_size),.array_size(array_size))
    u_async_fifo(.w_req (w_req), .w_rst(w_rst), .w_clk(w_clk),.r_req(r_req), .r_clk(r_clk), .r_rst(r_rst),.w_data(w_data), .r_data(r_data), .full(full), .empty(empty));


initial begin
    w_rst = 0;
    w_clk = 0;
    w_req = 0;
    w_data = 0;
    repeat (2) #(WCLK_PERIOD/2) w_clk = ~w_clk;
    w_rst = 1;
    forever #(WCLK_PERIOD/2) w_clk = ~w_clk;
end

initial begin
    r_rst = 0;
    r_clk = 0;
    r_req = 0;
    repeat (2) #(RCLK_PERIOD/2) r_clk = ~r_clk;
    r_rst = 1;
    forever  #(RCLK_PERIOD/2) r_clk = ~r_clk;
end


initial begin
    repeat (4) @ (posedge w_clk);
     @(negedge w_clk); w_req = 1;w_data = 8'd1;
     @(negedge w_clk); w_req = 1;w_data = 8'd2;
     @(negedge w_clk); w_req = 1;w_data = 8'd3;
     @(negedge w_clk); w_req = 1;w_data = 8'd4;
     @(negedge w_clk); w_req = 1;w_data = 8'd5;
     @(negedge w_clk); w_req = 1;w_data = 8'd6;
     @(negedge w_clk); w_req = 1;w_data = 8'd7;
     @(negedge w_clk); w_req = 1;w_data = 8'd8;
     @(negedge w_clk); w_req = 1;w_data = 8'd9;
     @(negedge w_clk); w_req = 1;w_data = 8'd10;
     @(negedge w_clk); w_req = 1;w_data = 8'd11;
     @(negedge w_clk); w_req = 1;w_data = 8'd12;
     @(negedge w_clk); w_req = 1;w_data = 8'd13;
     @(negedge w_clk); w_req = 1;w_data = 8'd14;
     @(negedge w_clk); w_req = 1;w_data = 8'd15;
     @(negedge w_clk); w_req = 1;w_data = 8'd16;
     @(negedge w_clk); w_req = 0;

     @(negedge r_clk); r_req = 1;
     repeat (17) @(posedge r_clk);
     r_req=0;

     #100;
     $finish;
end

endmodule