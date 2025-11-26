typedef enum logic [6:0] {
        LOAD                = 7'd3,
        ARITHMETIC_IMM      = 7'd19,
        ADD_UIMM            = 7'd23,
        STORE               = 7'd35,
        ARITHMETIC_REG      = 7'd51,
        LOAD_UIMM           = 7'd55,
        BRANCH              = 7'd99,
        JUMP_AND_LINK_REG   = 7'd103,
        JUMP_AND_LINK       = 7'd111
} instr_t;


module ALU_control(
    input  instr_t     op_i,
    input  logic [2:0] funct3_i,
    input  logic       funct75_i,

    output logic       ALU_src1_sel_o,    
    output logic       ALU_src2_sel_o,
    output logic [3:0] ALU_sel_o

);

    always_comb begin
        ALU_sel_o       = 4'b0000;
        ALU_src1_sel_o   = 1'b0;     // ALU first input DONT CARE
        ALU_src2_sel_o   = 1'b0;     // ALU second input DONT CARE
        case (op_i)
            LOAD, STORE             : begin
                ALU_src1_sel_o   = 1'b0;     // ALU first input is rs1
                ALU_sel_o       = 4'b0000;  // add immediate to register
                ALU_src2_sel_o   = 1'b1;     // ALU second input = immediate     
            end
            ARITHMETIC_IMM   : begin
                ALU_src2_sel_o   = 1'b0;     // ALU first input is rs1
                ALU_src2_sel_o   = 1'b1;     // ALU second input = immediate
                case (funct3_i)
                    3'd0: begin // addi (add immediate)
                        ALU_sel_o       = 4'b0000;  // add
                    end     
                    3'd1: begin // slli (shift left logical immediate)
                        if (~funct75_i)             // for some reason it needs this
                        ALU_sel_o       = 4'b0010;      // shift left logical, uimm = imm[4:0] already handled by ALU           
                    end
                    3'd2: begin // slti (set less than immediate)                  
                        ALU_sel_o       = 4'b0011;  // set less than immediate SIGNED, signed comparison handled by ALU            
                    end
                    3'd3: begin // sltiu (set less than immediate unsigned)                  
                        ALU_sel_o       = 4'b0100;  // set less than immediate unsigned, unsigned comparison handled by ALU              
                    end
                    3'd4: begin // xori (xor immediate)                
                        ALU_sel_o       = 4'b0101;  // xor            
                    end
                    3'd5: begin // srli / srai (shift right logical/arithmetic immediate)
                        ALU_sel_o       = {3'b011, funct75_i};  // shift right logical / arithmetic, uimm = imm[4:0] already handled by ALU   
                    end
                    3'd6: begin // ori (or immediate)
                        ALU_sel_o       = 4'b1000;  // or           
                    end
                    3'd7: begin // andi (and immediate)
                        ALU_sel_o       = 4'b1001;  // and               
                    end
                    default: ALU_sel_o       = 4'b1001;  // and 
               endcase
            end
            ADD_UIMM: begin
               ALU_src1_sel_o   = 1'b1;     // ALU first  input = PC
               ALU_sel_o        = 4'b0000;  // ALU operation add
               ALU_src2_sel_o   = 1'b1;     // ALU second input = immediate
            end
            LOAD_UIMM : begin
               ALU_src1_sel_o   = 1'b0;     // ALU first  input = DONT CARE
               ALU_sel_o        = 4'b0000;  // ALU operation add
               ALU_src2_sel_o   = 1'b1;     // ALU second input = immediate
            end
            ARITHMETIC_REG   : begin
                ALU_src1_sel_o   = 1'b0;     // ALU first  input is rs1
                ALU_src2_sel_o   = 1'b0;     // ALU second input is rs2
                case (funct3_i)
                    3'd0: begin // add / sub (add /subtract immediate)
                        ALU_sel_o       = {3'b000, funct75_i};  // add/sub
                    end     
                    3'd1: begin // sll (shift left logical)
                        if (~funct75_i)                 // for some reason it needs this
                        ALU_sel_o       = 4'b0010;      // shift left logical, rs2[4:0] already handled by ALU            
                    end
                    3'd2: begin // slt (set less than)
                        if (~funct75_i)                  
                        ALU_sel_o       = 4'b0011;  // set less than immediate SIGNED, signed comparison handled by ALU            
                    end
                    3'd3: begin // sltu (set less than unsigned)
                        if (~funct75_i)                 
                        ALU_sel_o       = 4'b0100;  // set less than immediate unsigned, unsigned comparison handled by ALU              
                    end
                    3'd4: begin // xor (xor)
                        if (~funct75_i)                
                        ALU_sel_o       = 4'b0101;  // xor            
                    end
                    3'd5: begin // srl / sra (shift right logical/arithmetic)
                        ALU_sel_o       = {3'b011, funct75_i};  // shift right logical / arithmetic, rs2[4:0] already handled by ALU   
                    end
                    3'd6: begin // ori (or )
                        if (~funct75_i)
                        ALU_sel_o       = 4'b1000;  // or           
                    end
                    3'd7: begin // and (and )
                        if (~funct75_i)
                        ALU_sel_o       = 4'b1001;  // and               
                    end
               endcase
            end
            BRANCH           : begin
               ALU_src1_sel_o   = 1'b0;     // ALU first  input = rs1
               ALU_src2_sel_o   = 1'b0;     // ALU second input = rs2         
               case (funct3_i)
                    3'b000: ALU_sel_o        = 4'b0001;  // sub                 - bEQ   
                    3'b001: ALU_sel_o        = 4'b0001;  // sub                 - bNE
                    3'b100: ALU_sel_o        = 4'b0011;  // slt signed          - bLT
                    3'b101: ALU_sel_o        = 4'b0011;  // slt signed          - bGE
                    3'b110: ALU_sel_o        = 4'b0100;  // slt unsigned        - bLTU
                    3'b111: ALU_sel_o        = 4'b0100;  // slt unsigned        - bGEU
                    default: ALU_sel_o        = 4'b0001;  // sub                - bNE
               endcase
                  
            end
            JUMP_AND_LINK, JUMP_AND_LINK_REG: begin
                ALU_src1_sel_o   = 1'b0;     // ALU first  input = rs1
                ALU_src2_sel_o   = 1'b0;     // ALU second input DONT CARE
                ALU_sel_o        = 4'b0000;  // ALU operation DONT CARE 
            end
            default: begin 
               ALU_sel_o        = 4'b0000;  // ALU operation DONT CARE  
            end
        endcase
    end
endmodule
