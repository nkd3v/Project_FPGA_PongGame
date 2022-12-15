`timescale 1ns / 1ps

module segment (
    input clk,
    input [3:0] p1,
    input [3:0] p2,
    input beep,
    output buzzer,
    output reg [6:0] seg,
    output reg [3:0] common
);

  reg [6:0] seg1;
  reg [6:0] seg2;
  reg sel;

  initial begin
    seg1 <= 7'b0000000;
    seg2 <= 7'b0000000;
  end

  assign buzzer = beep;

  always @(posedge clk) begin
    sel <= ~sel;
    case (sel)
      1'b0: begin
        seg <= seg1;
        common <= 4'b0111;
      end
      1'b1: begin
        seg <= seg2;
        common <= 4'b1110;
      end
    endcase
  end

  always @(p1) begin
    case (p1)
      4'b0000: seg1 <= 7'b1111110;  // "1"     
      4'b0001: seg1 <= 7'b0110000;  // "0" 
      4'b0010: seg1 <= 7'b1101101;  // "2" 
      4'b0011: seg1 <= 7'b1111001;  // "3" 
      4'b0100: seg1 <= 7'b0110011;  // "4" 
      4'b0101: seg1 <= 7'b1011011;  // "5" 
      4'b0110: seg1 <= 7'b1011111;  // "6" 
      4'b0111: seg1 <= 7'b1110000;  // "7" 
      4'b1000: seg1 <= 7'b1111111;  // "8"     
      4'b1001: seg1 <= 7'b1111011;  // "9" 
      default: seg1 <= 7'b1111110;  // "1"
    endcase
  end

  always @(p2) begin
    case (p2)
      4'b0000: seg2 <= 7'b1111110;  // "1"     
      4'b0001: seg2 <= 7'b0110000;  // "0" 
      4'b0010: seg2 <= 7'b1101101;  // "2" 
      4'b0011: seg2 <= 7'b1111001;  // "3" 
      4'b0100: seg2 <= 7'b0110011;  // "4" 
      4'b0101: seg2 <= 7'b1011011;  // "5" 
      4'b0110: seg2 <= 7'b1011111;  // "6" 
      4'b0111: seg2 <= 7'b1110000;  // "7" 
      4'b1000: seg2 <= 7'b1111111;  // "8"     
      4'b1001: seg2 <= 7'b1111011;  // "9" 
      default: seg2 <= 7'b1111110;  // "1"
    endcase
  end
endmodule
