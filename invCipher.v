`timescale 1ns / 1ps

module invCipher(
input clk_i,
input rst_i,
input basla,
input [127:0]metin_i,
input  [1919:0]key_i,
output [127:0]metin_o,
output bitti_o
    );                                           
    reg bitti;                                             
    reg [127:0]result;                                     
    reg [127:0]statein;                                   
    wire [127:0]resultsb;                                  
    wire [127:0]resultsr;                                  
    wire [127:0]resultmc;                                  
    wire [127:0]resultak;                                  
                                                       
    reg [127:0]roundkey;                                    
    reg [9:0] roundkeyctr;
    inv_subbytes sb (statein,resultsb);    
    invshiftrows sr(statein,resultsr);              
    INVMIXCOLUMNS mc(statein,resultmc);             
    addroundkey ak(statein,roundkey,resultak);             
                                  
    localparam Idle = 4'b0000;    
    localparam preloop = 4'b0001; 
    localparam loop = 4'b0010;    
    localparam postloop = 4'b0011;
                              
    reg [3:0]state;               
    reg [6:0]loopctr;            
    always@(posedge clk_i)begin 
        if(rst_i)begin 
            state <= Idle;
            loopctr <= 0;
            bitti <= 0;    
            result <= 0;
            statein <= 0;
            roundkeyctr <= 0;
            roundkey <= 0;            
        end
        else begin 
            bitti <= 0;
            case(state)
                Idle:begin 
                    if(basla)begin 
                        state <= preloop;
                        statein <= metin_i;
                        roundkey <= key_i[(128 * roundkeyctr) +: 128];
                        roundkeyctr <= roundkeyctr+1;
                    end
                    else state <= Idle;
                end
                preloop:begin 
                    statein <= resultak;
                    roundkey <= key_i[(128 * roundkeyctr) +: 128];//key_i[128 * roundkeyctr +: 128];
                    roundkeyctr <= roundkeyctr+1;
                    state <= loop;
                    loopctr <= 0;
                end
    
                loop:begin 
                    case(loopctr%4)
                        0:begin 
                              statein <= resultsr;
                        end
                        1:begin 
                             statein <= resultsb;
                        end
                        2:begin 
                            statein <= resultak;
                            roundkey <= key_i[(128 * roundkeyctr) +: 128];//key_i[1919-(128*roundkeyctr)-:128];
                            roundkeyctr <= roundkeyctr+1;
                        end
                        3:begin 
                            statein <= resultmc;
                            
                        end
                    endcase
                    loopctr <= loopctr+1;//loop counter asl?nda art?k 51
                    if(loopctr==51)begin 
                        //loop bitti 
                        state <= postloop; 
                        loopctr <= 0;
                    end
               end
               postloop:begin 
                    case(loopctr)
                        0:begin 
                            statein <= resultsr;
                        end
                        1:begin 
                            statein <= resultsb;
                        end
                        2:begin 
                             result <= resultak;
                        end
                    endcase
                    loopctr <= loopctr+1;
                    if(loopctr==2)begin 
                        //cipherbitti
                        loopctr <= 0;
                        state <= Idle;
                        bitti <= 1;
                        roundkeyctr <= 0;
                        roundkey <= 0;
                    end
                end
            endcase
        end
    end
    assign metin_o = result;
    assign bitti_o = bitti;
endmodule