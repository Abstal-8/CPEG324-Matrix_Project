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


module full_adder_nbit #(
    parameter N = 8
)(
    input clk,
    input rst,
    input start,
    input  [N-1:0] a,
    input  [N-1:0] b,
    output reg [N:0] sum, // Output is one bit wider (N bits + 1 carry bit)
    output reg done
);
    // Wire to hold carry signals between full adders
    // carry[0] is the external Cin (0), carry[N] is the final Cout
    wire [N:0] sum_comb;
    wire [N:0] carry;
    assign carry[0] = 1'b0; // No carry-in for the first stage

    // Instantiate N full adders using a generate loop
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : fa_block
            full_adder fa_inst (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum_comb[i]),      // Current bit of the sum
                .cout(carry[i+1])  // Carry to the next bit
            );
        end
    endgenerate

    // The (N+1)th bit of the sum is the final carry-out
    assign sum_comb[N] = carry[N];

    always @(posedge clk) begin
        if (rst) begin
            sum  <= 0;
            done <= 1'b0;
        end else begin
            sum  <= sum_comb; 
            done <= start;
        end
    end


endmodule
