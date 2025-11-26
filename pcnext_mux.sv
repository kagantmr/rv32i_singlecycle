module pcnext_mux(
    input  logic [31:0] pc_target_i,
    input  logic [31:0] pc_p4_i,
    input  logic        sel_i,
    output logic [31:0] pc_next_o
    );
    
    assign pc_next_o = sel_i ? pc_target_i : pc_p4_i;
endmodule
