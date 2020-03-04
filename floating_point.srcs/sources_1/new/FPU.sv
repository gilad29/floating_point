`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03/03/2020 04:33:48 PM
// Design Name:
// Module Name: FPU
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


module FPU(

    );
endmodule

module fpu_adder(
  input [31:0] a, b,
  output logic [31:0] out
  );

  logic a_sign, b_sign, out_sign;
  logic [7:0] a_exponent, b_exponent, out_exponent;
  logic [23:0] a_mantissa, b_mantissa;
  logic [24:0] out_mantissa;
  logic [7:0] exp_diff;
  logic [23:0] a_signed, b_signed, out_signed, a_twos, b_twos;

  assign a_sign = a[31];
  assign b_sign = b[31];
  assign a_exponent = a[30:23];
  assign b_exponent = b[30:23];
  assign a_mantissa = {1'b1, a[22:0]};
  assign b_mantissa = {1'b1, b[22:0]};

  always_comb begin
    if (a_exponent < b_exponent) begin
      exp_diff = b_exponent-a_exponent;
      a_exponent = a_exponent + exp_diff;
      a_mantissa = a_mantissa >> exp_diff;
    end
    else begin
      exp_diff = a_exponent-b_exponent;
      b_exponent = b_exponent + exp_diff;
      b_mantissa = b_mantissa >> exp_diff;
    end

    if (a_sign == 0 && b_sign == 0) begin
      out_mantissa = a_mantissa + b_mantissa;
      out_sign = 0;
    end
    else if (a_sign == 1 && b_sign == 0) begin
      if (a_mantissa > b_mantissa) begin
        out_mantissa = a_mantissa - b_mantissa;
        out_sign = 1;
      end
      else begin
        out_mantissa = b_mantissa - a_mantissa;
        out_sign = 0;
      end
    end
    else if (a_sign == 0 && b_sign == 1) begin
      if (a_mantissa > b_mantissa) begin
        out_mantissa = a_mantissa - b_mantissa;
        out_sign = 0;
      end
      else begin
        out_mantissa = b_mantissa - a_mantissa;
        out_sign = 1;
      end
    end
    else begin
      out_mantissa = a_mantissa + b_mantissa;
      out_sign = 1;
    end

    out_exponent = a_exponent;
    out = {out_sign, out_exponent, out_mantissa[22:0]};
  end



endmodule

module fpu_multiplier(
  input [31:0] a, b,
  output logic [31:0] out
  );

endmodule
