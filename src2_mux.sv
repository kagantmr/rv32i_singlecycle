module src2_mux(
    input  logic [31:0] immext_i,
    input  logic [31:0] rd2_i,
    input  logic        sel_i,
    output logic [31:0] src2_o
    );
    
    assign src2_o = sel_i ? immext_i : rd2_i;
endmodule
