`timescale 1ns / 1ps
module uart_tx(
    input  wire i_clk,
    input  wire i_tx_start,      // G�nderimi ba?latmak i�in 1 saat vuru?luk sinyal
    input  wire [7:0] i_tx_byte, // G�nderilecek 8-bit'lik byte

    output wire o_tx_serial,     // Fiziksel TX pinine ba?lanacak �?k??
    output wire o_tx_busy        // Mod�l me?gulken '1' olur
);
    localparam CLKS_PER_BIT = 10417;
    localparam [2:0] S_IDLE      = 3'b000,
                     S_START_BIT = 3'b001,
                     S_DATA_BITS = 3'b010,
                     S_STOP_BIT  = 3'b011;

    reg [2:0] r_state = S_IDLE;
    
    reg [$clog2(CLKS_PER_BIT)-1:0] r_clk_counter = 0;
    reg [2:0] r_bit_index = 0;
    reg [7:0] r_tx_byte = 0;
    reg r_tx_serial = 1'b1; // UART hatt? bo?ta iken '1' olmal?d?r.
    
    assign o_tx_serial = r_tx_serial;
    assign o_tx_busy = (r_state != S_IDLE);

    always @(posedge i_clk) begin
        case (r_state)
            S_IDLE: begin
                r_tx_serial <= 1'b1; // Hatt? idle (high) konumunda tut
                if (i_tx_start) begin
                    r_tx_byte <= i_tx_byte;
                    r_clk_counter <= 0;
                    r_bit_index <= 0;
                    r_state <= S_START_BIT;
                end
            end

            S_START_BIT: begin
                r_tx_serial <= 1'b0; // Start biti
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_clk_counter <= 0;
                    r_state <= S_DATA_BITS;
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end
            
            S_DATA_BITS: begin
                r_tx_serial <= r_tx_byte[r_bit_index]; // LSB'den ba?layarak bitleri g�nder
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_clk_counter <= 0;
                    if (r_bit_index == 7) begin
                        r_state <= S_STOP_BIT;
                    end else begin
                        r_bit_index <= r_bit_index + 1;
                    end
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end

            S_STOP_BIT: begin
                r_tx_serial <= 1'b1; // Stop biti
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_state <= S_IDLE;
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end
            
            default:
                r_state <= S_IDLE;
        endcase
    end
endmodule