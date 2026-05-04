module half_adder (
    input  a, b,
    output sum, carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule

module full_adder (
    input  a, b, cin,
    output sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module CombinationalMultiplier (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] C
);
    // Partial product bits: pp[row][column]
    wire [7:0] pp [7:0];
    genvar r, c;
    generate
        for (r = 0; r < 8; r = r + 1) begin : gen_rows
            for (c = 0; c < 8; c = c + 1) begin : gen_cols
                assign pp[r][c] = A[c] & B[r];
            end
        end
    endgenerate

    // Intermediate Sums and Carries
    // s[row][column], cy[row][column]
    wire [7:0] s [7:0];
    wire [7:0] cy [7:0];

    // --- ROW 0 ---
    // The first row is just the first partial product
    assign C[0] = pp[0][0];
    assign s[0] = pp[0]; // Passing pp[0][7:1] to next row

    // --- ROW 1 ---
    half_adder ha1_0 (pp[1][0], s[0][1],  s[1][0], cy[1][0]);
    full_adder fa1_1 (pp[1][1], s[0][2], cy[1][0], s[1][1], cy[1][1]);
    full_adder fa1_2 (pp[1][2], s[0][3], cy[1][1], s[1][2], cy[1][2]);
    full_adder fa1_3 (pp[1][3], s[0][4], cy[1][2], s[1][3], cy[1][3]);
    full_adder fa1_4 (pp[1][4], s[0][5], cy[1][3], s[1][4], cy[1][4]);
    full_adder fa1_5 (pp[1][5], s[0][6], cy[1][4], s[1][5], cy[1][5]);
    full_adder fa1_6 (pp[1][6], s[0][7], cy[1][5], s[1][6], cy[1][6]);
    half_adder ha1_7 (pp[1][7], cy[1][6], s[1][7], cy[1][7]);
    assign C[1] = s[1][0];

    // --- ROW 2 ---
    half_adder ha2_0 (pp[2][0], s[1][1],  s[2][0], cy[2][0]);
    full_adder fa2_1 (pp[2][1], s[1][2], cy[2][0], s[2][1], cy[2][1]);
    full_adder fa2_2 (pp[2][2], s[1][3], cy[2][1], s[2][2], cy[2][2]);
    full_adder fa2_3 (pp[2][3], s[1][4], cy[2][2], s[2][3], cy[2][3]);
    full_adder fa2_4 (pp[2][4], s[1][5], cy[2][3], s[2][4], cy[2][4]);
    full_adder fa2_5 (pp[2][5], s[1][6], cy[2][4], s[2][5], cy[2][5]);
    full_adder fa2_6 (pp[2][6], s[1][7], cy[2][5], s[2][6], cy[2][6]);
    full_adder fa2_7 (pp[2][7], cy[1][7], cy[2][6], s[2][7], cy[2][7]);
    assign C[2] = s[2][0];

    // --- ROW 3 ---
    half_adder ha3_0 (pp[3][0], s[2][1],  s[3][0], cy[3][0]);
    full_adder fa3_1 (pp[3][1], s[2][2], cy[3][0], s[3][1], cy[3][1]);
    full_adder fa3_2 (pp[3][2], s[2][3], cy[3][1], s[3][2], cy[3][2]);
    full_adder fa3_3 (pp[3][3], s[2][4], cy[3][2], s[3][3], cy[3][3]);
    full_adder fa3_4 (pp[3][4], s[2][5], cy[3][3], s[3][4], cy[3][4]);
    full_adder fa3_5 (pp[3][5], s[2][6], cy[3][4], s[3][5], cy[3][5]);
    full_adder fa3_6 (pp[3][6], s[2][7], cy[3][5], s[3][6], cy[3][6]);
    full_adder fa3_7 (pp[3][7], cy[2][7], cy[3][6], s[3][7], cy[3][7]);
    assign C[3] = s[3][0];

    // --- ROW 4 ---
    half_adder ha4_0 (pp[4][0], s[3][1],  s[4][0], cy[4][0]);
    full_adder fa4_1 (pp[4][1], s[3][2], cy[4][0], s[4][1], cy[4][1]);
    full_adder fa4_2 (pp[4][2], s[3][3], cy[4][1], s[4][2], cy[4][2]);
    full_adder fa4_3 (pp[4][3], s[3][4], cy[4][2], s[4][3], cy[4][3]);
    full_adder fa4_4 (pp[4][4], s[3][5], cy[4][3], s[4][4], cy[4][4]);
    full_adder fa4_5 (pp[4][5], s[3][6], cy[4][4], s[4][5], cy[4][5]);
    full_adder fa4_6 (pp[4][6], s[3][7], cy[4][5], s[4][6], cy[4][6]);
    full_adder fa4_7 (pp[4][7], cy[3][7], cy[4][6], s[4][7], cy[4][7]);
    assign C[4] = s[4][0];

    // --- ROW 5 ---
    half_adder ha5_0 (pp[5][0], s[4][1],  s[5][0], cy[5][0]);
    full_adder fa5_1 (pp[5][1], s[4][2], cy[5][0], s[5][1], cy[5][1]);
    full_adder fa5_2 (pp[5][2], s[4][3], cy[5][1], s[5][2], cy[5][2]);
    full_adder fa5_3 (pp[5][3], s[4][4], cy[5][2], s[5][3], cy[5][3]);
    full_adder fa5_4 (pp[5][4], s[4][5], cy[5][3], s[5][4], cy[5][4]);
    full_adder fa5_5 (pp[5][5], s[4][6], cy[5][4], s[5][5], cy[5][5]);
    full_adder fa5_6 (pp[5][6], s[4][7], cy[5][5], s[5][6], cy[5][6]);
    full_adder fa5_7 (pp[5][7], cy[4][7], cy[5][6], s[5][7], cy[5][7]);
    assign C[5] = s[5][0];

    // --- ROW 6 ---
    half_adder ha6_0 (pp[6][0], s[5][1],  s[6][0], cy[6][0]);
    full_adder fa6_1 (pp[6][1], s[5][2], cy[6][0], s[6][1], cy[6][1]);
    full_adder fa6_2 (pp[6][2], s[5][3], cy[6][1], s[6][2], cy[6][2]);
    full_adder fa6_3 (pp[6][3], s[5][4], cy[6][2], s[6][3], cy[6][3]);
    full_adder fa6_4 (pp[6][4], s[5][5], cy[6][3], s[6][4], cy[6][4]);
    full_adder fa6_5 (pp[6][5], s[5][6], cy[6][4], s[6][5], cy[6][5]);
    full_adder fa6_6 (pp[6][6], s[5][7], cy[6][5], s[6][6], cy[6][6]);
    full_adder fa6_7 (pp[6][7], cy[5][7], cy[6][6], s[6][7], cy[6][7]);
    assign C[6] = s[6][0];

    // --- ROW 7 ---
    half_adder ha7_0 (pp[7][0], s[6][1],  s[7][0], cy[7][0]);
    full_adder fa7_1 (pp[7][1], s[6][2], cy[7][0], s[7][1], cy[7][1]);
    full_adder fa7_2 (pp[7][2], s[6][3], cy[7][1], s[7][2], cy[7][2]);
    full_adder fa7_3 (pp[7][3], s[6][4], cy[7][2], s[7][3], cy[7][3]);
    full_adder fa7_4 (pp[7][4], s[6][5], cy[7][3], s[7][4], cy[7][4]);
    full_adder fa7_5 (pp[7][5], s[6][6], cy[7][4], s[7][5], cy[7][5]);
    full_adder fa7_6 (pp[7][6], s[6][7], cy[7][5], s[7][6], cy[7][6]);
    full_adder fa7_7 (pp[7][7], cy[6][7], cy[7][6], s[7][7], cy[7][7]);
    assign C[7] = s[7][0];

    // --- FINAL STAGE (CARRY PROPAGATION) ---
    assign C[8]  = s[7][1];
    assign C[9]  = s[7][2];
    assign C[10] = s[7][3];
    assign C[11] = s[7][4];
    assign C[12] = s[7][5];
    assign C[13] = s[7][6];
    assign C[14] = s[7][7];
    assign C[15] = cy[7][7];

endmodule
