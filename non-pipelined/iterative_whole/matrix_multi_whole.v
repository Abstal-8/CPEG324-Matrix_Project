module matrix_multi (
    input clk,
    input reset,
    input start,
    input [511:0] A,
    input [511:0] B,
    output reg [1023:0] C,
    output reg done
);

    reg [2:0] state;
    reg [2:0] r;
    reg [2:0] c;
    reg [2:0] k;

    wire [8:0] a_off = {r, k, 3'b000};
    wire [8:0] b_off = {k, c, 3'b000};
    wire [9:0] c_off = {r, c, 4'b0000};

    wire [7:0] ain = A[a_off +: 8];
    wire [7:0] bin = B[b_off +: 8];
    wire [15:0] accum_out;

    wire mac_clear = (state == 3'd1); 
    wire mac_en    = (state == 3'd2); 

    mac_worker mac_inst (
        .clk(clk),
        .reset(reset),
        .en(mac_en),
        .clear(mac_clear),
        .ain(ain),
        .bin(bin),
        .accum_out(accum_out)
    );

    localparam STATE_IDLE  = 3'd0;
    localparam STATE_CLEAR = 3'd1;
    localparam STATE_CALC  = 3'd2;
    localparam STATE_SAVE  = 3'd3;
    localparam STATE_DONE  = 3'd4;

    always @(posedge clk) begin
        if (reset) begin
            state <= STATE_IDLE;
            r     <= 3'd0;
            c     <= 3'd0;
            k     <= 3'd0;
            C     <= 1024'd0;
            done  <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    done <= 1'b0;
                    r    <= 3'd0;
                    c    <= 3'd0;
                    if (start) state <= STATE_CLEAR;
                end

                STATE_CLEAR: begin
                    k     <= 3'd0;
                    state <= STATE_CALC;
                end

                STATE_CALC: begin
                    k <= k + 1'b1;
                    if (k == 3'd7) begin
                        state <= STATE_SAVE;
                    end
                end

                STATE_SAVE: begin
                    C[c_off +: 16] <= accum_out;
                    
                    if (c == 3'd7) begin
                        c <= 3'd0;
                        if (r == 3'd7) begin
                            state <= STATE_DONE;
                        end else begin
                            r     <= r + 1'b1;
                            state <= STATE_CLEAR;
                        end
                    end else begin
                        c     <= c + 1'b1;
                        state <= STATE_CLEAR;
                    end
                end

                STATE_DONE: begin
                    done  <= 1'b1;
                    state <= STATE_IDLE;
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
