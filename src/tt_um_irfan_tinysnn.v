`timescale 1ns / 1ps
`default_nettype none

module tt_um_irfan_tinysnn (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Since the SNN requires a reset signal that's active high, we'll invert the rst_n signal
    wire reset = ~rst_n;

    wire [1:0] snn_output_spikes;

    // Spiking Neural Network Instance
    SpikingNeuralNetwork snn (
        .clk(clk),
        .reset(reset),
        .rawInputValue(ui_in),
        .output_spikes(snn_output_spikes)
    );

    // Here, I'm assuming that you want to display the output of the SNN on the 7-segment display.
    // The two outputs from the SNN are used as the two least significant bits on the display.
    // The remaining bits can be used as per your requirements.

    assign uo_out = {6'b0, snn_output_spikes};

    // The IO configurations remain unchanged. You can modify them as required for your specific application.
    assign uio_out = uio_in;
    assign uio_oe = 8'b11111111;  // This sets all IOs to be outputs. Adjust accordingly.

endmodule
