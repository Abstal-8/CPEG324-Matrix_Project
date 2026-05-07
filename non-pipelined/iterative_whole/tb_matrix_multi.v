module tb_matrix_multi;

    reg clk;
    reg reset;
    reg start;
    reg [511:0] A;
    reg [511:0] B;
    
    wire [1023:0] C;
    wire done;

    integer r, c;
    reg test_passed;

    matrix_multi dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .done(done)
    );

    always #5 clk = ~clk;

    // --- HELPER TASKS FOR PRINTING MATRICES ---
    task print_matrix_8;
        input [511:0] mat;
        integer row, col;
        reg [7:0] val;
        begin
            for (row = 0; row < 8; row = row + 1) begin
                $write("    ");
                for (col = 0; col < 8; col = col + 1) begin
                    val = mat[(row * 8 + col) * 8 +: 8];
                    $write("%4d ", val);
                end
                $display("");
            end
        end
    endtask

    task print_matrix_16;
        input [1023:0] mat;
        integer row, col;
        reg [15:0] val;
        begin
            for (row = 0; row < 8; row = row + 1) begin
                $write("    ");
                for (col = 0; col < 8; col = col + 1) begin
                    val = mat[(row * 8 + col) * 16 +: 16];
                    $write("%6d ", val);
                end
                $display("");
            end
        end
    endtask

    // --- HELPER TASKS FOR LOADING MATRICES ---
    task load_identity;
        output reg [511:0] mat;
        integer row, col;
        begin
            mat = 512'd0;
            for (row = 0; row < 8; row = row + 1) begin
                for (col = 0; col < 8; col = col + 1) begin
                    if (row == col)
                        mat[(row * 8 + col) * 8 +: 8] = 8'd1;
                end
            end
        end
    endtask

    task load_ones;
        output reg [511:0] mat;
        integer row, col;
        begin
            mat = 512'd0;
            for (row = 0; row < 8; row = row + 1) begin
                for (col = 0; col < 8; col = col + 1) begin
                    mat[(row * 8 + col) * 8 +: 8] = 8'd1;
                end
            end
        end
    endtask
    
    task load_random;
        output reg [511:0] mat;
        integer row, col;
        begin
            mat = 512'd0;
            for (row = 0; row < 8; row = row + 1) begin
                for (col = 0; col < 8; col = col + 1) begin
                    // Mask with 8'h1F to keep numbers small enough to avoid 16-bit overflow
                    mat[(row * 8 + col) * 8 +: 8] = $random & 8'h1F; 
                end
            end
        end
    endtask

    // --- DYNAMIC CHECKER (SIMPLIFIED WITH '*') ---
    task check_result;
        input [511:0] matA;
        input [511:0] matB;
        input [1023:0] matC_dut;
        integer row, col, k;
        reg [7:0] valA, valB;
        reg [15:0] expected_dot_prod;
        reg [15:0] actual_val;
        begin
            test_passed = 1;
            for (row = 0; row < 8; row = row + 1) begin
                for (col = 0; col < 8; col = col + 1) begin
                    expected_dot_prod = 16'd0;
                    
                    // Standard matrix multiplication logic
                    for (k = 0; k < 8; k = k + 1) begin
                        valA = matA[(row * 8 + k) * 8 +: 8];
                        valB = matB[(k * 8 + col) * 8 +: 8];
                        expected_dot_prod = expected_dot_prod + (valA * valB);
                    end
                    
                    actual_val = matC_dut[(row * 8 + col) * 16 +: 16];
                    if (actual_val != expected_dot_prod) begin
                        $display("      [FAIL] Mismatch at [%0d][%0d]: Expected %0d, Got %0d", row, col, expected_dot_prod, actual_val);
                        test_passed = 0;
                    end
                end
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        A = 512'd0;
        B = 512'd0;
        
        #20 reset = 0;
        #10;

        // ==========================================
        // TEST 1: Identity x Identity
        // ==========================================
        $display("\n========================================");
        $display("Starting Test 1: Identity x Identity");
        load_identity(A);
        load_identity(B);
        
        start = 1; #10 start = 0;
        wait(done); #10;
        
        check_result(A, B, C);
        if (test_passed) $display("--> Test 1 Passed!"); else $display("--> Test 1 Failed!");

        // ==========================================
        // TEST 2: Ones x Ones
        // ==========================================
        $display("\n========================================");
        $display("Starting Test 2: Ones x Ones");
        load_ones(A);
        load_ones(B);
        
        start = 1; #10 start = 0;
        wait(done); #10;

        check_result(A, B, C);
        if (test_passed) $display("--> Test 2 Passed!"); else $display("--> Test 2 Failed!");

        // ==========================================
        // TEST 3: Ones x Identity
        // ==========================================
        $display("\n========================================");
        $display("Starting Test 3: Ones x Identity");
        load_ones(A);
        load_identity(B);
        
        start = 1; #10 start = 0;
        wait(done); #10;

        check_result(A, B, C);
        if (test_passed) $display("--> Test 3 Passed!"); else $display("--> Test 3 Failed!");

        // ==========================================
        // TEST 4: RANDOM STRESS TEST
        // ==========================================
        $display("\n========================================");
        $display("Starting Test 4: Random Data Stress Test");
        load_random(A);
        load_random(B);
        
        $display("\nInput Matrix A:");
        print_matrix_8(A);
        
        $display("\nInput Matrix B:");
        print_matrix_8(B);

        start = 1; #10 start = 0;
        wait(done); #10;

        $display("\nOutput Matrix C (Result):");
        print_matrix_16(C);

        check_result(A, B, C);
        if (test_passed) $display("\n--> Test 4 Passed! Random data matches expected."); 
        else $display("\n--> Test 4 Failed! Hardware output mismatched testbench calculation.");
        $display("========================================\n");

        $display("Simulation Complete.");
        $finish;
    end

endmodule
