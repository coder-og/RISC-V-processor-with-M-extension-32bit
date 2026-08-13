`timescale 1ns / 1ps

module adress_source_mux#(
    parameter ins_width = 32
)(
    input logic [ins_width-1:0] pc_in,         
    input logic [ins_width-1:0] alu_result_in, 
    input logic adress_source,                          
    output logic [ins_width-1:0] mem_address_out  
);

always_comb
begin
    case(adress_source)
        1'b0: mem_address_out = pc_in;
        1'b1: mem_address_out = alu_result_in;
        default: mem_address_out = pc_in; // Default to PC (fetch)
    endcase
end

endmodule