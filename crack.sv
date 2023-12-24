`timescale 1ps / 1ps

module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
             input logic [23:0] start_key, input logic [7:0] copy_pt_addr, output logic [7:0] copy_pt_data);

    // For Task 5, you may modify the crack port list above,
    // but ONLY by adding new ports. All predefined ports must be identical.

    logic [7:0] pt_addr;
    logic [7:0] pt_wrdata;
    logic [7:0] pt_rddata;
    logic pt_wren;
    logic rdy_arc4;
    logic arc4_rst = 1;
    logic en_arc4 = 0;
    logic [7:0] pt_addr_arc4;
    logic [7:0] pt_addr_crack = 8'd0;
    logic [7:0] string_length = 8'd0;
    reg [3:0] state = 4'b0000;
    reg [3:0] next_state;
    
    wire combine_reset;

    assign combine_reset = rst_n & arc4_rst;
    assign copy_pt_data = pt_rddata;

    always_comb begin
        casex({key_valid, rdy_arc4})
        2'b1x: pt_addr = pt_addr_crack;
        2'b00: pt_addr = pt_addr_arc4;
        2'b01: pt_addr = pt_addr_crack;
        default: pt_addr = pt_addr_crack;
        endcase
    end

    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(.address(pt_addr), .clock(clk), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata));
    arc4 a4( .clk(clk), .rst_n(combine_reset), .en(en_arc4), .rdy(rdy_arc4), .key(key), .ct_addr(ct_addr), 
            .ct_rddata(ct_rddata), .pt_addr(pt_addr_arc4), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren) );

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) state <= 4'b0000;
        else state <= next_state;
    end

    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            en_arc4 <= 0;
            key_valid <= 0;
            key <= start_key;
            pt_addr_crack <= 0;
            arc4_rst <= 1;
            rdy <= 1;
        end
        else begin
            if(next_state == 4'b0000) begin
                en_arc4 <= 0;
                key_valid <= 0;
                key <= start_key;
                pt_addr_crack <= 0;
                arc4_rst <= 1;
                rdy <= 1;
            end
            else if(next_state == 4'b0001) begin
                key <= start_key;
                rdy <= 0;
                en_arc4 <= 1;
            end
            else if(next_state == 4'b0010) en_arc4 <= 0;
            else if(next_state == 4'b0011) pt_addr_crack <= 8'd0;
            else if(next_state == 4'b0100) pt_addr_crack++;
            else if(next_state == 4'b0101) begin
                string_length <= pt_rddata;
                if(pt_rddata > 8'd0) rdy <= 0;
                else rdy <= 1;
            end
            else if(next_state == 4'b0110) pt_addr_crack++;
            else if(next_state == 4'b1000) begin
                if(key < 24'hFFFFFF) begin
                    key += 2;
                    arc4_rst <= 0;
                    rdy <= 0;
                end
                else rdy <= 1;
            end 
            else if(next_state == 4'b1001) begin
                arc4_rst <= 1;
                en_arc4 <= 1;
            end
            else if(next_state == 4'b1010) en_arc4 = 0;
            else if(next_state == 4'b1011) pt_addr_crack = 8'd1;
            else if(next_state == 4'b1101) begin
                rdy <= 1;
                key_valid <= 1;
                pt_addr_crack <= copy_pt_addr;
            end
        end
    end

    always_comb begin
        case(state)
        4'b0000: begin
            if(en == 1) next_state = 4'b0001;
            else next_state = 4'b0000;
        end
        4'b0001: begin
            next_state = 4'b0010;
        end
        4'b0010: begin
            if(rdy_arc4 == 0) next_state = 4'b0010;
            else next_state = 4'b0011;
        end
        4'b0011: next_state = 4'b0100;
        4'b0100: next_state = 4'b0101;
        4'b0101: begin
            if(pt_rddata == 0 || rdy == 1) next_state = 4'b0101;
            else next_state = 4'b0110;
        end
        4'b0110: begin
            if(pt_rddata >= 8'h20 && pt_rddata <= 8'h7E) next_state = 4'b0111;
            else next_state = 4'b1000;
        end
        4'b0111: begin
            if(pt_addr <= string_length) next_state = 4'b0110;
            else next_state = 4'b1101;
        end
        4'b1000: begin 
            if(rdy == 1) next_state = 4'b1000;
            else next_state = 4'b1001;
        end
        4'b1001: next_state = 4'b1010;
        4'b1010: begin
            if(rdy_arc4 == 0) next_state = 4'b1010;
            else next_state = 4'b1011;
        end
        4'b1011: next_state = 4'b1100;
        4'b1100: next_state = 4'b0110;
        4'b1101: next_state = 4'b1101;
        default: next_state = 4'b0000;
        endcase
    end

endmodule: crack
