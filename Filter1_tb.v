`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 04:03:07 PM
// Design Name: 
// Module Name: Filter1_tb
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


module Filter1_tb(

    );
    parameter N = 4;     // Number of filter coefficients
    parameter datawidth = 8;     // Bit-width of input and coefficients
    
    reg clk;
    reg rst;
    reg signed [datawidth-1:0] x_in;
    wire signed [datawidth-1:0] y_out;
    
  FIR_filter #(
    .datawidth(datawidth),       // Bit-width of input, output, and coefficients
    .N(N)       // Number of coefficients (3 beta, 2 alpha)
)filter(
    .clk(clk),                      // Clock signal
    .rst(rst),                      // Reset signal
    .x_in(x_in),  // Current input sample x[n]
    .y_out(y_out) // Filtered output y[n]
);
    // Coefficient array


initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

initial begin
    rst = 1;
    x_in = 0;
    
    #10 rst = 0; 
    
    x_in = 8'b0;
    #2;
    x_in = 8'b0;
    #2;
    x_in = 8'b0;
    #2;
    x_in = 8'b0;
    #2;
    
    
    #10
    rst  = 1; 
    #2;
    rst = 0;
    
    x_in = 8'b1;
    #50;
    $stop;
end


endmodule