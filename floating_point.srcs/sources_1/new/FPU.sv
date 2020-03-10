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
  input [31:0] a, b,
  input [1:0] sel,
  output logic [31:0] out
  );

  logic [31:0] add_out, mult_out;

  fpu_adder ADDER (.a(a), .b(b), .out(add_out));
  fpu_multiplier MULT (.a(a), .b(b), .out(mult_out));

  always_comb begin
      case (sel)
        0: out = add_out;
        2: out = mult_out;
        default: out = 0;
      endcase
  end
endmodule

module fpu_adder(
  input [31:0] a, b,
  output logic [31:0] out
  );

  logic a_sign, b_sign, out_sign;
  logic [7:0] a_exponent, b_exponent, out_exponent;
  logic [22:0] a_mantissa, b_mantissa;
  logic [22:0] out_mantissa;
  logic [7:0] exp_diff;
  logic [23:0] a_signed, b_signed, out_signed, a_twos, b_twos;
  logic a_hidden, b_hidden, out_hidden, out_carry;


  always_comb begin

    a_sign = a[31];
    b_sign = b[31];
    a_exponent = a[30:23];
    b_exponent = b[30:23];
    a_mantissa = a[22:0];
    b_mantissa = b[22:0];

    if (a_exponent < b_exponent) begin
      exp_diff = b_exponent-a_exponent;
      a_exponent = a_exponent + exp_diff;
      a_mantissa = {1'b1, a_mantissa} >> exp_diff;
      a_hidden = 0;
      b_hidden = 1;
      out_exponent = b_exponent;
    end
    else begin
      exp_diff = a_exponent-b_exponent;
      b_exponent = b_exponent + exp_diff;
      b_mantissa = {1'b1, b_mantissa} >> exp_diff;
      a_hidden = 1;
      if (exp_diff == 0)
        b_hidden = 1;
      else
        b_hidden = 0;
      out_exponent = a_exponent;
    end

    if (a_sign == 0 && b_sign == 0) begin
      {out_carry, out_hidden, out_mantissa} = {1'b0, a_hidden, a_mantissa} + {1'b0, b_hidden, b_mantissa};
      out_sign = 0;
    end
    else if (a_sign == 1 && b_sign == 0) begin
      if (a_mantissa > b_mantissa) begin
        {out_carry, out_hidden, out_mantissa} = {1'b0, a_hidden, a_mantissa} - {1'b0, b_hidden, b_mantissa};
        out_sign = 1;
      end
      else begin
        {out_carry, out_hidden, out_mantissa} = {1'b0, b_hidden, b_mantissa} - {1'b0, a_hidden, a_mantissa};
        out_sign = 0;
      end
    end
    else if (a_sign == 0 && b_sign == 1) begin
      if (a_mantissa > b_mantissa) begin
        {out_carry, out_hidden, out_mantissa} = {1'b0, a_hidden, a_mantissa} - {1'b0, b_hidden, b_mantissa};
        out_sign = 0;
      end
      else begin
        {out_carry, out_hidden, out_mantissa} = {1'b0, b_hidden, b_mantissa} - {1'b0, a_hidden, a_mantissa};
        out_sign = 1;
      end
    end
    else begin
      out_mantissa = {1'b0, a_hidden, a_mantissa} + {1'b0, b_hidden, b_mantissa};
      out_sign = 1;
    end


    if (out_carry == 0 && out_hidden == 1) begin
      out = {out_sign, out_exponent, out_mantissa};
    end
    else if (out_carry == 1) begin
      out = {out_sign, out_exponent + 1, out_mantissa >> 1};
    end
    else begin
      for (int i = 22; i >= 0; i--) begin
        if (out_mantissa[i] == 1) begin
          out_mantissa = out_mantissa << 23-i;
          out_exponent = out_exponent - (23-i);
          break;
        end
        else begin
          out_mantissa = out_mantissa << 0;
        end
      end
      out = {out_sign, out_exponent, out_mantissa};
    end

  end

endmodule

module fpu_multiplier(
  input [31:0] a, b,
  output logic [31:0] out
  );

  logic a_sign, b_sign, out_sign;
  logic [7:0] a_exponent, b_exponent, shift_exponent, out_exponent;
  logic [23:0] a_mantissa, b_mantissa;
  logic [47:0] out_mantissa_big;
  logic [24:0] out_mantissa, shift_mantissa;
  logic [7:0] exp_diff;
  logic [23:0] a_signed, b_signed, out_signed, a_twos, b_twos;
  logic a_MSB, b_MSB, hidden_bit, carry;

  assign a_sign = a[31];
  assign b_sign = b[31];
  assign a_exponent = a[30:23];
  assign b_exponent = b[30:23];
  assign a_mantissa = {1'b1, a[22:0]};
  assign b_mantissa = {1'b1, b[22:0]};

  always_comb begin
    shift_exponent = a_exponent + b_exponent - 127;
    out_sign = a_sign ^ b_sign;
    out_mantissa_big = a_mantissa * b_mantissa;
    shift_mantissa = out_mantissa_big[47:23];
    if (shift_mantissa[24] == 1) begin
      out_mantissa = shift_mantissa >> 1;
      out_exponent = shift_exponent+1;
    end
    else begin
      out_mantissa = shift_mantissa;
      out_exponent = shift_exponent;
    end
    out = {out_sign,out_exponent,out_mantissa[22:0]};
  end


endmodule
