
module MIMO(in1,in2,in3,in4,out_main1,out_main2);

input [3:0] in1,in2,in3,in4;
output [15:0] out_main1,out_main2;

wire [3:0] i1 = 4'b0000;
wire [3:0] i2 = 4'b0001;
wire [3:0] i3 = 4'b0010;
wire [3:0] i4 = 4'b0011;
wire [3:0] i5 = 4'b0100;
wire [3:0] i6 = 4'b0101;
wire [3:0] i7 = 4'b0110;
wire [3:0] i8 = 4'b0111;
wire [3:0] i9 = 4'b1000;

wire [3:0] w_val1,w_val2,w_val3,w_val4,w_val5,w_val6,w_val7,w_val8,w_val9;
wire [7:0] out_n1,out_n2,out_n3,out_n4;
wire [7:0] out_1,out_2,out_3,out_4;
wire [7:0] out_temp1,out_temp2,out_temp3;
wire [15:0] out_mem1,out_mem2;

mem m1(i1,w_val1);
neuron  n1(out_n1,in1,w_val1);
//normalization norm1(out_1,out_n1);

mem m2(i2,w_val2);
neuron  n2(out_n2,in2,w_val2);

mem m3(i3,w_val3);
neuron  n3(out_n3,in3,w_val3);

mem m4(i4,w_val4);
neuron  n4(out_n4,in4,w_val4);

relu R1(out_1,out_2,out_n1,out_n2,out_n3,out_n4);
//relu R3(out_3,out_n7,out_n8,out_n9);


assign  out_main1 = out_1;
assign  out_main2 = out_2;

endmodule

//mem

module mem(index,weight_value);
input [3:0] index;
output reg [3:0] weight_value;

always @(*)
begin
case(index)

4'b0000 : weight_value = 4'b0101;
4'b0001 : weight_value = 4'b1011;
4'b0010 : weight_value = 4'b1010;
4'b0011 : weight_value = 4'b0110;
4'b0100 : weight_value = 4'b0100;
4'b0101 : weight_value = 4'b1100;
4'b0110 : weight_value = 4'b1101;
4'b0111 : weight_value = 4'b1110;
4'b1000 : weight_value = 4'b1000;

endcase
end

endmodule

//relu
module relu(data_out1,data_out2,data_in1,data_in2,data_in3,data_in4);
input signed [7:0] data_in1,data_in2,data_in3,data_in4;
output reg signed [7:0] data_out1,data_out2;

reg  signed [7:0] data_temp1,data_temp2;
wire signed [3:0] inputs[7:0];

integer i;

assign inputs[0]= data_in1;
assign inputs[1]= data_in2;
assign inputs[2]= data_in3;
assign inputs[3]= data_in4;
//assign inputs[4]= data_in5;
//assign inputs[5]= data_in6;
//assign inputs[6]= data_in7;
//assign inputs[7]= data_in8;

always@(*)
begin
  data_temp1 = (inputs[0] > inputs[1]) ? inputs[0] : inputs[1];
  data_temp2 = (inputs[0] > inputs[1]) ? inputs[1] : inputs[0];

  for (i = 2; i < 3; i = i + 1) begin
    if (inputs[i] > data_temp1) begin
      data_temp2 = data_temp1;
      data_temp1 = inputs[i];
    end
    else if (inputs[i] > data_temp2) begin
      data_temp2 = inputs[i];
    end
  end

  data_out1 = data_temp1;
  data_out2 = data_temp2;
end

endmodule

//neuron
module neuron(out_neuron,input_neuron,weight_value);
input [3:0] weight_value;
input [3:0] input_neuron;
output [7:0] out_neuron;

wire [7:0] bias= 8'b00000001 ;
wire [7:0] out_mul;

smul s1 (out_mul,weight_value,input_neuron);
sadder s2(out_neuron,out_mul,bias);

endmodule

//add
module sadder(
  output signed [7:0] sum,
  input signed [7:0] a,
  input signed [7:0] b);

  assign sum = a + b;
endmodule

//mul
module smul(p,a,b);

input [3:0] a,b;
output [7:0] p;
supply1 one;

wire w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18,w19,w20,w21,w22,w23;

assign p[0]=a[0]&b[0];

half_adder HA1(a[1]&b[0],a[0]&b[1],p[1],w1);
half_adder HA2(a[2]&b[0],a[1]&b[1],w2,w3);
half_adder HA3(~(a[3]&b[0]),a[2]&b[1],w4,w5);

full_adder FA1(w2,w1,a[0]&b[2],p[2],w6);
full_adder FA2(w4,w3,a[1]&b[2],w7,w8);
full_adder FA3(w5,a[2]&b[2],~(a[3]&b[1]),w9,w10);

full_adder FA4(w6,w7,~(a[0]&b[3]),p[3],w11);
full_adder FA5(w8,w9,~(a[1]&b[3]),w12,w13);
full_adder FA6(w10,~(a[2]&b[3]),~(a[3]&b[2]),w14,w15);

full_adder FA7(one,w11,w12,p[4],w16);
half_adder HA4(w13,w14,w17,w18);
half_adder HA5(a[3]&b[3],w15,w19,w20);

half_adder HA6(w16,w17,p[5],w21);
half_adder HA7(w18,w19,w22,w23);

half_adder HA8(w21,w22,p[7],p[6]);

endmodule

module half_adder(x,y,s,cout);
input x,y;
output s,cout;
assign s=x^y;
assign cout=(x&y);
endmodule

module full_adder(x,y,cin,s,cout);
input x,y,cin;
output s,cout;
assign s=x^y^cin;
assign cout = (x&y)|(y&cin)|(x&cin);
endmodule


