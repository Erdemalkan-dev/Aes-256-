`timescale 1ns / 1ps

module SHIFTROWS(
    input [127:0] inputState,
    output [127:0] outputState
    );
    
    //first row: o[0]=i[0],o[4]=i[4],o[8]=i[8],o[12]=i[12]
    assign outputState[127:120]=inputState[127:120];
    assign outputState[95:88]=inputState[95:88];
    assign outputState[63:56]=inputState[63:56];
    assign outputState[31:24]=inputState[31:24];
    
    //second row o[1]=i[5],o[5]=i[9],o[9]=i[13],o[13]=i[1]
    assign outputState[119:112]=inputState[87:80];
    assign outputState[87:80]=inputState[55:48];
    assign outputState[55:48]=inputState[23:16];
    assign outputState[23:16]=inputState[119:112];
    
    //third row o[2]=i[10],o[6]=i[14],o[10]=i[2],o[14]=i[6]
    assign outputState[111:104]=inputState[47:40];
    assign outputState[79:72]=inputState[15:8];
    assign outputState[47:40]=inputState[111:104];
    assign outputState[15:8]=inputState[79:72];
    
    //fourth row o[3]=i[15],o[7]=i[3],o[11]=i[7],o[15]=i[11]
    assign outputState[103:96]=inputState[7:0];
    assign outputState[71:64]=inputState[103:96];
    assign outputState[39:32]=inputState[71:64];
    assign outputState[7:0]=inputState[39:32];
    
    
endmodule
