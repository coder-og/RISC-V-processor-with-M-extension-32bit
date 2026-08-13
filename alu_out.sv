    `timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 11/10/2025 11:23:31 PM
    // Design Name: 
    // Module Name: ALU_output
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
    
    
    module ALU_output#(parameter ins_width = 32)(
     input logic [1:0] Alu_result,
     input logic [ins_width-1:0] result1,result2,result3,
     output logic [ins_width-1:0] ALU_output
        );
        always_comb
        begin
        case(Alu_result)
        2'b00:
        ALU_output=result1;
         2'b01:
        ALU_output=result2;//writeback form mem
         2'b10:
        ALU_output=result3;//writeback to pc+4 for next nis
        endcase
        end
    endmodule
