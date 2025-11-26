module pctarget_mux(
    input  logic [31:0] pc_i,
    input  logic [31:0] rf_rd1_i,
    input  logic        sel_i,
    output logic [31:0] pctarget_src1_o
    );
    
    assign pctarget_src1_o = sel_i ? rf_rd1_i : pc_i;
endmodule
