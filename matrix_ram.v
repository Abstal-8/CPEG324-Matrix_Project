module matrix_ram #(
    parameter ADDR_WIDTH = 4, // 16 locations
    parameter DATA_WIDTH = 8  // 8-bit numbers
)(
    input clk,
    input we,                        // Write Enable (1 to save data, 0 to read)
    input [ADDR_WIDTH-1:0] addr,     // Address in memory
    input [DATA_WIDTH-1:0] din,      // Data to be written
    output reg [DATA_WIDTH-1:0] dout // Data being read
);
    // The memory array
    reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];

    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= din; //read
        end
        dout <= ram[addr]; //write
    end
endmodule
