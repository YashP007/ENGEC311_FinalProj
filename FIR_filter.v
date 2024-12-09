`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Class: ENGEC311: Final Project
//// Group - 6 Digital Filtering Using HDL
//// Finalized Date: 12/09/24
//// Author: Heewon Park
////////////////////////////////////////////////////////////////////////////////////


//module FIR_Filter1 #(
//    parameter n = 5,               // Number of filter coefficients
//    parameter datawidth = 8      // Bit-width of input and coefficients
//)(
//    input clk,                     // Clock signal
//    input rst,                     // Reset signal
//    input signed [datawidth-1:0] x_in,  // Input signal
//    output reg signed [datawidth-1:0] y_out // Filtered output
//);


//    // Internal registers
//   // Internal registers for delayed inputs (x[n], x[n-1], x[n-2])
//    reg signed [datawidth-1:0] x_delayed [0:2];  // Delays for x[n], x[n-1], x[n-2]
//     reg signed [datawidth-1:0] coeff [0:n-1];

//    // Internal variables to store the filter calculation
//    wire signed [datawidth*2-1:0] product_x [0:4];  // Products for x[n], x[n-1], x[n-2]
//    wire signed [datawidth*2-1:0] sum;  // Sum of all products

//    integer i;
    
//    // Coefficients initialization (example values)
//    initial begin
//        coeff[0] = -8'd4;  // Example coefficients
//        coeff[1] = -8'd2;
//        coeff[2] = -8'd1;
//        coeff[3] = 8'd0;
//        coeff[4] = 8'd0;
//    end
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            for (i = 0; i < n; i = i + 1) begin
//                x_delayed[i] <= 0;
//            end
//        end else begin
//            // Shift pipeline
//            x_delayed[0] <= x_in;  // x[n]
//            x_delayed[1] <= x_delayed[0];  // x[n-1]
//            x_delayed[2] <= x_delayed[1];  // x[n-2]
            
//        end
//    end
    
//    assign product_x[0] = x_delayed[0] * coeff[0];  // B0 * x[n]
//    assign product_x[1] = x_delayed[1] * coeff[1];  // B1 * x[n-1]
//    assign product_x[2] = x_delayed[2] * coeff[2];  // B2 * x[n-2]
    
//    assign product_x[3] = x_delayed[1] * coeff[3];
//    assign product_x[4] = x_delayed[2] * coeff[4];

    
    
//    // Add all products to compute output
//    assign sum = product_x[0] + product_x[1] +product_x[2] + product_x[3] + product_x[4];
    
//    // Update output
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            y_out <= 0;
//        end else begin
//            y_out <= sum[datawidth-1:0]; // Truncate to data width
//        end
//    end
    
//endmodule


module FIR_filter #(
    parameter n = 5,               // Number of filter coefficients
    parameter datawidth = 8        // Bit-width of input and coefficients
)(
    input clk,                     // Clock signal
    input rst,                     // Reset signal
    input signed [datawidth-1:0] x_in,  // Input signal
    output reg signed [datawidth-1:0] y_out // Filtered output
);

    // Internal registers for delayed inputs (x[n], x[n-1], x[n-2], ...)
    reg signed [datawidth-1:0] x_delayed [0:n-1];  
    reg signed [datawidth-1:0] coeff [0:n-1];     // Filter coefficients

    // Internal variables to store the filter calculation
    wire signed [datawidth*2-1:0] product_x [0:n-1];  // Products of x and coefficients
    wire signed [datawidth*2-1:0] sum;  // Sum of all products

    integer i;
    
    // Coefficients initialization (example values)
    initial begin
        coeff[0] = -8'd4;  // Example coefficients
        coeff[1] = -8'd2;
        coeff[2] = -8'd1;
        coeff[3] = 8'd0;
        coeff[4] = 8'd0;
    end

    // Shift register for input delays
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < n; i = i + 1) begin
                x_delayed[i] <= 0;
            end
        end else begin
            // Shift pipeline for the input signal
            x_delayed[0] <= x_in;  // x[n]
            for (i = 1; i < n; i = i + 1) begin
                x_delayed[i] <= x_delayed[i-1];  // x[n-1], x[n-2], ...
            end
        end
    end
    
    // Compute products of coefficients and delayed inputs
    generate
        genvar j;
        for (j = 0; j < n; j = j + 1) begin
            assign product_x[j] = x_delayed[j] * coeff[j];
        end
    endgenerate
    
    // Sum all products
    assign sum = product_x[0] + product_x[1] + product_x[2] + product_x[3] + product_x[4];
    
    // Update output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
        end else begin
            y_out <= sum[datawidth-1:0]; // Truncate to data width
        end
    end
    
endmodule
