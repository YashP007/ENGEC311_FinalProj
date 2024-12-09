`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 03:41:59 PM
// Design Name: 
// Module Name: Filter1
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


module Filter1 #(
    parameter n = 6,               // Number of filter coefficients
    parameter datawidth = 8      // Bit-width of input and coefficients
)(
    input clk,                     // Clock signal
    input rst,                     // Reset signal
    input signed [datawidth-1:0] x_in,  // Input signal
    output reg signed [datawidth-1:0] y_out // Filtered output
);
    // Internal registers
    reg signed [datawidth-1:0] shift_reg [0:n-1]; // Shift registers for pipeline
    reg signed [datawidth-1:0] coeff [0:n-1];     // Filter coefficients
    wire signed [datawidth*2-1:0] product [0:n-1];// Multiplier outputs
    wire signed [datawidth*2-1:0] sum;            // Adder output
    integer i;
    
    
    // Coefficients initialization (example values)
    initial begin
        coeff[0] = -8'd4;  // Example coefficients
        coeff[1] = -8'd2;
        coeff[2] = -8'd1;
        coeff[3] = 8'd0;
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < n; i = i + 1) begin
                shift_reg[i] <= 0;
            end
        end else begin
            // Shift pipeline
            shift_reg[0] <= x_in;
            for (i = 1; i < n; i = i + 1) begin
                shift_reg[i] <= shift_reg[i-1];
            end
        end
    end
    generate
        genvar j;
        for (j = 0; j < n; j = j + 1) begin : mult_accum
            assign product[j] = shift_reg[j] * coeff[j]; // Multiplication
        end
    endgenerate
    // Add all products to compute output
    assign sum = product[0] + product[1] + product[2] + product[3];
    // Update output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
        end else begin
            y_out <= sum[datawidth-1:0]; // Truncate to data width
        end
    end
endmodule


