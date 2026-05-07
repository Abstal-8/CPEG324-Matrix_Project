module matrix_multi (
    input clk,
    input reset,
    input start,
    input [511:0] A,
    input [511:0] B,
    output reg [1023:0] C,
    output reg done
);

    wire [7:0] a_mat [0:7][0:7];
    wire [7:0] b_mat [0:7][0:7];
    wire [15:0] mac_outs [0:7][0:7];
    wire [1023:0] C_next;

    reg [1:0] state;
    reg [3:0] k;

    // Combinational control signals to fix the 1-cycle delay
    wire mac_clear = (state == 2'd0) && start; 
    wire mac_en    = (state == 2'd1);          

    localparam STATE_IDLE = 2'd0;
    localparam STATE_CALC = 2'd1;
    localparam STATE_DONE = 2'd2;

    genvar r, c;
    generate
        for (r = 0; r < 8; r = r + 1) begin : gen_r
            for (c = 0; c < 8; c = c + 1) begin : gen_c
                // Map flattened inputs (r << 6 == r * 64, c << 3 == c * 8)
                assign a_mat[r][c] = A[((r << 6) + (c << 3)) +: 8];
                assign b_mat[r][c] = B[((r << 6) + (c << 3)) +: 8];
                
                // Map to flattened output (r << 7 == r * 128, c << 4 == c * 16)
                assign C_next[((r << 7) + (c << 4)) +: 16] = mac_outs[r][c];

                mac_worker mac_inst (
                    .clk(clk),
                    .reset(reset),
                    .en(mac_en),
                    .clear(mac_clear),
                    .ain(a_mat[r][k]),
                    .bin(b_mat[k][c]),
                    .accum_out(mac_outs[r][c])
                );
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (reset) begin
            state <= STATE_IDLE;
            k     <= 4'd0;
            done  <= 1'b0;
            C     <= 1024'd0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    done <= 1'b0;
                    k    <= 4'd0;
                    if (start) begin
                        state <= STATE_CALC;
                    end
                end
                
                STATE_CALC: begin
                    k <= k + 1'b1;
                    if (k == 4'd7) begin
                        state <= STATE_DONE;
                    end
                end
                
                STATE_DONE: begin
                    C     <= C_next;
                    done  <= 1'b1;
                    state <= STATE_IDLE;
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
