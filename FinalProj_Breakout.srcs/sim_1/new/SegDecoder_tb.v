`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 10:58:43 AM
// Design Name: 
// Module Name: SegDecoder_tb
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


module SegDecoder_tb(
    );
    
    // Create regs/wires and variables
    reg  [3:0] bcd_tb;
    wire [6:0] seg_tb;
    reg  [6:0] result;
    reg[3:0] i;
    
    // Duration for each vector
    localparam period = 20;
    
    // Instantiate the module
    SegDecoder uut(.bcd(bcd_tb), .seg(seg_tb));
    
    // Golden model for expected segments (active-low a..g)
    function automatic [6:0] expect_seg(input [3:0] b);
        case (b)
          4'd0: expect_seg = 7'b0000001;
          4'd1: expect_seg = 7'b1001111;
          4'd2: expect_seg = 7'b0010010;
          4'd3: expect_seg = 7'b0000110;
          4'd4: expect_seg = 7'b1001100;
          4'd5: expect_seg = 7'b0100100;
          4'd6: expect_seg = 7'b0100000;
          4'd7: expect_seg = 7'b0001111;
          4'd8: expect_seg = 7'b0000000;
          4'd9: expect_seg = 7'b0000100;
          default: expect_seg = 7'b1111111;
        endcase
      endfunction
    
      initial begin
        for (i = 0; i < 16; i = i + 1) begin
          bcd_tb = i[3:0];
          result = expect_seg(i[3:0]);
          #period;
          if (result == seg_tb)
            $display("bcd=%0d seg=%07b passed.", i, seg_tb);
          else
            $display("bcd=%0d seg=%07b failed. (exp=%07b)", i, seg_tb, result);
        end
        $finish;
      end
endmodule
