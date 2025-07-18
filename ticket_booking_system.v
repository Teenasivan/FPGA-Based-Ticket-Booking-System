`timescale 1ns/1ps
module ticket_booking_system (
    input clk,
    input rst,
    input book,
    input cancel,
    input check,
    input [3:0] seat_type,
    input [4:0] travel_date,
    output reg [7:0] price,
    output reg [7:0] seats_left,
    output reg booking_success,
    output reg cancel_success,
    output reg availability_status
);

    // FSM States (2-bit encoding)
    parameter IDLE = 2'b00,
              BOOKING = 2'b01,
              CANCELLING = 2'b10,
              CHECKING = 2'b11;

    reg [1:0] state, next_state;

    reg [7:0] seat_matrix [0:2][0:31];  // 3 seat types × 32 travel dates

    reg [1:0] pulse_count;

    integer i, j;

    // State transition logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (book)
                    next_state = BOOKING;
                else if (cancel)
                    next_state = CANCELLING;
                else if (check)
                    next_state = CHECKING;
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // FSM with seat logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            price <= 8'd0;
            booking_success <= 0;
            cancel_success <= 0;
            availability_status <= 0;
            seats_left <= 0;
            pulse_count <= 0;

            // Initialize all seats to 10
            for (i = 0; i < 3; i = i + 1)
                for (j = 0; j < 32; j = j + 1)
                    seat_matrix[i][j] <= 8'd10;
        end else begin
            state <= next_state;

            // Auto-clear outputs after a few cycles
            if (pulse_count > 0)
                pulse_count <= pulse_count - 1;
            else begin
                booking_success <= 0;
                cancel_success <= 0;
                availability_status <= 0;
            end

            case (next_state)
                BOOKING: begin
                    if (seat_matrix[seat_type][travel_date] > 0) begin
                        seat_matrix[seat_type][travel_date] <= seat_matrix[seat_type][travel_date] - 1;
                        booking_success <= 1;
                        pulse_count <= 2;

                        case (seat_type)
                            0: price <= 8'd100;
                            1: price <= 8'd150;
                            2: price <= 8'd200;
                            default: price <= 8'd0;
                        endcase
                    end
                end

                CANCELLING: begin
                    seat_matrix[seat_type][travel_date] <= seat_matrix[seat_type][travel_date] + 1;
                    cancel_success <= 1;
                    price <= 8'd0;
                    pulse_count <= 2;
                end

                CHECKING: begin
                    seats_left <= seat_matrix[seat_type][travel_date];
                    availability_status <= 1;
                    pulse_count <= 2;
                end
            endcase
        end
    end

endmodule

