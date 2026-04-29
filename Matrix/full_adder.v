// Full Adder Module
module full_adder(input a, b, cin, output sum, cout);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module full_adder_8bit
(
    input [7:0] A,
    input [7:0] B,
    input CIN,
    output [7:0] SUM,
    output COUT
);

    wire [6:0] c; // Internal carry wires

    full_adder fa0 (A[0], B[0], CIN,  SUM[0], c[0]);
    full_adder fa1 (A[1], B[1], c[0], SUM[1], c[1]);
    full_adder fa2 (A[2], B[2], c[1], SUM[2], c[2]);
    full_adder fa3 (A[3], B[3], c[2], SUM[3], c[3]);
    full_adder fa4 (A[4], B[4], c[3], SUM[4], c[4]);
    full_adder fa5 (A[5], B[5], c[4], SUM[5], c[5]);
    full_adder fa6 (A[6], B[6], c[5], SUM[6], c[6]);
    full_adder fa7 (A[7], B[7], c[6], SUM[7], COUT);
    
endmodule
