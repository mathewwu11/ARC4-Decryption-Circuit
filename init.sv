`timescale 1ps / 1ps

module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);


    
    integer i = 0;
    reg run_en = 1;


    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            rdy <= 1'd1;
            addr <= 8'd0;
            wrdata <= 8'd0;
            wren <= 1'd0;
            i <= 0;
            run_en <= 1'd1;
        end
        else begin
            if(run_en == 1 && en == 0) begin
                rdy <= 1'd1;
                addr <= 8'd0;
                wrdata <= 8'd0;
                wren <= 1'd0;
                i <= 0;
                run_en <= 1'd1;
            end
            else if(run_en == 1 && en == 1) begin
                rdy <= 1'd0;
                addr <= 8'd0;
                wrdata <= 8'd0;
                wren <= 1'd1;
                i <= 0;
                run_en <= 1'd0;
            end
            else if(run_en == 0 && i < 256) begin
                rdy <= 1'd0;
                addr++;
                wrdata++;
                wren <= 1'd1;
                i++;
                run_en <= 1'd0;
            end
            else begin
                rdy <= 1'd1;
                addr <= 8'd0;
                wrdata <= 8'd0;
                wren <= 1'd0;
                i <= 256;
                run_en <= 1'd0;
            end
        end
    end
    


endmodule: init

