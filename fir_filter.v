`timescale 1ns / 1ps

module fir_filter (
    input wire        clk,
    input wire [7:0]  data_in,
    output wire [7:0] data_out
);
    parameter signed [7:0] coeff_0 = 8'd1;
    parameter signed [7:0] coeff_1 = 8'd2;
    parameter signed [7:0] coeff_2 = 8'd1;

    reg [7:0] x [0:2];
    reg [15:0] y;

    always @(posedge clk) begin
        x[2] <= x[1];
        x[1] <= x[0];
        x[0] <= data_in;
        y <= coeff_0 * x[0] + coeff_1 * x[1] + coeff_2 * x[2];
    end

    assign data_out = y[15:8]; // Scaled output
endmodule
