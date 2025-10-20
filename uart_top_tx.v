`timescale 1ns / 1ps
module uart_top_tx(
    input wire i_clk,
    input wire i_reset,
    input wire i_send_trigger, // Gönderimi başlatmak için tetikleme sinyali
    input wire [127:0] i_data, // Gönderilecek veri

    output wire o_uart_txd // Fiziksel TX pinine bağlanacak çıkış
);

    localparam CHAR_COUNT = 32;
    localparam BAUD_RATE = 9600;
    localparam CLK_FREQ = 100_000_000;
    // Durum makinesi durumları
    localparam S_IDLE = 2'b00,
               S_SEND_CHAR = 2'b01,
               S_WAIT_TX_DONE = 2'b10;
               
    reg [1:0] r_state = S_IDLE;

    reg [127:0] r_tx_data_buffer = 0;
    reg [$clog2(CHAR_COUNT)-1:0] r_char_counter = 0;

    wire w_tx_busy;
    wire [7:0] w_ascii_char;
    wire w_tx_start;

    // Düşük seviye UART vericisini projemize dahil ediyoruz
    uart_tx uart_tx_inst (
        .i_clk(i_clk),
        .i_tx_start(w_tx_start),
        .i_tx_byte(w_ascii_char),
        .o_tx_serial(o_uart_txd),
        .o_tx_busy(w_tx_busy)
    );

    // --- 4-bit Hex'ten 8-bit ASCII'ye Çevrim ---
    // *** HATA BURADAYDI: Veri register'da (reg) tutuluyordu ve geç güncelleniyordu. ***
    // reg [3:0] r_current_nibble; 
    
    // *** DÜZELTME: Veriyi kablo (wire) olarak tanımlayıp kombinasyonel atama yapıyoruz. ***
    wire [3:0] w_current_nibble;
    assign w_current_nibble = r_tx_data_buffer[128 - 1 - (r_char_counter * 4) -: 4];
    assign w_ascii_char = (w_current_nibble < 10) ? (w_current_nibble + "0") : (w_current_nibble - 10 + "A");

    // Gönderim için anlık tetikleme sinyali
    assign w_tx_start = (r_state == S_SEND_CHAR);

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_state <= S_IDLE;
            r_char_counter <= 0;
            r_tx_data_buffer <= 0;
        end else begin
            case(r_state)
                S_IDLE: begin
                    if (i_send_trigger) begin
                        r_tx_data_buffer <= i_data; // Gönderilecek veriyi içeri al ve sabitle
                        r_char_counter <= 0;
                        r_state <= S_SEND_CHAR;
                    end
                end

                S_SEND_CHAR: begin
                    // *** DÜZELTME: Veri ataması artık always bloğu dışında yapıldığı için buradan kaldırıyoruz. ***
                    // r_current_nibble <= r_tx_data_buffer[128 - 1 - (r_char_counter * 4) -: 4];
                    
                    // Bu durum sadece bir saat vuruşu boyunca aktif kalarak w_tx_start sinyalini üretir.
                    r_state <= S_WAIT_TX_DONE;
                end
                
                S_WAIT_TX_DONE: begin
                    // uart_tx modülü bir önceki karakteri göndermeyi bitirene kadar bekle
                    if (!w_tx_busy) begin
                        if (r_char_counter == CHAR_COUNT - 1) begin
                            // Tüm karakterler gönderildi, başa dön
                            r_state <= S_IDLE;
                        end else begin
                            // Bir sonraki karaktere geç
                            r_char_counter <= r_char_counter + 1;
                            r_state <= S_SEND_CHAR;
                        end
                    end
                end
                
                default:
                    r_state <= S_IDLE;
            endcase
        end
    end
endmodule