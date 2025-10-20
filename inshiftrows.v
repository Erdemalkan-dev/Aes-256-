`timescale 1ns / 1ps

module invshiftrows (
    input  wire [127:0] state_in,   // AES state in column-major order
    output wire [127:0] state_out
);
    // Byte extraction (AES column-major order)
    // Column 0
    wire [7:0] s0  = state_in[127:120];
    wire [7:0] s1  = state_in[119:112];
    wire [7:0] s2  = state_in[111:104];
    wire [7:0] s3  = state_in[103:96];

    // Column 1
    wire [7:0] s4  = state_in[95:88];
    wire [7:0] s5  = state_in[87:80];
    wire [7:0] s6  = state_in[79:72];
    wire [7:0] s7  = state_in[71:64];

    // Column 2
    wire [7:0] s8  = state_in[63:56];
    wire [7:0] s9  = state_in[55:48];
    wire [7:0] s10 = state_in[47:40];
    wire [7:0] s11 = state_in[39:32];

    // Column 3
    wire [7:0] s12 = state_in[31:24];
    wire [7:0] s13 = state_in[23:16];
    wire [7:0] s14 = state_in[15:8];
    wire [7:0] s15 = state_in[7:0];

    /*
       AES State (column-major):
       [ s0  s4  s8  s12 ]
       [ s1  s5  s9  s13 ]
       [ s2  s6  s10 s14 ]
       [ s3  s7  s11 s15 ]

       Inverse ShiftRows:
       Row 0 ? no shift
       Row 1 ? right shift by 1
       Row 2 ? right shift by 2
       Row 3 ? right shift by 3
    */

    assign state_out = {
        // Column 0
        s0,  s13, s10, s7,
        // Column 1
        s4,  s1,  s14, s11,
        // Column 2
        s8,  s5,  s2,  s15,
        // Column 3
        s12, s9,  s6,  s3
    };

endmodule
