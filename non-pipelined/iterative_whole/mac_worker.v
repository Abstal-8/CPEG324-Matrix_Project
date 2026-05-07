module mac_worker (
    input clk,		    // Clock Signal for the MAC
    input reset,	    // Reset the MAC
    input en,               // Enable the MAC operation
    input clear,            // Clear the accumulator for a new dot product
    input [7:0] ain,        // Value from Matrix A
    input [7:0] bin,        // Value from Matrix B
    output [15:0] accum_out // Current accumulated total
);

    wire [15:0] product;
    reg [15:0] accumulator;
 
    CombinationalMultiplier multiplier_inst (
        .A(ain),
        .B(bin),
        .C(product)
    );

    always @(posedge clk) begin
        if (reset || clear) begin
            accumulator <= 16'h0000;
        end else if (en) begin
            // Non-pipelined: One addition per clock cycle
            accumulator <= accumulator + product;
        end
    end

    assign accum_out = accumulator;

endmodule
