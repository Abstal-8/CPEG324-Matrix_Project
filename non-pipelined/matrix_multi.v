module iterative_matrix_reg_mult (
    input clk,
    input reset,
    input start,
    output reg done,
    
    input [3:0] load_addr,
    input [7:0] load_data_a,
    input [7:0] load_data_b,
    input load_en,
    
    input [3:0] read_addr,
    output [15:0] result_out
);

    reg [7:0] matrix_a [15:0];
    reg [7:0] matrix_b [15:0];
    reg [15:0] matrix_c [15:0];

    // Indices and State
    reg [2:0] i, j, k; 
    reg [2:0] state;
    
    localparam IDLE   = 3'd0;
    localparam CLEAR  = 3'd1; 
    localparam ACCUM  = 3'd2;
    localparam STEP   = 3'd3;
    localparam WRITE  = 3'd4;
    localparam FINISH = 3'd5;

    // MAC Signals
    reg mac_clear, mac_en;
    wire [15:0] mac_result;
    reg [7:0] op_a, op_b;

    mac_worker worker (
        .clk(clk), .reset(reset), .en(mac_en), .clear(mac_clear),
        .ain(op_a), .bin(op_b), .accum_out(mac_result)
    );

    assign result_out = matrix_c[read_addr];
    
    integer idx;
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            done <= 1'b0;
            i <= 3'd0; j <= 3'd0; k <= 3'd0;
            mac_en <= 1'b0;
            mac_clear <= 1'b0;
            for (idx = 0; idx < 16; idx = idx + 1) matrix_c[idx] <= 16'h0;
        end else if (load_en) begin
            matrix_a[load_addr] <= load_data_a;
            matrix_b[load_addr] <= load_data_b;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= CLEAR;
                        i <= 3'd0; j <= 3'd0; k <= 3'd0;
                    end
                end

                CLEAR: begin
                    mac_clear <= 1'b1;
                    mac_en <= 1'b0;
                    state <= ACCUM;
                end

                ACCUM: begin
                    mac_clear <= 1'b0;
                    op_a <= matrix_a[{i[1:0], k[1:0]}]; 
                    op_b <= matrix_b[{k[1:0], j[1:0]}];
                    mac_en <= 1'b1;
                    state <= STEP;
                end

                STEP: begin
                    mac_en <= 1'b0;
                    if (k == 3'd3) state <= WRITE;
                    else begin
                        k <= k + 3'd1;
                        state <= ACCUM;
                    end
                end

                WRITE: begin
                    matrix_c[{i[1:0], j[1:0]}] <= mac_result;
                    k <= 3'd0;
                    if (j == 3'd3) begin
                        j <= 3'd0;
                        if (i == 3'd3) begin
                            state <= FINISH;
                        end else begin
                            i <= i + 3'd1;
                            state <= CLEAR;
                        end
                    end else begin
                        j <= j + 3'd1;
                        state <= CLEAR;
                    end
                end

                FINISH: begin
                    done <= 1'b1;
                    if (!start) state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
