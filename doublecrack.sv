module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    logic crack_en_c1;
    logic crack_en_c2;
    logic crack_rdy_c1;
    logic crack_rdy_c2;
    logic [23:0] key_c1;
    logic [23:0] key_c2;
    logic key_valid_c1;
    logic key_valid_c2;
    logic [7:0] ct_addr_c1;
    logic [7:0] ct_addr_c2;
    logic ct_mux_selector;
    logic [7:0] pt_addr;
    logic [7:0] pt_wrdata;
    logic [7:0] pt_rddata;
    logic pt_wren;
    logic [7:0] copy_pt_addr_c1;
    logic [7:0] copy_pt_addr_c2;
    logic [7:0] copy_pt_data_c1;
    logic [7:0] copy_pt_data_c2;
    logic [3:0] mode = 4'b0000;
    logic [3:0] next_mode;
    logic [7:0] length_reg = 8'd0;

    assign ct_addr = ct_addr_c1;

    
    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(.address(pt_addr), .clock(clk), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata));

    // for this task only, you may ADD ports to crack
    crack c1(.clk(clk), .rst_n(rst_n),
             .en(crack_en_c1), .rdy(crack_rdy_c1),
             .key(key_c1), .key_valid(key_valid_c1),
             .ct_addr(ct_addr_c1), .ct_rddata(ct_rddata), .start_key(24'd0), .copy_pt_addr(copy_pt_addr_c1), .copy_pt_data(copy_pt_data_c1));
    crack c2(.clk(clk), .rst_n(rst_n),
             .en(crack_en_c2), .rdy(crack_rdy_c2),
             .key(key_c2), .key_valid(key_valid_c2),
             .ct_addr(ct_addr_c2), .ct_rddata(ct_rddata), .start_key(24'd1), .copy_pt_addr(copy_pt_addr_c2), .copy_pt_data(copy_pt_data_c2));
    

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) mode <= 4'b0000;
        else mode <= next_mode;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            pt_addr <= 8'd0;
            pt_wren <= 0;
            pt_wrdata <= 8'd0;
            copy_pt_addr_c1 <= 8'd0;
            copy_pt_addr_c2 <= 8'd0;
            crack_en_c1 <= 0;
            crack_en_c2 <= 0;
            rdy <= 1;
            key <= 24'd0;
            key_valid <= 0;
            length_reg <= 8'd0;
        end
        else if(next_mode == 4'b0000) begin
            pt_addr <= 8'd0;
            pt_wren <= 0;
            pt_wrdata <= 8'd0;
            copy_pt_addr_c1 <= 8'd0;
            copy_pt_addr_c2 <= 8'd0;
            crack_en_c1 <= 0;
            crack_en_c2 <= 0;
            rdy <= 1;
            key <= 24'd0;
            key_valid <= 0;
            length_reg <= 8'd0;
        end
        else if(next_mode == 4'b0001) begin 
            rdy <= 0;
            crack_en_c1 <= 1;
            crack_en_c2 <= 1;
        end
        else if(next_mode == 4'b0010) begin
            crack_en_c1 <= 0;
            crack_en_c2 <= 0;
        end
        else if(next_mode == 4'b0011) begin
            length_reg <= copy_pt_data_c1;
            pt_wrdata <= copy_pt_data_c1;
            pt_wren <= 1;
            copy_pt_addr_c1++;
            key <= key_c1;
        end
        else if(next_mode == 4'b0100) pt_wren <= 0;
        else if(next_mode == 4'b0101) begin
            if(pt_addr >= length_reg) key_valid <= 1;
        end
        else if(next_mode == 4'b0111) begin
            pt_wrdata <= copy_pt_data_c1;
            pt_wren <= 1;
            pt_addr++;
            copy_pt_addr_c1++;
        end
        else if(next_mode == 4'b1000) begin
            length_reg <= copy_pt_data_c2;
            pt_wrdata <= copy_pt_data_c2;
            pt_wren <= 1;
            copy_pt_addr_c2++;
            key <= key_c2;
        end
        else if(next_mode == 4'b1001) pt_wren <= 0;
        else if(next_mode == 4'b1010) begin
            if(pt_addr >= length_reg) key_valid <= 1;
        end
        else if(next_mode == 4'b1100) begin
            pt_wrdata <= copy_pt_data_c2;
            pt_wren <= 1;
            pt_addr++;
            copy_pt_addr_c2++;
        end
    end

    always_comb begin
        case(mode)
        4'b0000: begin
            if(en == 1) next_mode = 4'b0001;
            else next_mode = 4'b0000;
        end
        4'b0001: next_mode = 4'b0010;
        4'b0010: begin
            if(key_valid_c1 == 1) next_mode = 4'b1101;
            else if(key_valid_c2 == 1) next_mode = 4'b1110;
            else next_mode = 4'b0010;
        end
        4'b0011: next_mode = 4'b0100;
        4'b0100: next_mode = 4'b0101;
        4'b0101: begin
            if(pt_addr < length_reg) next_mode = 4'b0110;
            else next_mode = 4'b0101;
        end
        4'b0110: next_mode = 4'b0111;
        4'b0111: next_mode = 4'b0100;
        4'b1000: next_mode = 4'b1001;
        4'b1001: next_mode = 4'b1010;
        4'b1010: begin
            if(pt_addr < length_reg) next_mode = 4'b1011;
            else next_mode = 4'b1010;
        end
        4'b1011: next_mode = 4'b1100;
        4'b1100: next_mode = 4'b1001;
        4'b1101: next_mode = 4'b0011;
        4'b1110: next_mode = 4'b1000;
        default: next_mode = 4'b0000;
        endcase
    end

endmodule: doublecrack

