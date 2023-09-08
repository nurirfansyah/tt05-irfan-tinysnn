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

    wire [7:0] encoded_spikes;
    wire [1:0] snn_output;

    // Spiking Neural Network
    SpikingNeuralNetwork snn (
        .clk(clk),
        .reset(!rst_n),
        .inputValue(ui_in),
        .input_spikes(encoded_spikes),
        .output_spikes(snn_output)
    );

    // Map the 2 SNN outputs to the first 2 bits of uo_out
    assign uo_out[1:0] = snn_output;
    assign uo_out[7:2] = 6'b101010; // Assigning the rest of the bits to 0 for this example.

    // IO Pins - Placeholder logic, not connected to SNN for now
    assign uio_out = uio_in;
    assign uio_oe = 8'b11111111; // All set as outputs for this example.

endmodule
