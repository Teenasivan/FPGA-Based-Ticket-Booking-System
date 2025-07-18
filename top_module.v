`timescale 1ns/1ps
module top_module (
    input clk,
    input rst,
    input book_btn, cancel_btn, check_btn,
    input [3:0] seat_type,
    input [4:0] travel_date,
    input [1:0] mode_sel,  // 00=price, 01=seats_left, 10=status
    output [6:0] seg,
    output [3:0] an
);

    wire [7:0] price, seats_left;
    wire booking_success, cancel_success, availability_status;
    wire book, cancel, check;
    reg [7:0] display_value;

    // Instantiate ticket booking FSM
    ticket_booking_system uut (
        .clk(clk), .rst(rst),
        .book(book), .cancel(cancel), .check(check),
        .seat_type(seat_type), .travel_date(travel_date),
        .price(price), .seats_left(seats_left),
        .booking_success(booking_success),
        .cancel_success(cancel_success),
        .availability_status(availability_status)
    );

    // Debounce modules
    debounce db_book (.clk(clk), .rst(rst), .noisy_in(book_btn), .clean_pulse(book));
    debounce db_cancel (.clk(clk), .rst(rst), .noisy_in(cancel_btn), .clean_pulse(cancel));
    debounce db_check (.clk(clk), .rst(rst), .noisy_in(check_btn), .clean_pulse(check));

    // Display selection logic
    always @(*) begin
        case (mode_sel)
            2'b00: display_value = price;  // Show ticket price
            2'b01: display_value = seats_left; // Show seats available
            2'b10: begin
                // Status encoding: Booking success = 001, Cancel success = 002, Availability = 003
                if (booking_success)
                    display_value = 8'd1;
                else if (cancel_success)
                    display_value = 8'd2;
                else if (availability_status)
                    display_value = 8'd3;
                else
                    display_value = 8'd0;
            end
            default: display_value = 8'd0;
        endcase
    end

    // Connect to display
    display_controller disp (
        .clk(clk),
        .value(display_value),
        .seg(seg),
        .an(an)
    );

endmodule
