`timescale 1ns / 1ps
module alu_control#(
  parameter ins_width = 32, 
  parameter fun1 = 3, 
  parameter fun2 = 7
)( 
  input logic [1:0] ALU_op,
  input logic [fun2-1:0] fun21, 
  input logic [fun1-1:0] fun11, 
  output logic [3:0] ALU_control
);

always_comb begin
  
  ALU_control = 4'b0010; 

  case (ALU_op)
    2'b00: ALU_control = 4'b0010; 
    2'b01: ALU_control = 4'b0110; 
    
    2'b10: begin 
      case (fun21)
      
        7'b0000000: begin
          case (fun11)
            3'b000: ALU_control = 4'b0010; // ADD
            3'b001: ALU_control = 4'b0100; // SLL
            3'b010: ALU_control = 4'b0011; // SLT
            3'b011: ALU_control = 4'b1010; // SLTU
            3'b100: ALU_control = 4'b0111; // XOR
            3'b101: ALU_control = 4'b0101; // SRL
            3'b110: ALU_control = 4'b0001; // OR
            3'b111: ALU_control = 4'b0000; // AND
            default: ALU_control = 4'b0010;
          endcase
        end

        // SUB and SRA
        7'b0100000: begin
          case (fun11)
            3'b000: ALU_control = 4'b0110; 
            3'b101: ALU_control = 4'b1011; 
            default: ALU_control = 4'b0010;
          endcase
        end

        // MUL, DIV, REM
        7'b0000001: begin
          case (fun11)
            3'b000: ALU_control = 4'b1000; // MUL
            3'b001: ALU_control = 4'b1000; // MULH
            3'b010: ALU_control = 4'b1000; // MULHSU
            3'b011: ALU_control = 4'b1000; // MULHU
            3'b100: ALU_control = 4'b1001; // DIV
            3'b101: ALU_control = 4'b1001; // DIVU
            3'b110: ALU_control = 4'b1001; // REM
            3'b111: ALU_control = 4'b1001; // REMU
            default: ALU_control = 4'b0010;
          endcase
        end 
        
   
        default: begin 
          case (fun11)
            3'b000: ALU_control = 4'b0010; 
            3'b010: ALU_control = 4'b0011; 
            3'b011: ALU_control = 4'b1010; 
            3'b100: ALU_control = 4'b0111; 
            3'b110: ALU_control = 4'b0001; 
            3'b111: ALU_control = 4'b0000; 
            3'b001: ALU_control = 4'b0100; 
            3'b101: begin 
              if (fun21 == 7'b0100000)
                ALU_control = 4'b1011; 
              else
                ALU_control = 4'b0101; 
            end
            default: ALU_control = 4'b0010;
          endcase
        end
      endcase
    end
    
  endcase
end

endmodule
