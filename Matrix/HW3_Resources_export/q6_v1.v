module q6_v1 (
    input  wire [7:0] data_in,
    input  wire [2:0] shamt,
    input  wire       c_in,
    input  wire [1:0] op,
    output reg  [7:0] data_out,
    output reg        c_out
);

    always @(*) begin
        // Default assignments to prevent latches
        data_out = data_in;
        c_out    = c_in;

        case (op)
            2'b00: begin // ROL (Rotate Left - 8 bit)
                case (shamt)
                    3'd0: begin data_out = data_in; c_out = c_in; end
                    3'd1: begin data_out = {data_in[6:0], data_in[7]};   c_out = data_in[7]; end
                    3'd2: begin data_out = {data_in[5:0], data_in[7:6]}; c_out = data_in[6]; end
                    3'd3: begin data_out = {data_in[4:0], data_in[7:5]}; c_out = data_in[5]; end
                    3'd4: begin data_out = {data_in[3:0], data_in[7:4]}; c_out = data_in[4]; end
                    3'd5: begin data_out = {data_in[2:0], data_in[7:3]}; c_out = data_in[3]; end
                    3'd6: begin data_out = {data_in[1:0], data_in[7:2]}; c_out = data_in[2]; end
                    3'd7: begin data_out = {data_in[0],   data_in[7:1]}; c_out = data_in[1]; end
                endcase
            end

            2'b01: begin // ROR (Rotate Right - 8 bit)
                case (shamt)
                    3'd0: begin data_out = data_in; c_out = c_in; end
                    3'd1: begin data_out = {data_in[0],   data_in[7:1]}; c_out = data_in[0]; end
                    3'd2: begin data_out = {data_in[1:0], data_in[7:2]}; c_out = data_in[1]; end
                    3'd3: begin data_out = {data_in[2:0], data_in[7:3]}; c_out = data_in[2]; end
                    3'd4: begin data_out = {data_in[3:0], data_in[7:4]}; c_out = data_in[3]; end
                    3'd5: begin data_out = {data_in[4:0], data_in[7:5]}; c_out = data_in[4]; end
                    3'd6: begin data_out = {data_in[5:0], data_in[7:6]}; c_out = data_in[5]; end
                    3'd7: begin data_out = {data_in[6:0], data_in[7]};   c_out = data_in[6]; end
                endcase
            end

            2'b10: begin // RLC (Rotate Left through Carry - 9 bit)
                // Slide definition: 9-bit vector is {data_in, c_in}
                // Upper 8 bits go to data_out, LSB goes to c_out
                case (shamt)
                    3'd0: begin data_out = data_in;                                 c_out = c_in;       end
                    3'd1: begin data_out = {data_in[6:0], c_in};                    c_out = data_in[7]; end
                    3'd2: begin data_out = {data_in[5:0], c_in, data_in[7]};        c_out = data_in[6]; end
                    3'd3: begin data_out = {data_in[4:0], c_in, data_in[7:6]};      c_out = data_in[5]; end
                    3'd4: begin data_out = {data_in[3:0], c_in, data_in[7:5]};      c_out = data_in[4]; end
                    3'd5: begin data_out = {data_in[2:0], c_in, data_in[7:4]};      c_out = data_in[3]; end
                    3'd6: begin data_out = {data_in[1:0], c_in, data_in[7:3]};      c_out = data_in[2]; end
                    3'd7: begin data_out = {data_in[0],   c_in, data_in[7:2]};      c_out = data_in[1]; end
                endcase
            end

            2'b11: begin // RRC (Rotate Right through Carry - 9 bit)
                // Slide definition: 9-bit vector is {data_in, c_in}
                case (shamt)
                    3'd0: begin data_out = data_in;                                 c_out = c_in;       end
                    3'd1: begin data_out = {c_in, data_in[7:1]};                    c_out = data_in[0]; end
                    3'd2: begin data_out = {data_in[0],   c_in, data_in[7:2]};      c_out = data_in[1]; end
                    3'd3: begin data_out = {data_in[1:0], c_in, data_in[7:3]};      c_out = data_in[2]; end
                    3'd4: begin data_out = {data_in[2:0], c_in, data_in[7:4]};      c_out = data_in[3]; end
                    3'd5: begin data_out = {data_in[3:0], c_in, data_in[7:5]};      c_out = data_in[4]; end
                    3'd6: begin data_out = {data_in[4:0], c_in, data_in[7:6]};      c_out = data_in[5]; end
                    3'd7: begin data_out = {data_in[5:0], c_in, data_in[7]};        c_out = data_in[6]; end
                endcase
            end
        endcase
    end
endmodule
