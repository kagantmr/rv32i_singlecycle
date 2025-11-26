module control_unit(
    input  instr_t     op_i,
    input  logic [2:0] funct3_i,
    input  logic       funct75_i,
    input  logic       Z_i,
    input  logic       SLT_i,
    
    output logic       pc_trg_src1_sel_o,
    output logic       pc_sel_o,
    output logic [1:0] result_sel_o,
    output logic [2:0] result_ext_o,
    output logic       dmem_en_o,
    output logic [2:0] dmem_in_ext_o,
    output logic [3:0] ALU_sel_o,
    output logic       ALU_src1_sel_o,
    output logic       ALU_src2_sel_o,
    output logic [2:0] imm_src_o,
    output logic       rf_in_sel_o,
    output logic       rf_en_o 
);
    
    ALU_control ALUDECODER(
        .op_i(op_i),
        .funct3_i(funct3_i),
        .funct75_i(funct75_i),
        .ALU_src1_sel_o(ALU_src1_sel_o),
        .ALU_src2_sel_o(ALU_src2_sel_o),
        .ALU_sel_o(ALU_sel_o)
    );

    main_control MAINDECODER(
        .op_i           (op_i),
        .funct3_i        (funct3_i),
        .Z_i              (Z_i),
        .SLT_i            (SLT_i),
        .pc_trg_src1_sel_o(pc_trg_src1_sel_o),
        .pc_sel_o         (pc_sel_o),
        .result_sel_o    (result_sel_o),
        .result_ext_o     (result_ext_o),
        .dmem_en_o       (dmem_en_o),
        .dmem_in_ext_o  (dmem_in_ext_o),
        .imm_src_o        (imm_src_o),
        .rf_in_sel_o      (rf_in_sel_o),
        .rf_en_o           (rf_en_o)
    );
    
endmodule
