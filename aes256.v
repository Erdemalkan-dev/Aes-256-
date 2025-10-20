`timescale 1ns / 1ps

module aes256(
    input clk_i,//1 bitlik saat sinyali
    input rst_i, //1 bitlik reset sinyali
    input [255:0]anahtar_i,//256 bitlik metni ?ifrelemede-��zmede kullan?lacak anahtar sinyali
    input [127:0]metin_i,// 128 bitlik ?ifrelenecek-��z�lecek metin sinyali
    input gecerli_i,// 1 bitlik, giri? metninin ge�erli oldu?unu belirten sinyal         
    input mod_i,    //  1 bitlik, mod�l�n hangi i?lem modunda �al??aca??n? belirten sinyal(0:?ifreleme, 1: ��zme)

    output [127:0]metin_o,// 128 bitlik ?ifrelenmi?-��z�lm�? metin �?kt?s?
    output hazir_o,// 1 bitlik, mod�l�n ?ifreleme-��zme i?lemine haz?r oldu?unu belirtensinyal  
    output gecerli_o// 1 bitlik, �?kt? metninin ge�erli oldu?unu belirten sinyal
    );
    //her bir modulun tamamlanmas? 1 clock s�recek ?ekilde yaparsak daha temiz olabilir
    reg [255:0]anahtar_i_buffer;
    reg [127:0]metin_i_buffer;
    
    wire sifrelemebitti;
    wire [1919:0]key1919;
    wire [127:0]sifrelimetin;
    reg cipherbasla;
    
    cipher cp(clk_i,rst_i,cipherbasla,metin_i_buffer,key1919,sifrelimetin,sifrelemebitti);
    
    wire cozmebitti;
    wire [127:0] cozulmusmetin;
    reg invcipherbasla;
    invCipher decp(clk_i,rst_i,invcipherbasla,metin_i_buffer,key1919,cozulmusmetin,cozmebitti);
    
    wire bittike;
    key_expansion ke(anahtar_i_buffer,key1919,bittike);
    
    localparam idle = 4'b0000;
    localparam cip = 4'b0001;
    localparam decip = 4'b0010;
    localparam makekey =4'b0011;
    reg [3:0] state;
    
    reg hazir;
    reg [127:0]sonuc;
    reg gecerli;
    
    always@(posedge clk_i)begin 
        if(rst_i)begin 
            hazir<= 1;
            sonuc<= 0;
            gecerli <= 0;
            state <= idle;
            cipherbasla <= 0;
            invcipherbasla <= 0;
           
        end
        else begin 
            gecerli <=0;
            cipherbasla <= 0;
            invcipherbasla <= 0;
            case(state)
                idle:begin 
                    if(gecerli_i)begin 
                        metin_i_buffer <= metin_i;
                        anahtar_i_buffer <= anahtar_i;
                        state<=makekey;
                    end
                    else begin 
                       hazir<=1;
                    end
                end
                makekey:begin 
                    if(bittike)begin 
                        if(mod_i)begin //0 ?ifrele 1 ��z
                            state<= decip;
                            hazir<=0;
                            invcipherbasla <= 1;
                        end
                        else begin 
                            state<=cip;
                            hazir<=0;
                            cipherbasla<=1;
                        end
                    end
                end
                cip:begin 
                    if(sifrelemebitti)begin 
                        gecerli <= 1;
                        hazir <= 1;
                        sonuc <= sifrelimetin;
                        state <= idle;
                    end
                end
                decip:begin 
                        if (cozmebitti) begin
                        // wire cozmebitti;
                        // wire [127:0] cozulmusmetin;
                        // reg invcipherbasla;
                        gecerli <= 1;
                        hazir <= 1;
                        sonuc <= cozulmusmetin;
                        state <= idle;
                    end
                end
                
            endcase
        end
        
    end
    assign hazir_o = hazir;
    assign metin_o = sonuc;
    assign gecerli_o = gecerli;
endmodule