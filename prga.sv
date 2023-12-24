`timescale 1ps / 1ps

module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    integer i = 0;
    integer j = 0;
    integer k = 0;
    integer temp_i = 0;
    integer temp_j = 0;
    logic [7:0] length_reg = 0;
    logic [7:0] s_i_reg = 0;
    logic [7:0] s_j_reg = 0;
    logic [3:0] state = 4'b0000;
    logic [3:0] next_state;


    always_ff @(posedge clk or negedge rst_n) begin //FF for other signals
        if(~rst_n) begin
            rdy <= 1;
            s_addr <= 8'd0;
            s_wrdata <= 8'd0;
            s_wren <= 0;
            ct_addr <= 8'd0;
            pt_addr <= 8'd0;
            pt_wrdata <= 8'd0;
            pt_wren <= 0;
            i <= 0;
            j <= 0;
            k <= 0;
            temp_i <= 0;
            temp_j <= 0;
            length_reg = 8'd0;
            s_i_reg = 8'd0;
            s_j_reg = 8'd0;
        end
        else if(next_state == 4'b0000) begin
            temp_i <= i;
            k <= 0;
            ct_addr <= 0;
            pt_addr <= 0;
            rdy <= 1;
        end
        else if(next_state == 4'b0001) rdy <= 0;
        else if(next_state == 4'b0010) begin
            length_reg <= ct_rddata;
            pt_wrdata <= ct_rddata;
            ct_addr <= 0;
            pt_addr <= 0;
            pt_wren <= 1;
            k++;
        end
        else if(next_state == 4'b0011) begin
            pt_wren <= 0;
            i <= (temp_i + 8'd1) % 256;
        end
        else if(next_state == 4'b0100)  begin 
            s_addr <= i;
            if(k <= length_reg) rdy <= 0;
            else rdy <= 1;
        end
        else if(next_state == 4'b0101) temp_j <= j;
        else if(next_state == 4'b0110) begin
            s_wrdata <= s_rddata;
            s_i_reg <= s_rddata;
            j <= (temp_j + s_rddata) % 256; 
        end
        else if(next_state == 4'b0111) s_addr <= j;
        else if(next_state == 4'b1000) s_wren <= 1;
        else if(next_state == 4'b1001) begin
            s_wrdata <= s_rddata;
            s_addr <= i;
            s_j_reg <= s_rddata;
        end
        else if(next_state == 4'b1010) begin
            s_wren <= 0;
            s_addr <= (s_i_reg + s_j_reg) % 256;
            ct_addr <= k;
        end
        else if(next_state == 4'b1011) begin
            pt_addr <= k;
        end
        else if(next_state == 4'b1100) begin
            pt_wrdata <= s_rddata ^ ct_rddata;
            pt_wren <= 1;
            k++;
            temp_i <= i;
        end
    end


    always_ff @(posedge clk or negedge rst_n) begin //state FF
        if(~rst_n) state <= 4'b0000;
        else state <= next_state;
    end

    always_comb begin //next_state CL
        case(state)
            4'b0000:begin
                if(en == 1) next_state = 4'b0001;
                else next_state = 4'b0000;
            end
            4'b0001: next_state = 4'b0010;
            4'b0010: next_state = 4'b0011;
            4'b0011: next_state = 4'b0100;
            4'b0100: begin
                if(k <= length_reg) next_state = 4'b0101;
                else next_state = 4'b0100;
            end
            4'b0101: next_state = 4'b0110;
            4'b0110: next_state = 4'b0111;
            4'b0111: next_state = 4'b1000;
            4'b1000: next_state = 4'b1001;
            4'b1001: next_state = 4'b1010;
            4'b1010: next_state = 4'b1011;
            4'b1011: next_state = 4'b1100;
            4'b1100: next_state = 4'b0011;
            default: next_state = 4'b0000;
        endcase
    end


endmodule: prga

