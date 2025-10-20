`timescale 1ns / 1ps



module addroundkey (
    input  wire [127:0] state,       // 4x4 byte = 128 bit AES state
    input  wire [127:0] round_key,   // 128 bit round key (from key schedule)
    output wire [127:0] new_state    // XOR sonucu: state ? round_key
);

    assign new_state = state ^ round_key;

endmodule

