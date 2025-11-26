module main_control(
    input  instr_t     op_i,
    input  logic [2:0] funct3_i,
    input  logic       Z_i,
    input  logic       SLT_i,
    
    output logic       pc_trg_src1_sel_o,
    output logic       pc_sel_o,
    output logic [1:0] result_sel_o,
    output logic [2:0] result_ext_o,
    output logic       dmem_en_o,
    output logic [2:0] dmem_in_ext_o,
    output logic [2:0] imm_src_o,
    output logic       rf_in_sel_o,
    output logic       rf_en_o 
);

always_comb begin
       pc_trg_src1_sel_o = 1'b0;    // pc_target DONT CARE
       pc_sel_o         = 1'b0;     // pc = pc + 4                    
       result_sel_o     = 2'b10;    // result = PC + 4             
       result_ext_o     = 3'b111;   // result will not be extended               
       dmem_en_o        = 1'b0;     // disable dmem                      
       dmem_in_ext_o  = 3'b111;    // dmem writing parts DOESNT MATTER             
       rf_in_sel_o      = 1'b0;     // RD <- Result         
       rf_en_o          = 1'b0;     // enable RF so rd <- PC + 4
        case (op_i)
            LOAD             : begin
                pc_trg_src1_sel_o = 1'b0;   // pc_target = DONT CARE
                pc_sel_o        = 1'b0;     // pc = pc + 4
                result_sel_o    = 2'b01;    // result = dmem_out
                dmem_en_o       = 1'b0;     // read from dmem
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER
                rf_in_sel_o     = 1'b0;     // choose result into RF 
                rf_en_o         = 1'b1;     // write loaded value onto rd          
                case (funct3_i)
                    3'd0: begin // lb (load byte)
                        result_ext_o    = 3'b000;   // result = 8bit_signextend(result)
                    end     
                    3'd1: begin // lh (load half)                    
                        result_ext_o    = 3'b001;   // result = 16bit_signextend(result)             
                    end
                    3'd2: begin // lw (load word)                  
                        result_ext_o    = 3'b111;   // result = result (no extend)             
                    end
                    3'd4: begin // lbu (load byte unsigned)                
                        result_ext_o    = 3'b010;   // result = 8bit_zeroextend(result)             
                    end
                    3'd5: begin // lhu (load half unsigned)
                        result_ext_o    = 3'b011;   // result = 16bit_zeroextend(result)             
                    end
                    default: begin // act as lw (load word)                      
                        result_ext_o    = 3'b111;    // result = result (no extend)             
                    end
                endcase
            end
            ARITHMETIC_IMM   : begin
                pc_trg_src1_sel_o = 1'b0;   // pc_target = DONT CARE
                pc_sel_o        = 1'b0;     // pc = pc + 4
                result_sel_o    = 2'b00;    // result = alu_out
                result_ext_o    = 3'b111;   // result = result (no extend) 
                dmem_en_o       = 1'b0;     // disable dmem
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER
                rf_in_sel_o     = 1'b0;     // choose result into RF 
                rf_en_o         = 1'b1;     // write ALU output onto rd          
            end
            ADD_UIMM         : begin        // solely for auipc
                pc_trg_src1_sel_o = 1'b0;   // DONT CARE 
                pc_sel_o        = 1'b0;     // pc = pc + 4
                result_sel_o    = 2'b00;    // result = alu result
                result_ext_o    = 3'b111;   // result = no extend
                dmem_en_o       = 1'b0;     // disable dmem
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER
                rf_in_sel_o     = 1'b0;     // choose result into rf
                rf_en_o         = 1'b1;     // enable rf     
            end
            STORE            : begin
                pc_trg_src1_sel_o = 1'b0;   // pc_target DONT CARE
                pc_sel_o        = 1'b0;     // pc = pc + 4
                result_sel_o    = 2'b01;    // result = dmem_out
                dmem_en_o       = 1'b1;     // write onto DMEM
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER
                rf_in_sel_o     = 1'b0;     // choose result into RF 
                rf_en_o         = 1'b0;     // disable writing into RF         
                case (funct3_i)
                    3'd0: begin // sb (store byte)
                        dmem_in_ext_o = 3'b000;    // dmem[addr] = sign extend rs2[7:0]
                    end     
                    3'd1: begin // sh (store half)                    
                        dmem_in_ext_o = 3'b001;    // dmem[addr] = sign extend rs2[15:0]
                    end
                    3'd2: begin // sw (store word)                  
                        dmem_in_ext_o = 3'b111;    // dmem[addr] = rs2
                    end
                    default: begin // act as sw                     
                        dmem_in_ext_o = 3'b111;    // dmem[addr] = rs2
                    end
                endcase
            end
            ARITHMETIC_REG   : begin
                pc_trg_src1_sel_o = 1'b0;   // pc_target DONT CARE
                pc_sel_o        = 1'b0;     // pc = pc + 4
                result_sel_o    = 2'b00;    // result = alu_out
                result_ext_o    = 3'b111;   // result = result (no extend) 
                dmem_en_o       = 1'b0;     // disable dmem
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER
                rf_in_sel_o     = 1'b0;     // choose result into RF 
                rf_en_o         = 1'b1;     // write ALU output onto rd          
            end
            LOAD_UIMM        : begin        // solely for lui
                pc_trg_src1_sel_o = 1'b0;   // pc_target DONT CARE
                pc_sel_o        = 1'b0;     // pc = pc + 4
                result_sel_o    = 2'b01;    // result = DONT CARE
                result_ext_o    = 3'b111;   // result = DONT CARE
                dmem_en_o       = 1'b0;     // disable dmem
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER
                rf_in_sel_o     = 1'b1;     // choose upperimm into RF 
                rf_en_o         = 1'b1;     // enable rf so it writes to rd   
                
            end
            BRANCH           : begin
               pc_trg_src1_sel_o = 1'b0;    // select PC as input to target adder
//             pc_sel_o         = ;         // pc logic handled below                    
               result_sel_o     = 2'b00;    // result = DONT CARE                
               result_ext_o     = 3'b111;   // result = DONT CARE                
               dmem_en_o        = 1'b0;     // disable dmem                      
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER  
                  
               rf_in_sel_o      = 1'b0;     // RF input doesnt matter          
               rf_en_o          = 1'b0;     // disable RF 
               
               case (funct3_i)
                    3'b000: pc_sel_o = Z_i;
                    3'b001: pc_sel_o = ~Z_i;
                    3'b100: pc_sel_o = SLT_i;
                    3'b101: pc_sel_o = ~SLT_i;
                    3'b110: pc_sel_o = SLT_i;
                    3'b111: pc_sel_o = ~SLT_i;
                    default: pc_sel_o = 0;
               endcase
                  
            end
            JUMP_AND_LINK_REG: begin        // solely for jalr
               if (funct3_i == 3'b000) begin    
                   pc_trg_src1_sel_o = 1'b1;    // pc_target first input = rs1
                   pc_sel_o         = 1'b1;     // pc = rs1 + immext                    
                   result_sel_o     = 2'b10;    // result = PC + 4             
                   result_ext_o     = 3'b111;   // result will not be extended               
                   dmem_en_o        = 1'b0;     // disable dmem                      
                    dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER               
                   rf_in_sel_o      = 1'b0;     // RD <- Result        
                   rf_en_o          = 1'b1;     // enable RF so rd <- PC + 4
               end
            end
            JUMP_AND_LINK    : begin        // solely for jal
               pc_trg_src1_sel_o = 1'b0;    // pc_target first input = pc
               pc_sel_o         = 1'b1;     // pc = pc + immext                    
               result_sel_o     = 2'b10;    // result = PC + 4             
               result_ext_o     = 3'b111;   // result will not be extended               
               dmem_en_o        = 1'b0;     // disable dmem                      
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER                
               rf_in_sel_o      = 1'b0;     // RD <- Result         
               rf_en_o          = 1'b1;     // enable RF so rd <- PC + 4
            end
            default: begin
               //$display("invalid opcode");
               pc_trg_src1_sel_o = 1'b0;    // pc_target DONT CARE
               pc_sel_o         = 1'b0;     // pc = pc + 4                    
               result_sel_o     = 2'b10;    // result = PC + 4             
               result_ext_o     = 3'b111;   // result will not be extended               
               dmem_en_o        = 1'b0;     // disable dmem                      
                dmem_in_ext_o = 3'b111;    // dmem writing parts DOESNT MATTER               
               rf_in_sel_o      = 1'b0;     // RD <- Result         
               rf_en_o          = 1'b0;     // enable RF so rd <- PC + 4
            end
        endcase
        
    end
    
always_comb begin

       imm_src_o        = 3'b100;   // immediate extension DONT CARE                   
        case (op_i)
            LOAD             : imm_src_o       = 3'b000;    // extend 12-bits of I-type immediate value  
            ARITHMETIC_IMM   : imm_src_o       = 3'b000;    // extend 12-bits of I-type immediate value                
            ADD_UIMM         : imm_src_o       = 3'b011;   // no extend, send upper immediate  
            STORE            : imm_src_o       = 3'b001;   // extend 12-bits of S-type immediate value (its divided)    
            ARITHMETIC_REG   : imm_src_o       = 3'b011;   // no extend, send upper immediate        
            LOAD_UIMM        : imm_src_o       = 3'b011;    // get upperimm             
            BRANCH           : imm_src_o        = 3'b010;    // extend 12-bits of B-type immediate value (its divided)                       
            JUMP_AND_LINK_REG: imm_src_o        = (funct3_i == 3'b000)  ? 3'b000 : 3'b100;   // extend 12-bits of I-type immediate value (its divided)                           
            JUMP_AND_LINK    : imm_src_o        = 3'b100;   // extend 12-bits of J-type immediate value (its divided)                        
            default: imm_src_o        = 3'b100;   // immediate extension DONT CARE                   
            
        endcase
        
    end

endmodule
