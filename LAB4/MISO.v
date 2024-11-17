
module MISO(
    input [31:0] x,  
    input [31:0] y, 
    input [31:0] z, 
    output [63:0] out
);

    // Intermediate wires
    wire [63:0] o1, o2, o3;
    wire [63:0] out_temp1, out_temp2, out_temp3;
    wire [63:0] out_temp;

    // Weight declaration
    reg [3:0] w [2:0];

    // Initialize weights
    initial begin
        w[0] = 4'b0001;   
        w[1] = 4'b0111;   
        w[2] = 4'b0011;  
    end

    // Instantiate neuron modules
    neuron n1 (.out_neuron(o1), .input_neuron(x), .weight_value(w[0]));
    neuron n2 (.out_neuron(o2), .input_neuron(y), .weight_value(w[1]));
    neuron n3 (.out_neuron(o3), .input_neuron(z), .weight_value(w[2]));

    // Instantiate ReLU modules
    ReLU r1 (.in(o1), .out(out_temp1));
    ReLU r2 (.in(o2), .out(out_temp2));
    ReLU r3 (.in(o3), .out(out_temp3));

    // Sum the outputs of the ReLU modules
    assign out_temp = out_temp1 + out_temp2 + out_temp3;

    // Final ReLU on the summed output
    ReLU r_final (.in(out_temp), .out(out));

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

