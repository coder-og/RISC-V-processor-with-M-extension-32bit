`timescale 1ns / 1ps
module top_processor(
    input logic clock,
    input logic reset,
    output logic [31:0] instruction,
    output logic [2:0] fun11,
    output logic [31:0] mul_hi,
    output logic [31:0] mul_lo,
    output logic [31:0] alu_result,
    output logic [4:0] rd,
    output logic [4:0] r1,
    output logic [4:0] r2,
    output logic [31:0] pc, old_pc, old_instruction
);



logic ins_write, PC_write;
logic [6:0] fun21, opcode;
logic [31:0] data1, data2, old_data1, old_data2, immediate;
logic [1:0] Alu_source_1, Alu_source_2, Alu_result_sel, ALU_op;
logic [3:0] ALU_control;
logic [31:0] alu_final, alu_reg_out, write_back_data;
logic zero, memwrite, adress_source, branch, regwrite;
logic [31:0] mem_read, mem_address, alu_src1_out, alu_src2_out, stored_mem_read;
logic ALU_reg_write, mult_ready;
logic [31:0] mem_data_out, mul_result;


pc_reg pc_register(.next_pc(write_back_data), .clock(clock), .reset(reset), .PC_write(PC_write), .pc(pc));
adress_source_mux mem_addr_mux_inst(.pc_in(pc), .alu_result_in(alu_result), .adress_source(adress_source), .mem_address_out(mem_address));
Unified_Memory_1Port memory(.clock(clock), .memwrite(memwrite), .address(mem_address), .data_in(old_data2), .data_out(mem_data_out));
assign instruction = mem_data_out;
assign mem_read = mem_data_out;
Instruction_reg instr_reg(.old_pc(pc), .instruction(instruction), .clock(clock), .reset(reset), .ins_write(ins_write),.old_pc_output(old_pc), .old_instruction(old_instruction),.r1_out(r1), .r2_out(r2), .rd_out(rd), .fun11_out(fun11), .fun21_out(fun21), .opcode_out(opcode));
Control_unit control(.opcode(opcode), .fun21(fun21), .fun11(fun11), .clock(clock), .reset(reset), .zero(zero), .regwrite(regwrite), .ALU_op(ALU_op), .Alu_source_1(Alu_source_1), .Alu_source_2(Alu_source_2),.Alu_result(Alu_result_sel), .PC_write(PC_write), .ins_write(ins_write), .adress_source(adress_source), .memwrite(memwrite), .branch(branch), .mult_ready(mult_ready), .ALU_reg_write(ALU_reg_write));
immediate_gen imm_gen(.ins(old_instruction), .immediate(immediate));
reg_file registers(.r1(r1), .r2(r2), .rd(rd), .ALU_control(ALU_control), .hi(mul_hi), .lo(mul_lo), .dataW(write_back_data), .data1(data1), .data2(data2), .clock(clock), .regwrite(regwrite));
data_reg data_reg_inst(.data1(data1), .data2(data2), .clock(clock), .reset(reset), .old_data1(old_data1), .old_data2(old_data2));
ALU_source1 alu_src1(.data1(old_data1), .pc(pc), .old_pc(old_pc), .Alu_source_1(Alu_source_1), .reg_1(alu_src1_out));
ALU_source2 alu_src2(.data2(old_data2), .immediate(immediate), .Alu_source_2(Alu_source_2), .reg_2(alu_src2_out));
alu_control alu_ctrl(.ALU_op(ALU_op), .fun21(fun21), .fun11(fun11), .ALU_control(ALU_control));
ALU alu_inst(.ALU_control(ALU_control), .data1(alu_src1_out), .data2(alu_src2_out), .dataW(alu_reg_out), .zero(zero));
multiplication_module mult_inst(.clock(clock), .reset(reset), .ALU_control(ALU_control), .data1(old_data1), .data2(old_data2), .fun11(fun11), .hi(mul_hi), .lo(mul_lo), .mult_ready(mult_ready));
Mul_output_mux mul_out_inst(.fun11(fun11), .hi(mul_hi), .lo(mul_lo), .out(mul_result));
mul_mux mux_mul(.ALU_control(ALU_control), .alu_result_final(alu_final), .alu_1(alu_reg_out), .mul_1(mul_result));
single_result_reg alu_reg_inst(.clock(clock), .reset(reset), .data_in(alu_final), .write_enable(ALU_reg_write), .data_out(alu_result));
ALU_output alu_out(.Alu_result(Alu_result_sel), .result1(alu_result), .result2(stored_mem_read), .result3(alu_final), .ALU_output(write_back_data));
write_back_mem_reg wb_reg(.data(mem_read), .clock(clock), .reset(reset), .old_data1(stored_mem_read));

endmodule