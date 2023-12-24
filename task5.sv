`timescale 1ps / 1ps

module task5(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    
    logic [23:0] key;
    logic key_valid;
    logic [7:0] ct_addr;
    logic [7:0] ct_rddata;
    logic [7:0] ct_wrdata = 8'd0;
    logic ct_wren = 0;
    logic crack_en = 0;
    logic crack_rdy;

    ct_mem ct( .address(ct_addr), .clock(CLOCK_50), .data(ct_wrdata), .wren(ct_wren), .q(ct_rddata));
    doublecrack dc(.clk(CLOCK_50), .rst_n(KEY[3]),
             .en(crack_en), .rdy(crack_rdy),
             .key(key), .key_valid(key_valid),
             .ct_addr(ct_addr), .ct_rddata(ct_rddata));

    
    always_comb begin
        if(crack_rdy == 1) crack_en = 1;
        else crack_en = 0;
    end


    hex_display h5(.base16(key[23:20]), .en(key_valid), .hex(HEX5));
    hex_display h4(.base16(key[19:16]), .en(key_valid), .hex(HEX4));
    hex_display h3(.base16(key[15:12]), .en(key_valid), .hex(HEX3));
    hex_display h2(.base16(key[11:8]), .en(key_valid), .hex(HEX2));
    hex_display h1(.base16(key[7:4]), .en(key_valid), .hex(HEX1));
    hex_display h0(.base16(key[3:0]), .en(key_valid), .hex(HEX0));


endmodule: task5


module hex_display(input logic [3:0] base16, input logic en, output logic [6:0] hex);

    always_comb begin
        casex ({en, base16})
            5'b0xxxx: begin //blank
                hex[6] = 1'b0;
                hex[5] = 1'b1;
                hex[4] = 1'b1;
                hex[3] = 1'b1;
                hex[2] = 1'b1;
                hex[1] = 1'b1;
                hex[0] = 1'b1;
            end
            5'b10000: begin //zero
                hex[6] = 1'b1;
                hex[5] = 1'b0;
                hex[4] = 1'b0;
                hex[3] = 1'b0;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b0;
            end
            5'b10001: begin //one
                hex[6] = 1'b1;
                hex[5] = 1'b1;
                hex[4] = 1'b1;
                hex[3] = 1'b1;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b1;
            end
            5'b10010: begin //two
                hex[6] = 1'b0;
                hex[5] = 1'b1;
                hex[4] = 1'b0;
                hex[3] = 1'b0;
                hex[2] = 1'b1;
                hex[1] = 1'b0;
                hex[0] = 1'b0;
            end
            5'b10011: begin //three
                hex[6] = 1'b0;
                hex[5] = 1'b1;
                hex[4] = 1'b1;
                hex[3] = 1'b0;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b0;
            end
            5'b10100: begin //four
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b1;
                hex[3] = 1'b1;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b1;
            end
            5'b10101: begin //five
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b1;
                hex[3] = 1'b0;
                hex[2] = 1'b0;
                hex[1] = 1'b1;
                hex[0] = 1'b0;
            end
            5'b10110: begin //six
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b0;
                hex[3] = 1'b0;
                hex[2] = 1'b0;
                hex[1] = 1'b1;
                hex[0] = 1'b0;
            end
            5'b10111: begin //seven
                hex[6] = 1'b1;
                hex[5] = 1'b1;
                hex[4] = 1'b1;
                hex[3] = 1'b1;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b0;
            end
            5'b11000: begin //eight
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b0;
                hex[3] = 1'b0;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b0;
            end
            5'b11001: begin //nine
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b1;
                hex[3] = 1'b0;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b0;
            end
            5'b11010: begin //A
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b0;
                hex[3] = 1'b1;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b0;
            end
            5'b11011: begin //b
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b0;
                hex[3] = 1'b0;
                hex[2] = 1'b0;
                hex[1] = 1'b1;
                hex[0] = 1'b1;
            end
            5'b11100: begin //C
                hex[6] = 1'b1;
                hex[5] = 1'b0;
                hex[4] = 1'b0;
                hex[3] = 1'b0;
                hex[2] = 1'b1;
                hex[1] = 1'b1;
                hex[0] = 1'b0;
            end 
            5'b11101: begin //d
                hex[6] = 1'b0;
                hex[5] = 1'b1;
                hex[4] = 1'b0;
                hex[3] = 1'b0;
                hex[2] = 1'b0;
                hex[1] = 1'b0;
                hex[0] = 1'b1;
            end
            5'b11110: begin //E
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b0;
                hex[3] = 1'b0;
                hex[2] = 1'b1;
                hex[1] = 1'b1;
                hex[0] = 1'b0;
            end
            5'b11111: begin //F
                hex[6] = 1'b0;
                hex[5] = 1'b0;
                hex[4] = 1'b0;
                hex[3] = 1'b1;
                hex[2] = 1'b1;
                hex[1] = 1'b1;
                hex[0] = 1'b0;
            end
            default: begin
                hex[6] = 1'b0;
                hex[5] = 1'b1;
                hex[4] = 1'b1;
                hex[3] = 1'b1;
                hex[2] = 1'b1;
                hex[1] = 1'b1;
                hex[0] = 1'b1;
            end
        endcase


    end



endmodule

