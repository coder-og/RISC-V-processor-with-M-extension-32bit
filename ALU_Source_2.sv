`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2025 05:25:37 PM
// Design Name: 
// Module Name: place_holder
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


module ALU_source2#( parameter ins_width = 32)(
    input logic [ins_width-1:0] data2,immediate, 
    input logic [1:0] Alu_source_2,
    output logic [ins_width-1:0] reg_2
    );
    always_comb
    begin
    if (Alu_source_2==2'b00)
    begin
    reg_2=data2;
    end
    else if (Alu_source_2==2'b01)
    begin
    reg_2=immediate;
    end
    else if (Alu_source_2==2'b10)
    begin
    reg_2=32'b100;
    end
    end
endmodule
