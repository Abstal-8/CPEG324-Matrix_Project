// Full Adder Module
module full_adder(input a, b, cin, output sum, cout);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// Half Adder Module
module half_adder(input a, b, output sum, cout);
    assign sum = a ^ b;
    assign cout = a & b;
endmodule


module multiplier_4bit (
    input [3:0] A, // Multiplicand
    input [3:0] B, // Multiplier
    output [7:0] P // Product
);
    wire [3:0] p0, p1, p2, p3; // Partial products
    wire [2:0] s1, s2, s3;     // Sums between rows
    wire [3:0] c1, c2, c3;     // Carries between rows

    // Step 1: Generate Partial Products (AND gates)
    assign p0 = A & {4{B[0]}};
    assign p1 = A & {4{B[1]}};
    assign p2 = A & {4{B[2]}};
    assign p3 = A & {4{B[3]}};

    // Step 2: Summation Rows
    assign P[0] = p0[0];

    // Row 1 Addition (p0[3:1] + p1[2:0])
    half_adder ha1_0 (p0[1], p1[0], P[1], c1[0]);
    full_adder fa1_1 (p0[2], p1[1], c1[0], s1[0], c1[1]);
    full_adder fa1_2 (p0[3], p1[2], c1[1], s1[1], c1[2]);
    half_adder ha1_3 (p1[3], c1[2], s1[2], c1[3]);

    // Row 2 Addition (s1[2:0] + p2[3:0])
    half_adder ha2_0 (s1[0], p2[0], P[2], c2[0]);
    full_adder fa2_1 (s1[1], p2[1], c2[0], s2[0], c2[1]);
    full_adder fa2_2 (s1[2], p2[2], c2[1], s2[1], c2[2]); // Using carry from HA1_3/FA1_2
    full_adder fa2_3 (c1[3], p2[3], c2[2], s2[2], c2[3]);

    // Row 3 Addition (Final Row)
    half_adder ha3_0 (s2[0], p3[0], P[3], c3[0]);
    full_adder fa3_1 (s2[1], p3[1], c3[0], P[4], c3[1]);
    full_adder fa3_2 (s2[2], p3[2], c3[1], P[5], c3[2]);
    full_adder fa3_3 (c2[3], p3[3], c3[2], P[6], P[7]); // Carry out is P[7]

endmodule