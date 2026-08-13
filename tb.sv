`timescale 1ns / 1ps

module tb_top_processor;

    // Testbench signals
    logic clock;
    logic reset;
    logic [31:0] instruction;
    logic [2:0] fun11;
    logic [31:0] mul_hi;
    logic [31:0] mul_lo;
    logic [31:0] alu_result;
    logic [4:0] rd;
    logic [4:0] r1;
    logic [4:0] r2;
    logic [31:0] pc, old_pc, old_instruction;

    // Instantiate the top_processor
    top_processor uut (
        .clock(clock),
        .reset(reset),
        .instruction(instruction),
        .fun11(fun11),
        .mul_hi(mul_hi),
        .mul_lo(mul_lo),
        .alu_result(alu_result),
        .rd(rd),
        .r1(r1),
        .r2(r2),
        .pc(pc), .old_pc(old_pc), .old_instruction(old_instruction)
    );

    // Clock generation: 10ns period
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // Test sequence
    initial begin
        // Initialize reset
        reset = 1;
        #20;
        reset = 0;

        // Run simulation for 200 ns
        #2500;

        // Finish simulation
        $finish;
    end

    // Monitor signals
    initial begin
        $display("Time\tPC\tInstruction\tALU_Result\tMul_HI\tMul_LO");
        $monitor("%0h\t%h\t%h\t%h\t%h\t%h",
                 $time, uut.pc, instruction, alu_result, mul_hi, mul_lo);
    end

endmodule
