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

module multiplier_8bit (
    input clk,
    input rst,
    input [7:0] A,     // Multiplicand
    input [7:0] B,     // Multiplier
    output reg [15:0] P, // Product (16-bit for 8x8)
);

    wire [15:0] P_rslt;
    wire [7:0] p [7:0];    // Partial products
    
    // Sums and Carries for 7 levels of addition
    wire [6:0] s1, s2, s3, s4, s5, s6; 
    wire [7:0] c1, c2, c3, c4, c5, c6, c7;

    // Step 1: Generate 8 Partial Products
    assign p[0] = A & {8{B[0]}};
    assign p[1] = A & {8{B[1]}};
    assign p[2] = A & {8{B[2]}};
    assign p[3] = A & {8{B[3]}};
    assign p[4] = A & {8{B[4]}};
    assign p[5] = A & {8{B[5]}};
    assign p[6] = A & {8{B[6]}};
    assign p[7] = A & {8{B[7]}};

    // Step 2: Summation Chain
    assign P_rslt[0] = p[0][0];

    // Row 1: p0 + p1
    half_adder ha1_0 (p[0][1], p[1][0], P_rslt[1], c1[0]);
    full_adder fa1_1 (p[0][2], p[1][1], c1[0], s1[0], c1[1]);
    full_adder fa1_2 (p[0][3], p[1][2], c1[1], s1[1], c1[2]);
    full_adder fa1_3 (p[0][4], p[1][3], c1[2], s1[2], c1[3]);
    full_adder fa1_4 (p[0][5], p[1][4], c1[3], s1[3], c1[4]);
    full_adder fa1_5 (p[0][6], p[1][5], c1[4], s1[4], c1[5]);
    full_adder fa1_6 (p[0][7], p[1][6], c1[5], s1[5], c1[6]);
    half_adder ha1_7 (p[1][7], c1[6], s1[6], c1[7]);

    // Row 2: s1 + p2
    half_adder ha2_0 (s1[0], p[2][0], P_rslt[2], c2[0]);
    full_adder fa2_1 (s1[1], p[2][1], c2[0], s2[0], c2[1]);
    full_adder fa2_2 (s1[2], p[2][2], c2[1], s2[1], c2[2]);
    full_adder fa2_3 (s1[3], p[2][3], c2[2], s2[2], c2[3]);
    full_adder fa2_4 (s1[4], p[2][4], c2[3], s2[3], c2[4]);
    full_adder fa2_5 (s1[5], p[2][5], c2[4], s2[4], c2[5]);
    full_adder fa2_6 (s1[6], p[2][6], c2[5], s2[5], c2[6]);
    full_adder fa2_7 (c1[7], p[2][7], c2[6], s2[6], c2[7]);

    // Row 3: s2 + p3
    half_adder ha3_0 (s2[0], p[3][0], P_rslt[3], c3[0]);
    full_adder fa3_1 (s2[1], p[3][1], c3[0], s3[0], c3[1]);
    full_adder fa3_2 (s2[2], p[3][2], c3[1], s3[1], c3[2]);
    full_adder fa3_3 (s2[3], p[3][3], c3[2], s3[2], c3[3]);
    full_adder fa3_4 (s2[4], p[3][4], c3[3], s3[3], c3[4]);
    full_adder fa3_5 (s2[5], p[3][5], c3[4], s3[4], c3[5]);
    full_adder fa3_6 (s2[6], p[3][6], c3[5], s3[5], c3[6]);
    full_adder fa3_7 (c2[7], p[3][7], c3[6], s3[6], c3[7]);

    // Row 4: s3 + p4
    half_adder ha4_0 (s3[0], p[4][0], P_rslt[4], c4[0]);
    full_adder fa4_1 (s3[1], p[4][1], c4[0], s4[0], c4[1]);
    full_adder fa4_2 (s3[2], p[4][2], c4[1], s4[1], c4[2]);
    full_adder fa4_3 (s3[3], p[4][3], c4[2], s4[2], c4[3]);
    full_adder fa4_4 (s3[4], p[4][4], c4[3], s4[3], c4[4]);
    full_adder fa4_5 (s3[5], p[4][5], c4[4], s4[4], c4[5]);
    full_adder fa4_6 (s3[6], p[4][6], c4[5], s4[5], c4[6]);
    full_adder fa4_7 (c3[7], p[4][7], c4[6], s4[6], c4[7]);

    // Row 5: s4 + p5
    half_adder ha5_0 (s4[0], p[5][0], P_rslt[5], c5[0]);
    full_adder fa5_1 (s4[1], p[5][1], c5[0], s5[0], c5[1]);
    full_adder fa5_2 (s4[2], p[5][2], c5[1], s5[1], c5[2]);
    full_adder fa5_3 (s4[3], p[5][3], c5[2], s5[2], c5[3]);
    full_adder fa5_4 (s4[4], p[5][4], c5[3], s5[3], c5[4]);
    full_adder fa5_5 (s4[5], p[5][5], c5[4], s5[4], c5[5]);
    full_adder fa5_6 (s4[6], p[5][6], c5[5], s5[5], c5[6]);
    full_adder fa5_7 (c4[7], p[5][7], c5[6], s5[6], c5[7]);

    // Row 6: s5 + p6
    half_adder ha6_0 (s5[0], p[6][0], P_rslt[6], c6[0]);
    full_adder fa6_1 (s5[1], p[6][1], c6[0], s6[0], c6[1]);
    full_adder fa6_2 (s5[2], p[6][2], c6[1], s6[1], c6[2]);
    full_adder fa6_3 (s5[3], p[6][3], c6[2], s6[2], c6[3]);
    full_adder fa6_4 (s5[4], p[6][4], c6[3], s6[3], c6[4]);
    full_adder fa6_5 (s5[5], p[6][5], c6[4], s6[4], c6[5]);
    full_adder fa6_6 (s5[6], p[6][6], c6[5], s6[5], c6[6]);
    full_adder fa6_7 (c5[7], p[6][7], c6[6], s6[6], c6[7]);

    // Row 7 (Final Row): s6 + p7
    half_adder ha7_0 (s6[0], p[7][0], P_rslt[7], c7[0]);
    full_adder fa7_1 (s6[1], p[7][1], c7[0], P_rslt[8],  c7[1]);
    full_adder fa7_2 (s6[2], p[7][2], c7[1], P_rslt[9],  c7[2]);
    full_adder fa7_3 (s6[3], p[7][3], c7[2], P_rslt[10], c7[3]);
    full_adder fa7_4 (s6[4], p[7][4], c7[3], P_rslt[11], c7[4]);
    full_adder fa7_5 (s6[5], p[7][5], c7[4], P_rslt[12], c7[5]);
    full_adder fa7_6 (s6[6], p[7][6], c7[5], P_rslt[13], c7[6]);
    full_adder fa7_7 (c6[7], p[7][7], c7[6], P_rslt[14], P_rslt[15]);

    // Sequential Output Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            P <= 16'b0;
        end else begin
            P <= P_rslt;
        end
    end
endmodule