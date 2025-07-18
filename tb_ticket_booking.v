`timescale 1ns/1ps
module tb_ticket_booking;

    reg clk = 0;
    reg rst = 0;
    reg book = 0, cancel = 0, check = 0;
    reg [3:0] seat_type = 0;
    reg [4:0] travel_date = 0;

    wire [7:0] price;
    wire [7:0] seats_left;
    wire booking_success, cancel_success, availability_status;

    // Instantiate your FSM-based ticket booking module
    ticket_booking_system uut (
        .clk(clk),
        .rst(rst),
        .book(book),
        .cancel(cancel),
        .check(check),
        .seat_type(seat_type),
        .travel_date(travel_date),
        .price(price),
        .seats_left(seats_left),
        .booking_success(booking_success),
        .cancel_success(cancel_success),
        .availability_status(availability_status)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Reset the system
        rst = 1; #20; rst = 0;

        // ===== CASE 1: Book Regular (0) on Date 5 =====
        seat_type = 0; travel_date = 5;
        book = 1; #10; book = 0;
        #50;

        // ===== CASE 2: Cancel Regular (0) on Date 5 =====
        cancel = 1; #10; cancel = 0;
        #50;

        // ===== CASE 3: Check Regular (0) on Date 5 =====
        check = 1; #10; check = 0;
        #50;

        // ===== CASE 4: Book AC (1) on Date 10 =====
        seat_type = 1; travel_date = 10;
        book = 1; #10; book = 0;
        #50;

        // ===== CASE 5: Check AC (1) on Date 10 =====
        check = 1; #10; check = 0;
        #50;

        // ===== CASE 6: Cancel AC (1) on Date 10 =====
        cancel = 1; #10; cancel = 0;
        #50;

        // ===== CASE 7: Book Sleeper (2) on Date 15 =====
        seat_type = 2; travel_date = 15;
        book = 1; #10; book = 0;
        #50;

        // ===== CASE 8: Check Sleeper (2) on Date 15 =====
        check = 1; #10; check = 0;
        #50;

        $finish;
    end

endmodule

