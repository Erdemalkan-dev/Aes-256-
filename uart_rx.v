`timescale 1ns / 1ps
module uart_rx(
    input  wire clk_i,
    input  wire rx,
    output wire o_rx_dv,       // Data valid sinyali (bir saat periyodu aktif)
    output wire [7:0] o_rx_byte  // Al§nan byte
);

    localparam CLKS_PER_BIT = 10417;
    // Durum makinesi durumlar§
    localparam [1:0] IDLE      = 2'b00,
                     START_BIT = 2'b01,
                     DATA_BITS = 2'b10,
                     STOP_BIT  = 2'b11;

    reg [1:0] r_state = IDLE;

    // --- YEN?L?K 1: G?R?? SENKRON?ZAT?R? ---
    // i_rx_serial asenkron sinyalini i_clk domain'ine g?venle almak i?in.
    reg r_rx_sync0, r_rx_sync1;
    always @(posedge clk_i) begin
        r_rx_sync0 <= rx;
        r_rx_sync1 <= r_rx_sync0;
    end

    // --- YEN?L?K 2: D??EN KENAR TESP?T? ---
    // Start bitinin ba?lang§c§n§ hassas bir ?ekilde yakalamak i?in.
    reg r_rx_prev_sync;
    wire w_start_edge;
    always @(posedge clk_i) begin
        r_rx_prev_sync <= r_rx_sync1;
    end
    assign w_start_edge = r_rx_prev_sync & ~r_rx_sync1; // 1 -> 0 ge?i?ini tespit eder

    // Zamanlama i?in saya?lar
    reg [$clog2(CLKS_PER_BIT)-1:0] r_clk_counter = 0;
    reg [2:0] r_bit_index = 0;

    // Al§nan veriyi tutan register
    reg [7:0] r_rx_byte = 8'b0;
    reg r_rx_dv = 1'b0;

    assign o_rx_byte = r_rx_byte;
    assign o_rx_dv = r_rx_dv;

    always @(posedge clk_i) begin
        r_rx_dv <= 1'b0;

        case (r_state)
            IDLE: begin
                // Sadece start bitinin d??en kenar§ alg§land§?§nda i?leme ba?la
                if (w_start_edge) begin
                    r_state       <= START_BIT;
                    r_clk_counter <= 0;
                end
            end

            START_BIT: begin
                // Start bitinin ortas§na gelene kadar bekle
                if (r_clk_counter == (CLKS_PER_BIT / 2) - 1) begin
                    r_state       <= DATA_BITS;
                    r_clk_counter <= 0;
                    r_bit_index   <= 0;
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end

            DATA_BITS: begin
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_clk_counter <= 0;
                    // Biti okurken senkronize edilmi? sinyali kullan
                    r_rx_byte[r_bit_index] <= r_rx_sync1; 

                    if (r_bit_index == 7) begin
                        r_state <= STOP_BIT;
                    end else begin
                        r_bit_index <= r_bit_index + 1;
                    end
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end

            STOP_BIT: begin
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_state <= IDLE;
                    r_rx_dv <= 1'b1;
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end

            default:
                r_state <= IDLE;
        endcase
    end
endmodule