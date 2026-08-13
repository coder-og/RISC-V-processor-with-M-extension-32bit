`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Unified_Memory_1Port
// Description: A single-port memory for instructions and data.
//////////////////////////////////////////////////////////////////////////////////
module Unified_Memory_1Port#(
    parameter ins_width = 32,
    parameter mem_size = 4096
)(
    input logic clock,
    input logic memwrite,
    input logic [ins_width-1:0] address,     // <-- Single address port
    input logic [ins_width-1:0] data_in,     
    output logic [ins_width-1:0] data_out     // <-- Single data output
);

    logic [ins_width-1:0] memory [0:mem_size-1];
    
    logic [11:0] word_index;
    assign word_index = address[13:2]; 
    
    initial begin
        $readmemh("unified_memory.mem", memory); 
    end

   
    assign data_out = memory[word_index];

    always_ff @(posedge clock)
    begin
        if (memwrite) begin 
            memory[word_index] <= data_in; 
        end
    end

endmodule