
module SISO(
    input [31:0] x,            // Single input
    output [63:0] y            // Single output
);

    reg [3:0] weight;
    wire [63:0] bias = 1;
    wire [63:0] neuron_output;
    wire [63:0] relu_output;

    initial begin
        weight = 4'b0101;  
    end

    neuron n1 (
        .out_neuron(neuron_output),
        .input_neuron(x),
        .weight_value(weight)
    );

    ReLU r1 (
        .in(neuron_output),
        .out(relu_output)
    );

    assign y = relu_output;

endmodule

module neuron(
    output reg [63:0] out_neuron,
    input [31:0] input_neuron,
    input [3:0] weight_value
);

    wire [63:0] bias = 1;

    reg [63:0] out_mul;

    always @(*) begin
        out_mul = weight_value * input_neuron;
        out_neuron = out_mul + bias;
    end

endmodule

module ReLU(
    input signed [31:0] in,  
    output reg [63:0] out  
);

    always @(*) begin
        if (in < 0) begin
            out = 0;  
        end else begin
            out = in;  
        end
    end

endmodule



