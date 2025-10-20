`timescale 1ns / 1ps

module MIXCOLUMNS(
    input [127:0] inputState,
    output reg [127:0] outputState
    );
        always@(inputState) begin
            outputState[127 :120]=(multiplier1byte(inputState[127 :120],(8'h02)))^(multiplier1byte(inputState[119 :112],(8'h03)))^(inputState[111 :104])^(inputState[103 :96]);
            outputState[95 :88]=(multiplier1byte(inputState[95 : 88],(8'h02)))^(multiplier1byte(inputState[87 :80],(8'h03)))^(inputState[79 :72])^(inputState[71 :64]);
            outputState[63 :56]=(multiplier1byte(inputState[63 :56],(8'h02)))^(multiplier1byte(inputState[55 :48],(8'h03)))^(inputState[47 :40])^(inputState[39 :32]);
            outputState[31 :24]=(multiplier1byte(inputState[31 :24],(8'h02)))^(multiplier1byte(inputState[23 :16],(8'h03)))^(inputState[15 :8])^(inputState[7 :0]);

            outputState[119:112]=(inputState[127 :120])^(multiplier1byte(inputState[119 :112],(8'h02)))^(multiplier1byte(inputState[111 :104],(8'h03)))^(inputState[103 :96]);
            outputState[87:80]=(inputState[95 : 88])^(multiplier1byte(inputState[87 :80],(8'h02)))^(multiplier1byte(inputState[79 :72],(8'h03)))^(inputState[71 :64]);
            outputState[55:48]=(inputState[63 :56])^(multiplier1byte(inputState[55 :48],(8'h02)))^(multiplier1byte(inputState[47 :40],(8'h03)))^(inputState[39 :32]);
            outputState[23:16]=(inputState[31 :24])^(multiplier1byte(inputState[23 :16],(8'h02)))^(multiplier1byte(inputState[15 :8],(8'h03)))^(inputState[7 :0]);
            
            outputState[111:104]=(inputState[127 :120])^(inputState[119 :112])^(multiplier1byte(inputState[111 :104],(8'h02)))^(multiplier1byte(inputState[103 :96],(8'h03)));
            outputState[79:72]=(inputState[95 : 88])^(inputState[87 :80])^(multiplier1byte(inputState[79 :72],(8'h02)))^(multiplier1byte(inputState[71 :64],(8'h03)));
            outputState[47:40]=(inputState[63 :56])^(inputState[55 :48])^(multiplier1byte(inputState[47 :40],(8'h02)))^(multiplier1byte(inputState[39 :32],(8'h03)));
            outputState[15:8]=(inputState[31 :24])^(inputState[23 :16])^(multiplier1byte(inputState[15 :8],(8'h02)))^(multiplier1byte(inputState[7 :0],(8'h03)));
            
            outputState[103:96]=(multiplier1byte(inputState[127 :120],(8'h03)))^(inputState[119 :112])^(inputState[111 :104])^(multiplier1byte(inputState[103 :96],(8'h02)));
            outputState[71:64]=(multiplier1byte(inputState[95 : 88],(8'h03)))^(inputState[87 :80])^(inputState[79 :72])^(multiplier1byte(inputState[71 :64],(8'h02)));
            outputState[39:32]=(multiplier1byte(inputState[63 :56],(8'h03)))^(inputState[55 :48])^(inputState[47 :40])^(multiplier1byte(inputState[39 :32],(8'h02)));
            outputState[7:0]=(multiplier1byte(inputState[31 :24],(8'h03)))^(inputState[23 :16])^(inputState[15 :8])^(multiplier1byte(inputState[7 :0],(8'h02)));
            
            end
        
    
    
function [7:0] multiplier1byte;
    input [7:0] x1;
    input [7:0] x2;

    reg [7:0] a;
    reg [7:0] b;
    reg [7:0] p;
    integer i;
begin
    a = x1;
    b = x2;
    p = 0;

    for (i = 0; i < 8; i = i + 1) begin
        if (b[0])
            p = p ^ a;
        
        if (a[7])
            a = (a << 1) ^ 8'h1b;
        else
            a = a << 1;
        
        b = b >> 1;
    end

    multiplier1byte = p;
end
endfunction
endmodule


