`timescale 1ns / 1ps
module write_back_mem_reg#( parameter ins_width = 32)(
    input logic [ins_width-1:0] data, 
    input logic clock,
    input logic reset,
    output logic [ins_width-1:0] old_data1
);
logic [ins_width-1:0] store;
always_ff @ (posedge clock or posedge reset)
begin
if (reset)
begin
store<=32'b0;
end
else
begin
store<=data;
end
end
assign old_data1=store;

endmodule
