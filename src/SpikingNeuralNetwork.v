module SpikingNeuralNetwork (
    input wire clk,
    input wire reset,
    input wire [7:0] rawInputValue,  // Raw input values
    output reg [1:0] output_spikes
);

    wire [7:0] encodedSpikes;  // Spikes generated by the encoder neurons
    
    // Create 8 instances of EncoderNeuron
    generate
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin
            EncoderNeuron en (
                .clk(clk),
                .reset(reset),
                .inputValue(rawInputValue[i]),
                .spikeOutput(encodedSpikes[i])
            );
        end
    endgenerate

    parameter STDP_WINDOW = 3'd3;  // Define the STDP time window
    parameter MAX_WEIGHT = 4'd15;  // Maximum synaptic weight
    parameter MIN_WEIGHT = 4'd0;   // Minimum synaptic weight

    reg [7:0] last_spike_time;  // Store the time of the last spike for each input neuron
    reg [3:0] weights[7:0];     // Synaptic weights for each input neuron to the 2 output neurons
    reg [2:0] output_neuron_timer[1:0]; // Timer to monitor the firing of the output neurons

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            output_spikes <= 2'b0;
            last_spike_time <= 8'b0;
            weights[7:0] <= MAX_WEIGHT / 2;  // Initialize weights to half the maximum value
            output_neuron_timer[1:0] <= 3'd0;
        end else begin
            // Check input spikes and update spike times
            for (int i = 0; i < 8; i = i + 1) begin
                if (encodedSpikes[i])
                    last_spike_time[i] <= 3'd0;
                else if (last_spike_time[i] < 3'd7)
                    last_spike_time[i] <= last_spike_time[i] + 1;
            end

            // Check for output spikes and adjust weights based on STDP
            for (int j = 0; j < 2; j = j + 1) begin
                if (output_neuron_timer[j] == STDP_WINDOW) begin
                    output_spikes[j] <= 0;
                    output_neuron_timer[j] <= 0;
                end else if (output_neuron_timer[j] > 0) begin
                    output_neuron_timer[j] <= output_neuron_timer[j] + 1;
                end
                
                // Basic SNN logic: sum the spikes weighted by the synaptic weights
                int sum = 0;
                for (int i = 0; i < 8; i = i + 1) begin
                    sum = sum + (encodedSpikes[i] ? weights[i] : 0);

                    // Adjust weights based on STDP rules
                    if (encodedSpikes[i]) begin
                        if (output_neuron_timer[j] > 0 && output_neuron_timer[j] < STDP_WINDOW) 
                            weights[i] = weights[i] + 1;  // Potentiation
                        else if (output_neuron_timer[j] == 0 && last_spike_time[i] < STDP_WINDOW)
                            weights[i] = weights[i] - 1;  // Depression
                    end
                end

                // If the sum exceeds a threshold, the output neuron fires
                if (sum > (6 * MAX_WEIGHT / 10)) begin
                    output_spikes[j] <= 1;
                    output_neuron_timer[j] <= 1;
                end
            end
        end
    end

endmodule
