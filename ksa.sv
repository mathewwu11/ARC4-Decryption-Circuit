`timescale 1ps / 1ps

module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    integer i = 0;
    integer j = 0;
    integer temp_j = 0;
    reg [2:0] state;
    reg [2:0] next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            state <= 3'b001;
        end
        else begin
            state = next_state;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            rdy <= 0;
            addr <= 8'd0;
            wrdata <= 8'd0;
            wren <= 0;
            i <= 0;
            j <= 0;
            temp_j <= 0;
        end
        else begin
            if(next_state == 3'b000) begin
                rdy <= 1;
                addr <= i;
                wrdata <= 8'd0;
                wren <= 0;
            end
            else if(next_state == 3'b001) begin
                if(en === 1) begin
                    rdy <= 0;
                    addr <= i;
                    wren <= 0;
                end
                else begin
                    rdy <= 1;
                    addr <= i;
                    wrdata <= 8'd0;
                    wren <= 0;
                end
            end
            else if(next_state == 3'b010) begin
                wren <= 0;
                rdy <= 0;
                temp_j <= j;
            end
            else if(next_state == 3'b011) begin
                if(i % 3 == 0) j <= (temp_j + rddata + key[23:16]) % 256;
                else if(i % 3 == 1) j <= (temp_j + rddata + key[15:8]) % 256;
                else j <= (temp_j + rddata + key[7:0]) % 256;
                wrdata <= rddata;
            end
            else if(next_state == 3'b100) begin
                addr <= j;
            end
            else if(next_state == 3'b101) begin
                wren = 1;
            end
            else if(next_state == 3'b110) begin
                addr <= i;
                wrdata <= rddata;
                i++;
            end
            else if(next_state == 3'b111) begin
                wren = 0;
                addr = i;
                if(i < 256) rdy <= 0;
                else rdy <= 1;
            end
        end
    end
    

    always_comb begin //this wont work
        case(state)
            3'b000: next_state = 3'b001;
            3'b001: begin
                if(en == 1) next_state = 3'b010;
                else next_state = 3'b001;
            end
            3'b010: next_state = 3'b011;
            3'b011: next_state = 3'b100;
            3'b100: next_state = 3'b101;
            3'b101: next_state = 3'b110;
            3'b110: next_state = 3'b111;
            3'b111: begin
                if(i < 256) next_state = 3'b010;
                else next_state = 3'b111;
            end
        endcase
    end


endmodule: ksa

