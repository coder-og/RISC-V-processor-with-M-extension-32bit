`timescale 1ns / 1ps

module ALU_source1#( parameter ins_width = 32)(
    input logic [ins_width-1:0] data1,pc,old_pc, 
    input logic [1:0] Alu_source_1,
    output logic [ins_width-1:0] reg_1
    );
    always_comb
    begin
    if (Alu_source_1==2'b00)
    begin
    reg_1=pc;
    end
    else if (Alu_source_1==2'b01)
    begin
    reg_1=old_pc;
    end
    else if (Alu_source_1==2'b10)
    begin
    reg_1=data1;
    end
    end
endmodule
