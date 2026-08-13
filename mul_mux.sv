`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2025 12:57:34 PM
// Design Name: 
// Module Name: mul_mux
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


module mul_mux  #(parameter ins_width = 32, ins_depth=19, pc_width = 5, opcode_width=7, r_width=5, fun1=3, fun2=7, immediate_len=12)
( 
input logic [3:0 ]ALU_control,
output logic [ins_width-1:0] alu_result_final,
input logic [ins_width-1:0] alu_1,mul_1       );
always_comb
begin
if (ALU_control==4'b1000||ALU_control==4'b1001)
begin
alu_result_final=mul_1;
end
else
begin
alu_result_final=alu_1;
end
end
endmodule
