`timescale 1ns / 1ps

module Instruction_reg#(
    parameter ins_width = 32,
    parameter mem_size = 4096, 
    parameter pc_width = 32, 
    parameter opcode_width = 7, 
    parameter r_width = 5, 
    parameter fun1 = 3, 
    parameter fun2 = 7, 
    parameter immediate_len = 12
)(
    input logic [ins_width-1:0] old_pc,
    input logic [ins_width-1:0] instruction,
    input logic clock,
    input logic reset,
    input logic ins_write,
    output logic [ins_width-1:0] old_pc_output,
    output logic [ins_width-1:0] old_instruction,
    output logic [r_width-1:0] r1_out, 
    output logic [r_width-1:0] r2_out,
    output logic [r_width-1:0] rd_out,
    output logic [fun1-1:0] fun11_out,
    output logic [fun2-1:0] fun21_out,
    output logic [opcode_width-1:0] opcode_out
);

logic [ins_width-1:0] pc_store, ins_store;
logic [r_width-1:0] r1_store, r2_store, rd_store;
logic [fun1-1:0] fun11_store;
logic [fun2-1:0] fun21_store;
logic [opcode_width-1:0] opcode_store;

always_ff @(posedge clock or posedge reset) 
begin
    if (reset) 
    begin
        pc_store <= {ins_width{1'b0}};
        ins_store <= {ins_width{1'b0}};
        r1_store <= 0;
        r2_store <= 0;
        rd_store <= 0;
        fun11_store <= 0;
        fun21_store <= 0;
        opcode_store <= 0;
    end
    else if (ins_write)
    begin
        pc_store <= old_pc;             
        ins_store <= instruction;
        
        // Store ALL decoded fields to avoid stale values
        r1_store <= instruction[19:15];
        r2_store <= instruction[24:20];
        rd_store <= instruction[11:7];
        fun11_store <= instruction[14:12];
        fun21_store <= instruction[31:25];
        opcode_store <= instruction[6:0];
    end
end

// Output the STORED values, not combinational decodes
assign old_pc_output = pc_store;
assign old_instruction = ins_store;
assign r1_out = r1_store;
assign r2_out = r2_store;
assign rd_out = rd_store;
assign fun11_out = fun11_store;
assign fun21_out = fun21_store;
assign opcode_out = opcode_store;

endmodule