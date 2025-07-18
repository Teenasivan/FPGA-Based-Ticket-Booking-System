`timescale 1ns/1ps
module display_controller (
    input clk,
    input [7:0] value,
    output reg [3:0] an,
    output reg [6:0] seg
);
    reg [15:0] refresh_counter = 0;

    wire [3:0] hundreds = value / 100;
    wire [3:0] tens = (value % 100) / 10;
    wire [3:0] ones = value % 10;

    wire [6:0] seg_h, seg_t, seg_o;

    bcd_to_7seg u0 (.digit(hundreds), .seg(seg_h));
    bcd_to_7seg u1 (.digit(tens), .seg(seg_t));
    bcd_to_7seg u2 (.digit(ones), .seg(seg_o));

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        case (refresh_counter[15:14])
            2'b00: begin an <= 4'b1110; seg <= seg_o; end
            2'b01: begin an <= 4'b1101; seg <= seg_t; end
            2'b10: begin an <= 4'b1011; seg <= seg_h; end
            default: begin an <= 4'b1111; seg <= 7'b1111111; end
        endcase
    end
endmodule