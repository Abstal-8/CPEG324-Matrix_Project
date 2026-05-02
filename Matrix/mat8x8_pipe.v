module mat8x8_pipe #( parameter mat_size = 64; ) (
    // Two flattened input arrays for our 8X8 matrix
    input clk,
    input rst,
    input start,
    input [(mat_size * 4)-1:0] arr1,
    input [(mat_size * 4)-1:0] arr2,
    output [(mat_size * 11)-1:0] mat,
    output done
    );

    reg [3:0] A [7:0][7:0];
    reg [3:0] B [7:0][7:0];


    // Step 1: Obtaining Row and Column values
    integer i, j;
    always @(posedge clk) begin 
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                for (j = 0; j < 8; j = j + 1) begin
                    A[i][j] = 4'b0000;
                    B[i][j] = 4'b0000;
                end
            end
            done <= 1'b0;
        end elsif (start) begin 
                for (i = 0; i < 8; i = i + 1) begin
                    for (j = 0; j < 8; j = j + 1) begin
                        A[i][j] = arr1[(i*8 + j)*4 +: 4];
                        B[i][j] = arr2[(i*8 + j)*4 +: 4];
                    end
                end
            end
    end



    // Flip Flop
    reg [4:0] curRowA [7:0];
    reg [4:0] curColB [7:0];
    wire curFilled;
    reg [2:0] rowCount;
    reg [2:0] colCount;
    // if the final value of the array has a value in it, then it must be full
    wire rowChange;
    wire colChange;



    integer k;
    if (rowChange) begin
        for (k = 0; k < 8; k = k + 1) begin
            curRowA[k] = A[rowCount][k];
        end
        rowChange <= 1'b0;
    end

    integer l;
    if (colChange) begin
        for (l = 0; l < 8; l = l + 1) begin
            curColB[l] = B[l][colCount];
        end
        colChange <= 1'b0;
    end



    // Step 2: Multiply
    // 8 multiplications in parallel
    reg [7:0] multiply_output [7:0];
    wire [7:0] multiply_done;

    wire multiRst;
    wire multiDone;
    assign multiDone = &multiply_done; 
    
    multiplier_4bit multiply1 (.clk(clk), .rst(multiRst), start(curFilled), .A(curRowA[0]), .B(curColB[0]), .P(multiply_output[0]), .done(multiply_done[0]));
    multiplier_4bit multiply2 (.clk(clk), .rst(multiRst), start(curFilled), .A(curRowA[1]), .B(curColB[1]), .P(multiply_output[1]), .done(multiply_done[1]));
    multiplier_4bit multiply3 (.clk(clk), .rst(multiRst), start(curFilled), .A(curRowA[2]), .B(curColB[2]), .P(multiply_output[2]), .done(multiply_done[2]));
    multiplier_4bit multiply4 (.clk(clk), .rst(multiRst), start(curFilled), .A(curRowA[3]), .B(curColB[3]), .P(multiply_output[3]), .done(multiply_done[3]));
    multiplier_4bit multiply5 (.clk(clk), .rst(multiRst), start(curFilled), .A(curRowA[4]), .B(curColB[4]), .P(multiply_output[4]), .done(multiply_done[4]));
    multiplier_4bit multiply6 (.clk(clk), .rst(multiRst), start(curFilled), .A(curRowA[5]), .B(curColB[5]), .P(multiply_output[5]), .done(multiply_done[5]));
    multiplier_4bit multiply7 (.clk(clk), .rst(multiRst), start(curFilled), .A(curRowA[6]), .B(curColB[6]), .P(multiply_output[6]), .done(multiply_done[6]));
    multiplier_4bit multiply8 (.clk(clk), .rst(multiRst), start(curFilled), .A(curRowA[7]), .B(curColB[7]), .P(multiply_output[7]), .done(multiply_done[7]));

    always @(posedge clk) begin 
        if (multiDone) begin 
            curFilled <= 1'b0;
        end
    end

    // Step 3: Add
    // --- Level 1 Wires & Registers ---
    wire [6:0] adder_done;

    wire adderRst;
    wire adderDone;
    assign adderDone = &adder_done;

    wire [8:0] s1_0w, s1_1w, s1_2w, s1_3w;
    reg  [8:0] s1_0, s1_1, s1_2, s1_3;

    full_adder_nbit #(8) add1_0 (.clk(clk), .rst(adderRst), .start(multiDone), .a(multiply_output[0]), .b(multiply_output[1]), .sum(s1_0w), .done(adder_done[0]));
    full_adder_nbit #(8) add1_1 (.clk(clk), .rst(adderRst), .start(multiDone), .a(multiply_output[2]), .b(multiply_output[3]), .sum(s1_1w), .done(adder_done[1]));
    full_adder_nbit #(8) add1_2 (.clk(clk), .rst(adderRst), .start(multiDone), .a(multiply_output[4]), .b(multiply_output[5]), .sum(s1_2w), .done(adder_done[2]));
    full_adder_nbit #(8) add1_3 (.clk(clk), .rst(adderRst), .start(multiDone), .a(multiply_output[6]), .b(multiply_output[7]), .sum(s1_3w), .done(adder_done[3]));

    // --- Level 2 Wires & Registers ---
    wire [9:0] s2_0w, s2_1w;
    reg  [9:0] s2_0, s2_1;

    full_adder_nbit #(9) add2_0 (.clk(clk), .rst(adderRst), .start(multiDone), .a(s1_0), .b(s1_1), .sum(s2_0w), .done(adder_done[4]));
    full_adder_nbit #(9) add2_1 (.clk(clk), .rst(adderRst), .start(multiDone), .a(s1_2), .b(s1_3), .sum(s2_1w), .done(adder_done[5]));

    // --- Level 3 Wire ---
    wire [10:0] add_rslt_w;
    full_adder_nbit #(10) add3_0 (.clk(clk), .rst(adderRst), .start(multiDone), .a(s2_0), .b(s2_1), .sum(add_rslt_w), .done(adder_done[6]));
    
    always @(posedge clk) begin 
        if (adderRst) begin
            s1_0 <= 9'b0;
            s1_1 <= 9'b0;
        end else if (adder_done[0] && adder_done[1]) begin
        // Only capture s1_0w and s1_1w when Level 1 is done
            s1_0 <= s1_0w;
            s1_1 <= s1_1w;
        end
    end

    always @(posedge clk) begin 
        if (adderRst) begin
            s2_0 <= 10'b0;
            s2_1 <= 10'b0;
        end else if (adder_done[4] && adder_done[5]) begin
        // Capture Level 2 results once add2_0 and add2_1 are done
            s2_0 <= s2_0w;
            s2_1 <= s2_1w;
        end
    end


    
    // Step 4: Insert final result
    reg [10:0] matrix_output;
    assign matrix_output = add_rslt_w;
    
    reg [5:0] matCount;
    always @(posedge clk) begin 
        if (adderDone && !(matCount == 6'd63)) begin
          matCount <= matCount + 1;
          adderRst <= 1'b1;
        end else begin
          done <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if (adderDone && !(matCount == 6'd63)) begin 
            mat[matCount * 11 +: 11] <= matrix_output;
        end
    end

endmodule