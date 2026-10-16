`timescale 1ns/1ps
module tb_alu;
    logic [3:0] control;
    logic [31:0] a,b,result;
    logic zero;
    ALU dut(.ALU_control(control),.data1(a),.data2(b),.dataW(result),.zero(zero));
    task automatic check(input logic [3:0] op, input logic [31:0] x,y,want);
      control=op; a=x; b=y; #1;
      if(result !== want) $fatal(1,"ALU op %h got %h expected %h",op,result,want);
    endtask
    initial begin
      check(2,32'hffffffff,1,0);
      check(6,5,5,0); if (!zero) $fatal(1,"Equality flag");
      check(3,32'hffffffff,0,1);
      check(10,32'hffffffff,0,0);
      check(11,32'h80000000,4,32'hf8000000);
      check(5,32'h80000000,4,32'h08000000);
      $display("PASS: ALU arithmetic, comparisons and shifts"); $finish;
    end
endmodule
