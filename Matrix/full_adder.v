// Full Adder Module
module full_adder(input a, b, cin, output sum, cout);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module full_adder_nbit #(
    parameter N = 8
)(
    input clk,
    input rst,
    input  [N-1:0] a,
    input  [N-1:0] b,
    output reg [N:0] sum, // Output is one bit wider (N bits + 1 carry bit)
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
        end else begin
            sum  <= sum_comb; 
        end
    end


endmodule