`timescale 1ns / 1ps

module multiplication_module #(parameter DATA_W = 32
)(
  
    input  logic                clock,
    input  logic                reset, 
    
    input  logic [3:0]          ALU_control,  // From Control Unit
    input  logic [DATA_W-1:0]   data1,       // Multiplicand (M)
    input  logic [DATA_W-1:0]   data2,       // Multiplier (Q)
    input  logic [2:0]          fun11,       // funct3
    output logic [DATA_W-1:0]   hi,          // High 32 bits of result
    output logic [DATA_W-1:0]   lo,          // Low 32 bits of result
    output logic               mult_ready   
);
    typedef enum logic [1:0] {
        IDLE,
        BUSY,
        DONE
    } state_t;

    state_t state, next_state;

    logic dividend_sign_reg;
    logic [63:0] product_reg;  
    logic [DATA_W-1:0]   m_reg, p_reg;        
    logic [5:0]          count_reg;    
    logic [2:0]          fun11_reg;   
    logic f_sign;
    logic a_data1;
    logic a_data2;
    logic [63:0] temp_product;
    logic [63:0] temp_product_2;
    logic is_div,zero_div;
    logic [31:0] rem_reg; 
    logic [31:0] temp_rem;
     logic [63:0] shifted_aq;

    logic is_mul;
     
    // ADD THESE REGISTERED SIGNALS
    logic is_mul_reg;
    logic is_div_reg;
    logic [3:0] alu_control_reg;  // NEW: Register the actual control value


    always_comb
    begin
    if (ALU_control==4'b1000)
    begin
    is_mul=1'b1;
    end
    else
    begin
    is_mul=0;
    end
    if (ALU_control==4'b1001)
    begin
    is_div=1;
    end
    else
    begin
    is_div=0;
    end
    end
   


    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always_comb begin
        next_state = state;
        case(state)
          //////////////////////////////////////////////////////////////////////////////
            IDLE: begin
            if (is_mul) begin
                next_state = BUSY;
            end
            else if (is_div) begin
                if (data2 == 32'b0) 
                    next_state = DONE; 
                else
                    next_state = BUSY; 
            end
            else begin
                next_state = IDLE;
            end
        end 
              //////////////////////////////////////////////////////////////////////////////
          BUSY: begin
              // FIXED: Use registered signals instead of combinational
              if ((is_mul_reg && count_reg == 6'd31) || (is_div_reg && count_reg == 6'd31))
              begin
                  next_state = DONE;             
              end
              else
              begin
                  next_state = BUSY; 
              end
          end
            DONE: begin
                    next_state = IDLE; 
                end
             default: next_state = IDLE;
        endcase
    end


    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
           
            count_reg <= 0;
            m_reg <= 0;
            product_reg <= 0;
            fun11_reg <= 0;
            f_sign<=0;
             temp_product_2<=0;
             zero_div<=0;
             // ADD THESE
             is_mul_reg <= 0;
             is_div_reg <= 0;
             alu_control_reg <= 0;  // Reset
            
        end
        
        else begin
            case(state)
                IDLE: begin
                                    count_reg <= 0; 
                                    zero_div <= 0;
                                    fun11_reg <= fun11;  // Move here
                                    alu_control_reg <= ALU_control;  // NEW: Register the control signal

                    if (is_mul) begin
                        logic sign1;
                        logic sign2;
                        
                     	sign1 = data1[31];
                      	sign2 = data2[31];
                      	zero_div <= 1'b0;
                       	if (fun11==3'b010) 
                      	begin
                      	    f_sign <= sign1;
                      	    
                      	    if (sign1) 
                      	    begin
                      	        m_reg <= -data1; 
                      	    end
                      	    else 
                      	    begin
                      	        m_reg <= data1; 
                      	     end
                      	 product_reg <= {32'b0, data2}; 
                      	end
                      	else if (fun11==3'b001) 
                      	begin
                      	    f_sign <= sign1 ^ sign2;
                      	    
                      	    if (sign1) 
                      	        m_reg <= -data1; 
                      	    else 
                      	        m_reg <= data1;
                     	    
                      	    if (sign2) 
                      	        product_reg <= {32'b0, -data2}; 
                      	    else 
                      	        product_reg <= {32'b0, data2};
                  	end
                      	else 
                      	begin
                      	f_sign <= 1'b0; 
                   	    m_reg <= data1;
                      	product_reg <= {32'b0, data2};
                      	fun11_reg <= fun11;
                  	end
                       // CAPTURE OPERATION TYPE
                       is_mul_reg <= 1;
                       is_div_reg <= 0;
                 end  // end for is_mul
                    else if (is_div)
                    begin
                    
                        logic sign1;
                        logic sign2;
                   
                     	sign1 = data1[31];
                      	sign2 = data2[31];
                        rem_reg <= 32'b0;
                        dividend_sign_reg <= sign1; 
                	    if (data2==0)
                	    begin
                	    zero_div<=1;
                	    end
                	   if (fun11 == 3'b100) begin 
                         f_sign <= sign1 ^ sign2; 
                         if (sign1) begin
                            product_reg <= {32'b0, -data1};
                        end else begin
                        product_reg <= {32'b0, data1};
                        end
                        if (sign2) begin
                        m_reg <= -data2; 
                        end else begin
                        m_reg <= data2;
                        end
                    end else begin 
                    f_sign <= 0;
                    product_reg <= {32'b0, data1}; 
                    m_reg <= data2;
                    end
                       // CAPTURE OPERATION TYPE
                       is_mul_reg <= 0;
                       is_div_reg <= 1;
                 end  // end for is_div
                    else begin  // NEW: Reset when no operation
                        is_mul_reg <= 0;
                        is_div_reg <= 0;
                        alu_control_reg <= 0;
                    end
               end  // end for IDLE case
            	
                               
                BUSY:
                begin
                if (is_mul_reg)  // FIXED: Use registered signal
                begin
                 
                    if (product_reg[0])
                     begin   
                        temp_product = {product_reg[63:32] + m_reg, product_reg[31:0]};
                    end
                    else
                    begin  
                        temp_product = product_reg;
                    end
                    product_reg <= temp_product >> 1;
                    count_reg <= count_reg + 1; 
                end
              else if (is_div_reg)  // FIXED: Use registered signal
                    begin
                  
                    shifted_aq = product_reg << 1;         	    
                    temp_rem = shifted_aq[63:32] - m_reg;
    
                    if (temp_rem[31]) begin
                      product_reg <= shifted_aq; 
                        end
                    else begin
                  product_reg <= {temp_rem, shifted_aq[31:1], 1'b1};

                     end
                    count_reg <= count_reg + 1; 
                    end
          	 end  // end for BUSY case
                
               

                
                
                
               DONE:
                begin
                 count_reg <= 0; 
                 is_mul_reg <= 0;     // Reset
                 is_div_reg <= 0;
                 alu_control_reg <= 0;  // Reset

                end
           
           endcase 
        end 
    end  

               
always_comb
begin
    
    mult_ready = 0;
    lo = 0;
    hi = 0;
    
    if (state==DONE)
    begin
        mult_ready = 1;
        // FIXED: Use registered operation type
        if (alu_control_reg == 4'b1000)  // Use registered version
        begin
        begin
        if (f_sign==0)
        begin
            lo = product_reg[31:0];
            hi = product_reg[63:32]; 
        end
        else
        begin
            temp_product_2 = -product_reg;
            lo = temp_product_2[31:0];
            hi = temp_product_2[63:32]; 
        end
        end
        end
       else if (alu_control_reg == 4'b1001) begin  // FIXED: Use registered signal
            hi = 32'b0; 
            if (zero_div) begin
                case(fun11_reg)
                    3'b100: lo = -1; 
                    3'b101: lo = -1; 
                    3'b110: lo = product_reg[31:0];  // Use latched dividend (was data1)        
                    3'b111: lo = product_reg[31:0];  // Use latched dividend (was data1)
                endcase
            end
                   
            else begin
                case(fun11_reg)
                    3'b100: begin // DIV: Signed Quotient
                        if (f_sign) begin
                            temp_product_2 = -product_reg[31:0]; 
                            lo = temp_product_2[31:0];
                        end
                        else begin
                            lo = product_reg[31:0];
                        end
                    end
                    3'b101: begin
                        lo = product_reg[31:0];
                    end
                    
                    3'b110: begin
                      
                        if (dividend_sign_reg) begin
                            temp_product_2 = -product_reg[63:32];
                            lo = temp_product_2[31:0];
                        end
                        else begin
                            lo = product_reg[63:32];
                        end
                    end
                    
                    3'b111: begin
                        lo = product_reg[63:32];
                    end
                    
                    default: lo = 32'b0;
  
                endcase
            end
        end
    end
end
always_ff @(posedge clock) begin
    if (state == DONE && is_mul_reg) begin
        $display("DEBUG MUL: data1=%h data2=%h HI=%h LO=%h", data1, data2, hi, lo);
    end
end

endmodule