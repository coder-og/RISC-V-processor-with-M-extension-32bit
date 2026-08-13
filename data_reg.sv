`timescale 1ns / 1ps
module data_reg#( parameter ins_width = 32)(
    input logic [ins_width-1:0] data1,
    input logic [ins_width-1:0] data2,
    input logic clock,
    input logic reset,
    output logic [ins_width-1:0] old_data1,
    output logic [ins_width-1:0] old_data2
);

    logic [ins_width-1:0] d1_store, d2_store;
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            d1_store <= 32'b0;
            d2_store <= 32'b0;
        end
        else begin
            d1_store <= data1;
            d2_store <= data2;
        end
    end
    
    assign old_data1 = d1_store;
    assign old_data2 = d2_store;

endmodule
