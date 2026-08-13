`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 10:09:49 PM
// Design Name: 
// Module Name: pc_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pc_reg#(parameter ins_width = 32, ins_depth=19, pc_width = 32, opcode_width=7, r_width=5, fun1=3, fun2=7, immediate_len=12)(
        input logic [ins_width-1:0]next_pc,
        input logic clock,
        input logic reset,
        input logic PC_write ,
        output logic [ins_width-1:0] pc  
              
    );
    always_ff @(posedge clock)
    begin
    if (reset)
    begin
    pc<=32'b00000000000000000000000000000000;
    end
    else if (PC_write)
    begin
    pc<=next_pc;
    end
    end
endmodule
