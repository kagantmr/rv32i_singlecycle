module src1_mux(
    input  logic [31:0] rf_out1_i,
    input  logic [31:0] pc_i,
    input  logic        sel_i,
    output logic [31:0] src1_o
    );
    
    assign src1_o = sel_i ? pc_i : rf_out1_i;
endmodule
