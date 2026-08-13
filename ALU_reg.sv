`timescale 1ns / 1ps
module single_result_reg#(
    parameter ins_width = 32
)(
    input logic clock,
    input logic reset,
    input logic [ins_width-1:0] data_in, 
    input logic write_enable,  
   
    output logic [ins_width-1:0] data_out   
);

    always_ff @(posedge clock or posedge reset)
    begin
        if (reset)
            data_out <= 32'b0;
        else if (write_enable) 
            data_out <= data_in;
    end

endmodule