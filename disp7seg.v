`timescale 1ns / 1ps

// display_driver.v
// D�rt dijitli 7-segment ekran? s�rmek i�in kullan?l?r.
// 100MHz'lik ana saat sinyalini yava?lat?r ve dijitleri s?rayla tarar.

module disp7seg(
    input clk,           // 100MHz sistem saati
    input rst,           // Reset sinyali
    input [127:0] metin,  // En sa?daki dijitte g�sterilecek say?
    input btnR,
    input btnL,
    output  [6:0] seg,     // 7-segment �?k??? (katotlar)
    output reg [3:0] an       // Anot se�imi (dijit se�imi)
    );

    localparam CLK_DIV_MAX = 100000; // ~250 Hz yenileme h?z?
    reg [17:0] clk_divider_count = 0;
        localparam CLK_DIV_MAXforbtn = 10000000; // ~250 Hz yenileme h?z?
        reg [30:0] clk_divider_countforbtn = 0;
        reg slowclkforbtn=0;
    reg refresh_clk = 0;
    reg [7:0]metindispindex ;
    reg [3:0] metincharindex ;
    
    always @(posedge clk) begin

        if (clk_divider_count == CLK_DIV_MAX - 1) begin
            clk_divider_count <= 0;
            refresh_clk <= ~refresh_clk; // Yava?lat?lm?? saat sinyali
        end else begin
            clk_divider_count <= clk_divider_count + 1;
            
        end
        
        if (clk_divider_countforbtn == CLK_DIV_MAXforbtn - 1) begin
            clk_divider_countforbtn <= 0;
            slowclkforbtn <= ~slowclkforbtn; // Yava?lat?lm?? saat sinyali
        end else begin
            clk_divider_countforbtn <= clk_divider_countforbtn + 1;
            
        end
    end
    //saat yava?latma
    // Hangi dijitin aktif oldu?unu tutan 2-bitlik saya�
    reg [1:0] active_digit_selector = 0;
    // Her yava?lat?lm?? saat vuru?unda bir sonraki dijite ge�
    
    always @(posedge slowclkforbtn) begin
             
        if(btnR)begin 
            if(metindispindex == 28)begin 
            end
            else begin 
                metindispindex <= metindispindex+1;
            end
        end
        else if(btnL)begin 
            if(metindispindex==0)begin 
                
            end
            else begin 
                metindispindex <= metindispindex-1;
            end
        end
    end 
    
    always @(posedge refresh_clk or posedge rst) begin 

        
        if (rst) begin
            active_digit_selector <= 0;
          
        end else begin
            active_digit_selector <= active_digit_selector + 1;
        end
    end

    // Aktif dijite g�re g�sterilecek binary veriyi tutan ara kablo
    wire [3:0] current_digit_data;
    assign current_digit_data = metin[127-(4*metindispindex)-(4*metincharindex)-:4];//bura olmam??//bit bit kayd?r?nca girdi?imiz de?erler farkl? okunuyor 4 bit 4 bit kayd?rmal?y?z
    
    // Binary'den 7-segmente �evirici mod�l�n� burada �a??r
    binary_to_7seg decoder (
        .binary_in(current_digit_data),
        .seg_out(seg) // Bu 'seg' �?k??? direkt mod�l�n 'seg' �?k???na ba?lan?r
    );
    
    // Aktif dijit se�imine g�re anotlar? kontrol et (aktif-d�?�k)
    always @(*) begin
        case (active_digit_selector)
            2'b00: begin metincharindex<=3; an <= 4'b1110;end // En sa?daki dijiti (AN0) aktif et
            2'b01:begin metincharindex<=2; an <= 4'b1101;end // AN1'i aktif et
            2'b10:begin metincharindex<=1; an <= 4'b1011;end // AN2'yi aktif et
            2'b11:begin metincharindex<=0; an <= 4'b0111;end // En soldaki dijiti (AN3) aktif et
            default: an <= 4'b1111; // Hi�birini aktif etme
        endcase
    end

endmodule
