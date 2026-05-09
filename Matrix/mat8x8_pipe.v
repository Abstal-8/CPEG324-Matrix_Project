module mat8x8_pipe #(parameter N = 64)(
    input clk,
    input rst,
    input start,

    input  [N*8-1:0] arr1,
    input  [N*8-1:0] arr2,

    output reg [N*19-1:0] mat,
    output reg done
);

    // ----------------------------
    // MEMORY
    // ----------------------------
    reg [7:0] A [0:7][0:7];
    reg [7:0] B [0:7][0:7];

    // ----------------------------
    // FSM
    // ----------------------------
    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state, next_state;

    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE: if (start) next_state = RUN;
            RUN:  if (matCount == 6'd64) next_state = DONE;
            DONE: next_state = DONE;
        endcase
    end

    wire compute_en = (state == RUN);

    // ----------------------------
    // LOAD INPUTS
    // ----------------------------
    integer i, j, k, q;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                for (j = 0; j < 8; j = j + 1) begin
                    A[i][j] <= 0;
                    B[i][j] <= 0;
                end
        end
        else if (state == IDLE && start) begin
            for (i = 0; i < 8; i = i + 1)
                for (j = 0; j < 8; j = j + 1) begin
                    A[i][j] <= arr1[(i*8 + j)*8 +: 8];
                    B[i][j] <= arr2[(i*8 + j)*8 +: 8];
                end
        end
    end

    // ----------------------------
    // INDEXING (KEY SIMPLIFICATION)
    // ----------------------------
    reg [5:0] matCount;

    wire [2:0] row = matCount[5:3];
    wire [2:0] col = matCount[2:0];

    // ----------------------------
    // ROW / COL SELECTION
    // ----------------------------
    reg [7:0] curRowA [0:7];
    reg [7:0] curColB [0:7];

    reg [7:0] curRowA_d [0:7];
    reg [7:0] curColB_d [0:7];

    always @(posedge clk) begin
        if (compute_en) begin
            for (k = 0; k < 8; k = k + 1) begin
                curRowA[k] <= A[row][k];
                curColB[k] <= B[k][col];
            end
        end
    end

    always @(posedge clk) begin
        if (compute_en) begin 
            for (q = 0; q < 8; q = q + 1) begin
                curRowA_d[q] <= curRowA[q];
                curColB_d[q] <= curColB[q];
            end
        end 
    end

    // ----------------------------
    // MULTIPLIER PIPELINE
    // ----------------------------

    reg [15:0] mult_out [0:7];
    reg [15:0] mult_out_aligned [0:7];

    always @(posedge clk) begin 
        for (i = 0; i < 8; i = i + 1)
            mult_out_aligned[i] <= mult_out[i];
    end

    genvar m;
    generate
        for (m = 0; m < 8; m = m + 1) begin : MUL
            multiplier_8bit u_mul (
                .clk(clk),
                .rst(rst),
                .A(curRowA_d[m]),
                .B(curColB_d[m]),
                .P(mult_out[m])
            );
        end
    endgenerate

    // ----------------------------
    // ADDER TREE
    // ----------------------------
    wire [18:0] result;
    reg [18:0] result_r;

    reg [16:0] w0_r, w1_r, w2_r, w3_r;
    wire [16:0] w0, w1, w2, w3;

    wire adder_done = (state == RUN);

    always @(posedge clk) begin 
        w0_r <= w0;
        w1_r <= w1;
        w2_r <= w2;
        w3_r <= w3;
    end

    full_adder_nbit #(16) a0 (.clk(clk), .rst(rst),
        .a(mult_out_aligned[0]), .b(mult_out_aligned[1]), .sum(w0));

    full_adder_nbit #(16) a1 (.clk(clk), .rst(rst),
        .a(mult_out_aligned[2]), .b(mult_out_aligned[3]), .sum(w1));

    full_adder_nbit #(16) a2 (.clk(clk), .rst(rst),
        .a(mult_out_aligned[4]), .b(mult_out_aligned[5]), .sum(w2));

    full_adder_nbit #(16) a3 (.clk(clk), .rst(rst),
        .a(mult_out_aligned[6]), .b(mult_out_aligned[7]), .sum(w3));


    wire [18:0] t0, t1;

    full_adder_nbit #(17) b0 (.clk(clk), .rst(rst),
        .a(w0_r), .b(w1_r), .sum(t0));

    full_adder_nbit #(17) b1 (.clk(clk), .rst(rst),
        .a(w2_r), .b(w3_r), .sum(t1));



    full_adder_nbit #(18) c0 (.clk(clk), .rst(rst),
        .a(t0), .b(t1), .sum(result));

    always @(posedge clk) begin
        result_r <= result;
    end

    // ----------------------------
    // OUTPUT CONTROL
    // ----------------------------
    always @(posedge clk) begin
        if (rst) begin
            matCount <= 0;
            done <= 0;
        end
        else if (state == RUN && adder_done) begin
            mat[matCount * 19 +: 19] <= result_r;
            matCount <= matCount + 1;
            done <= 1'b0;
        end
        else if (state == DONE) begin
            done <= 1'b1;
        end
        else if (state == IDLE && start) begin 
            matCount <= 0;
        end
    end

endmodule