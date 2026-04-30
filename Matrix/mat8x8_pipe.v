module mat8x8_pipe #( parameter mat_size = 64; ) (
    // Two flattened input arrays for our 8X8 matrix
    input clk,
    input rst,
    input [(mat_size * 4)-1:0] arr1,
    input [(mat_size * 4)-1:0] arr2,
    output [(mat_size * 8)-1:0] mat 
    );

    reg [3:0] A [7:0][7:0];
    reg [3:0] B [7:0][7:0];

    wire rowChange;
    wire colChange;


    // Step 1: Obtaining Row and Column values
    integer i, j;
    for (i = 0; i < 8; i = i + 1) begin
        for (j = 0; j < 8; j = j + 1) begin
            A[i][j] = arr1[(i*8 + j)*4 +: 4];
            B[i][j] = arr2[(i*8 + j)*4 +: 4];
        end
    end


    // Flip Flop
    reg [4:0] curRowA [7:0];
    reg [4:0] curColB [7:0];

    integer r, k;
    if (rowChange) begin
        r = r + 1;
        for (k = 0; k < 8; k = k + 1) begin
            curRowA[k] = A[r][k];
        end
        rowChange <= 1'b0;
    end

    integer c, l;
    if (colChange) begin
        c = c + 1;
        for (l = 0; l < 8; l = l + 1) begin
            curColB[l] = B[l][c];
        end
        colChange <= 1'b0;
    end



    // Step 2: Multiply
    // 8 multiplications in parallel
    reg [7:0] multiply_output [7:0];
    
    multiplier_4bit multiply1 (.A(curRowA[0]), .B(curColB[0]), .P(multiply_output[0]));
    multiplier_4bit multiply2 (.A(curRowA[1]), .B(curColB[1]), .P(multiply_output[1]));
    multiplier_4bit multiply3 (.A(curRowA[2]), .B(curColB[2]), .P(multiply_output[2]));
    multiplier_4bit multiply4 (.A(curRowA[3]), .B(curColB[3]), .P(multiply_output[3]));
    multiplier_4bit multiply5 (.A(curRowA[4]), .B(curColB[4]), .P(multiply_output[4]));
    multiplier_4bit multiply6 (.A(curRowA[5]), .B(curColB[5]), .P(multiply_output[5]));
    multiplier_4bit multiply7 (.A(curRowA[6]), .B(curColB[6]), .P(multiply_output[6]));
    multiplier_4bit multiply8 (.A(curRowA[7]), .B(curColB[7]), .P(multiply_output[7]));


    // Step 3: Add
    // 8 additions in parallel
    // --- Level 1 Wires & Registers ---
    wire [8:0] s1_0w, s1_1w, s1_2w, s1_3w;
    reg  [8:0] s1_0, s1_1, s1_2, s1_3;

    full_adder_nbit #(8) add1_0 (multiply_output[0], multiply_output[1], s1_0w);
    full_adder_nbit #(8) add1_1 (multiply_output[2], multiply_output[3], s1_1w);
    full_adder_nbit #(8) add1_2 (multiply_output[4], multiply_output[5], s1_2w);
    full_adder_nbit #(8) add1_3 (multiply_output[6], multiply_output[7], s1_3w);

    // --- Level 2 Wires & Registers ---
    wire [9:0] s2_0w, s2_1w;
    reg  [9:0] s2_0, s2_1;

    full_adder_nbit #(9) add2_0 (s1_0, s1_1, s2_0w);
    full_adder_nbit #(9) add2_1 (s1_2, s1_3, s2_1w);

    // --- Level 3 Wire ---
    wire [10:0] s3_final_w;

    full_adder_nbit #(10) add3_0 (s2_0, s2_1, s3_final_w);
    

    // s3_final will go to matrix output
    reg [10:0] matrix_output;
    
    // Step 4: Insert final result







endmodule