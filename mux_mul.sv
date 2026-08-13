`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 10:41:21 AM
// Design Name: 
// Module Name: Mul_output_mux
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


module Mul_output_mux #(parameter DATA_W = 32
)(
    
    input  logic [2:0]  fun11,         
    input logic [DATA_W-1:0] hi,      
    input logic [DATA_W-1:0] lo,
    output logic [DATA_W-1:0] out   
);
always_comb
begin
case (fun11)
3'b000:
out=lo;
3'b001:
out=hi;
3'b010:
 out=hi;
3'b011: 
out=hi;
3'b100: 
out=lo;
3'b101:
out=lo;
3'b110: 
out=lo;
3'b111: 
out=lo;
endcase
end 
endmodule
