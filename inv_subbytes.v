`timescale 1ns / 1ps
module inv_subbytes (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : invsbox_loop
            inv_sbox u_inv_sbox (
                .in(state_in[i*8 +: 8]),
                .out(state_out[i*8 +: 8])
            );
        end
    endgenerate

endmodule

