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
    reg [7:0] multiply_out;
    
    multiplier_4bit multiply (
    .A(currentA), 
    .B(currentB), 
    .P(multiply_out)
    );

    // Flip Flop



    // Step 3: Add
    // 8 additions in parallel
    full_adder_8bit add_after_multiply
    (
        .A(),
        .B(),
        .CIN(),
        .SUM(),
        .COUT()
    );

    // Flip Flop

    // Step 4: Insert final result







endmodule