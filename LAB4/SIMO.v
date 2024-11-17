module SIMO(
    input [31:0] x,            // Single input
    output [63:0] y1,          // First output
    output [63:0] y2,          // Second output
    output [63:0] y3           // Third output
);

    // Weight declaration
    reg [3:0] w [2:0];

    // Intermediate outputs from neuron modules
    wire [63:0] o1, o2, o3;

    // ReLU outputs
    wire [63:0] out1, out2, out3;

    // Initialize weights
    initial begin
        w[0] = 4'b0001;   // Weight for y1
        w[1] = 4'b0111;   // Weight for y2
        w[2] = 4'b0011;   // Weight for y3
    end

    // Instantiate neuron modules for each output
    neuron n1 (.out_neuron(o1), .input_neuron(x), .weight_value(w[0]));
    neuron n2 (.out_neuron(o2), .input_neuron(x), .weight_value(w[1]));
    neuron n3 (.out_neuron(o3), .input_neuron(x), .weight_value(w[2]));

    // Apply ReLU activation to each neuron's output
    ReLU r1 (.in(o1), .out(out1));
    ReLU r2 (.in(o2), .out(out2));
    ReLU r3 (.in(o3), .out(out3));

    // Assign outputs
    assign y1 = out1;
    assign y2 = out2;
    assign y3 = out3;

endmodule

module neuron(
    output reg [63:0] out_neuron,
    input [31:0] input_neuron,
    input [3:0] weight_value
);

    // Bias constant
    wire [63:0] bias = 1;

    // Intermediate multiplication result
    reg [63:0] out_mul;

    // Compute neuron output
    always @(*) begin
        out_mul = weight_value * input_neuron;
        out_neuron = out_mul + bias;
    end

endmodule

module ReLU(
    input signed [63:0] in,  
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
