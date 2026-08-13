`timescale 1ns / 1ps

module Control_unit#(
    parameter ins_width = 32, 
    parameter ins_depth=19, 
    parameter pc_width = 32, 
    parameter opcode_width=7, 
    parameter r_width=5, 
    parameter fun1=3, 
    parameter fun2=7, 
    parameter immediate_len=12
)(
    input logic mult_ready,
    input logic [opcode_width-1:0] opcode,
    input logic [fun2-1:0] fun21, // funct7
    input logic [fun1-1:0] fun11, // funct3
    input logic clock,
    input logic reset,
    input logic zero,
    output logic regwrite,
    output logic [1:0 ]ALU_op,
    output logic [1:0] Alu_source_1,
    output logic [1:0] Alu_source_2,
    output logic [1:0] Alu_result,
    output logic PC_write,
    output logic ins_write,
    output logic adress_source,
    output logic memwrite,
    output logic branch,
    output logic ALU_reg_write
);

    logic pc_update;
    typedef enum logic [3:0] {
        fetch,
        decode,
        mem_read,
        mem_write,
        mem_adress,
        exec_r,
        exec_m,
        exec_i,
        alu_wb,
        beq,
        jal,
        mem_to_reg,
        beq_last
    } state_t; 
    
    state_t state, next; 
    
    always_comb begin
        ins_write = 0;
        adress_source = 0;
        regwrite = 0;
        memwrite = 0;
        ALU_op = 2'b00;
        Alu_source_1 = 2'b00;
        Alu_source_2 = 2'b00;
        Alu_result = 2'b00;
        PC_write = 0;
        pc_update = 0;
        branch = 0;
        ALU_reg_write = 0;

        case(state)
            fetch: 
            begin
                ins_write = 1;
                adress_source = 0;
                pc_update = 1;
                Alu_result = 2'b10; 
                Alu_source_1 = 2'b00; // PC
                Alu_source_2 = 2'b10; // 4
                ALU_op = 2'b00; 
                ALU_reg_write = 1;
            end
            
            decode: 
            begin
                ALU_op = 2'b00;       
                Alu_source_1 = 2'b01; // old_pc
                Alu_source_2 = 2'b01; // immediate
                ALU_reg_write = 1;
            end
            
            mem_adress:
            begin
                ALU_op = 2'b00;
                Alu_source_1 = 2'b10; // rs1
                Alu_source_2 = 2'b01; // immediate
                Alu_result = 2'b00;
                ALU_reg_write = 1;
            end
            
            mem_read:
            begin
                Alu_result = 2'b00;
                adress_source = 1;
            end
            
            exec_r:
            begin
                ALU_op = 2'b10;
                Alu_source_1 = 2'b10; // rs1
                Alu_source_2 = 2'b00; // rs2
                ALU_reg_write = 1;
            end
            
            exec_i:
            begin
                ALU_op = 2'b10;
                Alu_source_1 = 2'b10; // rs1
                Alu_source_2 = 2'b01; // immediate
                ALU_reg_write = 1;
            end
            
         // --- Modified signals inside exec_m state ---
exec_m:
begin
    ALU_op = 2'b10;
    Alu_source_1 = 2'b10; // rs1
    Alu_source_2 = 2'b00; // rs2
    Alu_result = 2'b00;  
    
  
    if (mult_ready) begin
        ALU_reg_write = 1;  
    end else begin
        ALU_reg_write = 0; // Hold the register enable low while busy
    end
end
            jal:
            begin
                ALU_op = 2'b00;   
                Alu_source_1 = 2'b01; // old_pc
                Alu_source_2 = 2'b10; // 4
                ALU_reg_write = 1;  
                Alu_result = 2'b00;
                PC_write = 1;
            end
            
            alu_wb:
            begin
                Alu_result = 2'b00;
                regwrite = 1;  
            end
            
            mem_to_reg:
            begin
                Alu_result = 2'b01;
                regwrite = 1; 
            end
            
            mem_write:
            begin
                adress_source = 1;
                memwrite = 1;
                Alu_result = 2'b00;
            end
            
            beq: 
            begin
                ALU_op = 2'b01;   
                Alu_source_1 = 2'b10; // rs1
                Alu_source_2 = 2'b00; // rs2
                if (zero) begin
                    branch = 1; 
                end
            end
        endcase
        
        PC_write = (zero && branch) || (state == jal) || pc_update;
        
        if (state == jal || (zero && branch))
            Alu_result = 2'b00; 
        else if (pc_update)
            Alu_result = 2'b10; 
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            state <= fetch;
        else 
            state <= next;
    end
    
    always_comb begin
        case(state)
            fetch:
                next = decode;
                
            decode:
                case(opcode)
                    7'b0110011: 
                        if (fun21 == 7'b0000001)
                            next = exec_m;
                        else
                            next = exec_r;
                    7'b0010011: 
                        next = exec_i;
                    7'b0000011:
                        next = mem_adress;
                    7'b0100011:
                        next = mem_adress;
                    7'b1101111:
                        next = jal;
                    7'b1100011:
                        next = beq;
                    default: next = fetch;
                endcase
                
            mem_adress:
                case(opcode)
                    7'b0000011:
                        next = mem_read;
                    7'b0100011:
                        next = mem_write;
                    default: next = fetch;
                endcase
                
            mem_read:
                next = mem_to_reg;
                
            mem_write:
                next = fetch;
                
            exec_r:
                next = alu_wb;
                
            exec_i:
                next = alu_wb;
                
            jal:
                next = alu_wb;
                
            alu_wb:
                next = fetch; 
                
            beq:
                next = fetch;
                
            mem_to_reg:
                next = fetch;
                
            exec_m:
                if (mult_ready)
                    next = alu_wb;
                else
                    next = exec_m;
                    
            default: next = fetch;
        endcase
    end
endmodule