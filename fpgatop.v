`timescale 1ns / 1ps

module fpgatop(
input clk_i,
input [15:0]switches_i,
input btnR_i,
input btnL_i,
input btnC_i,
input rx,

output tx,
output  [15:0] leds_o,
output  [6:0]seven_seg_o,
output  [3:0]seven_loc_o

    );
    wire islemmodu;
    assign islemmodu = switches_i[0];//islem modunu switch 0 ile se�iyoruz 0 iken ?ifrele 1 iken ��z
    assign leds_o[15:8] = {8{islemmodu}};
    assign leds_o[7:0] = {8{~islemmodu}};//sifrele modundayken yanarlar
    
    wire rst;
    assign rst = switches_i[15];
    
    wire btnR_db_t;
    wire btnR_db_l;
    wire btnL_db_t;
    wire btnL_db_l;
    wire btnC_db_t;
    wire btnC_db_l;
    
    debounce_explicit dbR(clk_i,rst,btnR_i,btnR_db_l,btnR_db_t);
    debounce_explicit dbL(clk_i,rst,btnL_i,btnL_db_l,btnL_db_t);
    debounce_explicit dbC(clk_i,rst,btnC_i,btnC_db_l,btnC_db_t);
    
    wire islemebasla;
    assign islemebasla = btnC_db_t;
    
    
    wire [127:0] metin;
    wire [127:0] sonucmetin;
    wire [255:0] key;
    
    disp7seg dsp7(clk_i,rst,sonucmetin,btnR_db_l,btnL_db_l,seven_seg_o,seven_loc_o);//buraya sonu� girecek metin de?il

    
    wire [255:0] uartkey;
    wire [127:0] uartmetin;
    wire uartmetinvalid;
    wire uartkeyvalid;
    uart_top_rx uart_top_rx(clk_i,rst,rx,uartmetin,uartmetinvalid,uartkey,uartkeyvalid);
    wire uarttxbasla;
    uart_top_tx transmitter_inst (clk_i,rst,uarttxbasla,sonucmetin,tx);
    
    
    wire [127:0]aessonuc;
    wire aeshazir;
    wire aesbitti;
    aes256 aes(clk_i,rst,key,metin,islemebasla,islemmodu,aessonuc,aeshazir,aesbitti);
    
    
    reg [127:0] uartmetin_reg;
    reg [255:0] uartkey_reg;
    reg [127:0] aessonuc_reg;
    reg uarttxbasla_reg;
    always @(posedge clk_i) begin
        if (rst) begin 
            uarttxbasla_reg <= 0;
            uartmetin_reg <= 0;
            uartkey_reg <= 0;
            aessonuc_reg <= 0;        
        end else begin
            uarttxbasla_reg <= 0;
            if (uartmetinvalid)begin
                uartmetin_reg <= uartmetin;
            end
            if (uartkeyvalid)begin 
                uartkey_reg <= uartkey ;
            end
            if(aesbitti)begin 
                aessonuc_reg <= aessonuc;
                uarttxbasla_reg <= 1;
            end
            
        end
    end

    assign metin = uartmetin_reg;
    assign key  = uartkey_reg;
    assign sonucmetin = aessonuc_reg;
    assign uarttxbasla = uarttxbasla_reg;
endmodule