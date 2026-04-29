module dff (
    input clk,
    input rst,
    input [3:0] d,
    output reg [3:0] q
);
    
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            q <= 4'b0000;
        end else begin
            q <= d;
        end
    end
endmodule