module rf_datain_mux(
    input  logic [31:0]  result_ext_i,
    input  logic [31:0]  imm_ext_i   ,
    input  logic         sel_i       ,
    output logic [31:0]  rf_data_in_o
    );
    
    assign rf_data_in_o = sel_i ? imm_ext_i : result_ext_i;
endmodule
