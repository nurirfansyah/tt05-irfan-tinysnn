module SpikingNeuralNetwork (
    input wire clk,
    input wire reset,        
    input wire[7:0] inputValue,  // 8 input values (each 0 or 1)
    output wire[7:0] input_spikes, // Encoded spikes
    output wire[1:0] output_spikes // 2 output neurons (dummy in this code, connect to your SNN implementation)
);

    // Create an array of encoder neurons
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            EncoderNeuron en (
                .clk(clk),
                .reset(reset),
                .inputValue(inputValue[i]),
                .spikeOutput(input_spikes[i])
            );
        end
    endgenerate

    // Dummy logic for 2 output neurons. 
    // You should connect these encoded spikes to your SNN logic here.
    assign output_spikes = {input_spikes[0] & input_spikes[1], input_spikes[2] & input_spikes[3]}; 

endmodule
