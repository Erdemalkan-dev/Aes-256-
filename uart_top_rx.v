`timescale 1ns / 1ps
module uart_top_rx(
    input  wire clk_i,
    input  wire reset,
    input  wire rx,

    output reg [127:0] o_metin,        // 'M' komutuyla gelen 128 bitlik metin
    output reg         o_metin_valid,  // Metin verisi hazýr olduðunda 1 olur
    output reg [255:0] o_anahtar,      // 'A' komutuyla gelen 256 bitlik anahtar
    output reg         o_anahtar_valid // Anahtar verisi hazýr olduðunda 1 olur
);

    // Durum makinesi durumlarý
    localparam S_IDLE       = 2'd0; // Komut bekleme
    localparam S_READ_METIN = 2'd1; // Metin verisini okuma
    localparam S_READ_ANAHTAR = 2'd2; // Anahtar verisini okuma

    reg [1:0] r_state = S_IDLE;

    // Gelen byte'larý saymak için sayaç
    reg [5:0] r_byte_counter = 0; // 256 bit = 32 byte (en fazla 32)

    // UART alýcýdan gelen sinyaller
    wire w_rx_dv;
    wire [7:0] w_rx_byte;

    // uart_rx modülünü projemize dahil ediyoruz
    uart_rx uart_rx_inst(clk_i,rx,w_rx_dv,w_rx_byte);
    
    reg [3:0] r_hex_nibble;
    always @(*) begin
        case (w_rx_byte)
            "0": r_hex_nibble = 4'h0;
            "1": r_hex_nibble = 4'h1;
            "2": r_hex_nibble = 4'h2;
            "3": r_hex_nibble = 4'h3;
            "4": r_hex_nibble = 4'h4;
            "5": r_hex_nibble = 4'h5;
            "6": r_hex_nibble = 4'h6;
            "7": r_hex_nibble = 4'h7;
            "8": r_hex_nibble = 4'h8;
            "9": r_hex_nibble = 4'h9;
            "a", "A": r_hex_nibble = 4'hA;
            "b", "B": r_hex_nibble = 4'hB;
            "c", "C": r_hex_nibble = 4'hC;
            "d", "D": r_hex_nibble = 4'hD;
            "e", "E": r_hex_nibble = 4'hE;
            "f", "F": r_hex_nibble = 4'hF;
            default: r_hex_nibble = 4'hF; // Geçersiz karakterler için varsayýlan deðer
        endcase
    end
    
    always @(posedge clk_i or posedge reset) begin
        if (reset) begin
            r_state <= S_IDLE;
            r_byte_counter <= 0;
            o_metin <= 0;
            o_metin_valid <= 0;
            o_anahtar <= 0;
            o_anahtar_valid <= 0;
        end else begin
            // Geçerli sinyallerini her zaman sýfýrla (tek vuruþluk olmalarý için)
            o_metin_valid <= 1'b0;
            o_anahtar_valid <= 1'b0;

            case (r_state)
                S_IDLE: begin
                    // Yeni bir byte geldiyse kontrol et
                    if (w_rx_dv) begin
                        if (w_rx_byte == "M") begin // Metin komutu
                            r_state <= S_READ_METIN;
                            r_byte_counter <= 0;
                        end else if (w_rx_byte == "A") begin // Anahtar komutu
                            r_state <= S_READ_ANAHTAR;
                            r_byte_counter <= 0;
                        end
                        // Diðer karakterler göz ardý edilir
                    end
                end

                S_READ_METIN: begin
                    if (w_rx_dv) begin
                        // Gelen byte'ý metin register'ýna kaydýrarak ekle
                        //case (w_rx_dv)
                        //    // Sayisal karakterler '0' (0x30) ile '9' (0x39) arasi
                        //    "0": o_metin <= {o_metin[123:0], 4'h0};
                        //    "1": o_metin <= {o_metin[123:0], 4'h1};
                        //    "2": o_metin <= {o_metin[123:0], 4'h2};
                        //    "3": o_metin <= {o_metin[123:0], 4'h3};
                        //    "4": o_metin <= {o_metin[123:0], 4'h4};
                        //    "5": o_metin <= {o_metin[123:0], 4'h5};
                        //    "6": o_metin <= {o_metin[123:0], 4'h6};
                        //    "7": o_metin <= {o_metin[123:0], 4'h7};
                        //    "8": o_metin <= {o_metin[123:0], 4'h8};
                        //    "9": o_metin <= {o_metin[123:0], 4'h9};
                        //
                        //    // Küçük harf karakterler 'a' (0x61) ile 'f' (0x66) arasi
                        //    "a": o_metin <= {o_metin[123:0], 4'hA}; // 1010
                        //    "b": o_metin <= {o_metin[123:0], 4'hB};
                        //    "c": o_metin <= {o_metin[123:0], 4'hC};
                        //    "d": o_metin <= {o_metin[123:0], 4'hD};
                        //    "e": o_metin <= {o_metin[123:0], 4'hE};
                        //    "f": o_metin <= {o_metin[123:0], 4'hF};
                        //
                        //    // Büyük harf karakterler 'A' (0x41) ile 'F' (0x46) arasi
                        //    "A": o_metin <= {o_metin[123:0], 4'hA}; // 1010
                        //    "B": o_metin <= {o_metin[123:0], 4'hB};
                        //    "C": o_metin <= {o_metin[123:0], 4'hC};
                        //    "D": o_metin <= {o_metin[123:0], 4'hD};
                        //    "E": o_metin <= {o_metin[123:0], 4'hE};
                        //    "F": o_metin <= {o_metin[123:0], 4'hF};
                        //
                        //     //default: hex_value <= 4'hX; // Geçersiz hex karakteri
                        //endcase 
                        o_metin <= {o_metin[123:0], r_hex_nibble};
                        
                        if (r_byte_counter == 31) begin // 16 byte (128 bit) okundu//32 byte 128 bit okuyacak her 8 biti hex karþýlýðýna çevirerek 128 bitlik metin regine koyacak
                            r_state <= S_IDLE;
                            o_metin_valid <= 1'b1; // Metin hazýr!
                        end else begin
                            r_byte_counter <= r_byte_counter + 1;
                        end
                    end
                end
                
                S_READ_ANAHTAR: begin
                    if (w_rx_dv) begin
                        // Gelen byte'ý anahtar register'ýna kaydýrarak ekle
                        o_anahtar <= {o_anahtar[251:0], r_hex_nibble};

                        if (r_byte_counter == 63) begin // 32 byte (256 bit) okundu
                            r_state <= S_IDLE;
                            o_anahtar_valid <= 1'b1; // Anahtar hazýr!
                        end else begin
                            r_byte_counter <= r_byte_counter + 1;
                        end
                    end
                end

                default:
                    r_state <= S_IDLE;

            endcase
        end
    end
    
    

endmodule