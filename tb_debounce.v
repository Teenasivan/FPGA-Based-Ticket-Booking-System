`timescale 1ns/1ps

module tb_debounce;

    reg clk = 0;
    reg rst = 0;
    reg noisy_in = 0;
    wire clean_pulse;

    // Instantiate the debounce module
    debounce uut (
        .clk(clk),
        .rst(rst),
        .noisy_in(noisy_in),
        .clean_pulse(clean_pulse)
    );

    // Generate slower clock: 50ns period (20MHz)
    always #25 clk = ~clk;

    initial begin
        // Optional: Generate waveform for GTKWave or ModelSim
        $dumpfile("debounce_waveform.vcd");
        $dumpvars(0, tb_debounce);

        // Reset the system
        rst = 1; #100;
        rst = 0;

        // Simulate button press with bouncing
        #100 noisy_in = 1;
        #50 noisy_in = 0;  // bounce
        #50 noisy_in = 1;
        #50 noisy_in = 0;
        #50 noisy_in = 1;  // now held high
        #1000;

        // Simulate button release with bouncing
        #100 noisy_in = 0;
        #50 noisy_in = 1;  // bounce
        #50 noisy_in = 0;
        #50 noisy_in = 1;
        #50 noisy_in = 0;  // now held low
        #1000;

        #200 $finish;
    end

endmodule

