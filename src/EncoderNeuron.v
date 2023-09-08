module EncoderNeuron (
    input wire clk,
    input wire reset,        
    input wire inputValue,  
    output reg spikeOutput   
);

    parameter N = 10; 
    parameter M = 5;  

    reg [3:0] counter;  
    reg [3:0] lfsr = 4'b0001;  // LFSR

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 4'b0;
            spikeOutput <= 0;
            lfsr <= 4'b0001;
        end
        else begin
            spikeOutput <= 0;
            
            // Simple 4-bit LFSR logic to generate pseudo-random numbers
            lfsr <= {lfsr[2] ^ lfsr[3], lfsr[0], lfsr[1], lfsr[2]};

            // Use the LSB of LFSR to add randomness: if it's 1, reduce the counter by 1, introducing randomness.
            if (inputValue) begin
                if (counter == (M - 1) - lfsr[0]) begin
                    spikeOutput <= 1;
                    counter <= 0;
                end else
                    counter <= counter + 1;
            end else {
                if (counter == (N - 1) - lfsr[0]) begin
                    spikeOutput <= 1;
                    counter <= 0;
                end else
                    counter <= counter + 1;
            end
        end
    end

endmodule
