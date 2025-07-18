`timescale 1ns/1ps
module debounce (
    input clk,
    input rst,
    input noisy_in,
    output reg clean_pulse
);
    reg [15:0] counter = 0;
    reg sync_0, sync_1, button_ff;
    wire stable;

    // Synchronize to avoid metastability
    always @(posedge clk) begin
        sync_0 <= noisy_in;
        sync_1 <= sync_0;
    end

    // Detect stable level
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            button_ff <= 0;
            clean_pulse <= 0;
        end else begin
            if (sync_1 == button_ff) begin
                counter <= 0;
                clean_pulse <= 0;
            end else begin
                counter <= counter + 1;
                if (counter == 16'hFFFF) begin
                    button_ff <= sync_1;
                    clean_pulse <= sync_1;  // 1-cycle pulse
                    counter <= 0;
                end else begin
                    clean_pulse <= 0;
                end
            end
        end
    end
endmodule

