`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module immediate_gen#(
    parameter ins_width = 32, 
    ins_depth=19, 
    pc_width = 5, 
    opcode_width=7, 
    r_width=5, 
    fun1=3, 
    fun2=7, 
    immediate_len=12
)(
    input logic [ins_width-1:0] ins,
    output logic [ins_width-1:0] immediate
);

always_comb
begin
    if (ins[6:0]==7'b0100011) 
    begin 
        immediate = {{20{ins[31]}}, ins[31:25], ins[11:7]};
    end
    else if (ins[6:0]==7'b1100011) // branch
    begin
        immediate = {{19{ins[31]}}, ins[31], ins[7], ins[30:25], ins[11:8], 1'b0};
    end
    else if (ins[6:0]==7'b1101111)//jump
    begin
   immediate = {{11{ins[31]}}, ins[31], ins[19:12],ins[20],ins[30:21],1'b0};           

    end
    else // load / I-type
    begin
        immediate = {{20{ins[31]}}, ins[31:20]};
    end
end

endmodule
