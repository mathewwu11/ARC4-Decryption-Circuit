`timescale 1ps / 1ps

module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    logic en_ksa;
    logic rdy_ksa;
    logic en_init;
    logic rdy_init;
    logic en_prga;
    logic rdy_prga;
    logic [7:0] s_addr_ksa;
    logic [7:0] s_addr_init;
    logic [7:0] s_addr_prga;
    logic [7:0] s_wrdata_ksa;
    logic [7:0] s_wrdata_init;
    logic [7:0] s_wrdata_prga;
    logic wren_ksa;
    logic wren_init;
    logic wren_prga;
    logic [7:0] s_data_out;
    logic [7:0] s_addr;
    logic [7:0] s_wrdata;
    logic wren;
    logic init_activated = 0;
    logic ksa_activated = 0;
    logic prga_activated = 0;
    logic arc4_activated = 0;

    s_mem s(.address(s_addr), .clock(clk), .data(s_wrdata), .wren(wren), .q(s_data_out));
    
    init i(.clk(clk), .rst_n(rst_n), .en(en_init), .rdy(rdy_init), .addr(s_addr_init), .wrdata(s_wrdata_init), .wren(wren_init));
    
    ksa k(.clk(clk), .rst_n(rst_n), .en(en_ksa), .rdy(rdy_ksa), .key(key), .addr(s_addr_ksa), .rddata(s_data_out), .wrdata(s_wrdata_ksa), .wren(wren_ksa));
    
    prga p(.clk(clk), .rst_n(rst_n), .en(en_prga), .rdy(rdy_prga), .key(key), .s_addr(s_addr_prga), .s_rddata(s_data_out), .s_wrdata(s_wrdata_prga), .s_wren(wren_prga), 
           .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) init_activated <= 0;
        else if(en_init == 1) init_activated <= 1;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) ksa_activated <= 0;
        else if(en_ksa == 1) ksa_activated <= 1;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) prga_activated <= 0;
        else if(en_prga == 1) prga_activated <= 1;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) arc4_activated <= 0;
        else if(en == 1) arc4_activated <= 1;
    end

    always_comb begin
        case({init_activated,ksa_activated,prga_activated})
            3'b100: begin
                s_addr = s_addr_init;
                s_wrdata = s_wrdata_init;
                wren = wren_init;
            end
            3'b110: begin
                s_addr = s_addr_ksa;
                s_wrdata = s_wrdata_ksa;
                wren = wren_ksa;
            end
            3'b111: begin
                s_addr = s_addr_prga;
                s_wrdata = s_wrdata_prga;
                wren = wren_prga;
            end
            default: begin
                s_addr = s_addr_init;
                s_wrdata = s_wrdata_init;
                wren = wren_init;
            end
        endcase
    end

    always_comb begin
        if(rdy_prga == 1 && ksa_activated == 1 && prga_activated == 0 && rdy_ksa == 1) begin
            en_prga = 1;
        end
        else begin
            en_prga = 0;
        end
    end

    always_comb begin
        if(rdy_ksa == 1 && init_activated == 1 && ksa_activated == 0 && rdy_init == 1) begin
            en_ksa = 1;
        end
        else begin
            en_ksa = 0;
        end
    end

    always_comb begin
        if(rdy_init == 1 && init_activated == 0 && arc4_activated == 1) begin
            en_init = 1;
        end
        else begin
            en_init = 0;
        end
    end

    always_comb begin
        if(arc4_activated == 0) rdy = 1;
        else if(rdy_prga == 1 && prga_activated == 1) rdy = 1;
        else rdy = 0;
    end
    

endmodule: arc4

