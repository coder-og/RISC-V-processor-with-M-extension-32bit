`timescale 1ns/1ps
module tb_regfile;
    logic clock=0, regwrite=0;
    logic [4:0] rd=0, r1=0, r2=1;
    logic [31:0] dataW=0, data1, data2;
    always #5 clock=~clock;
    reg_file dut(.clock(clock), .regwrite(regwrite), .rd(rd), .r1(r1), .r2(r2),
      .dataW(dataW), .data1(data1), .data2(data2), .ALU_control(4'b0), .hi(32'b0), .lo(32'b0));
    initial begin
        @(negedge clock); regwrite=1; rd=0; dataW=32'hffffffff;
        @(negedge clock);
        if (data1 !== 0) $fatal(1, "x0 accepted a write");
        rd=1; dataW=32'h12345678;
        @(negedge clock); regwrite=0;
        if (data2 !== 32'h12345678) $fatal(1, "x1 write/read failed");
        $display("PASS: x0 invariant and register write/read"); $finish;
    end
endmodule
