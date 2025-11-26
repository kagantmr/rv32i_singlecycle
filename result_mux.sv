module result_mux(
    input  logic [31:0] aluresult_i,
    input  logic [31:0] dmem_out_i,
    input  logic [31:0] pc_p4_i,
    input  logic [1:0]  sel_i,
    output logic [31:0] result_o
    );
    
    always @* begin
        case (sel_i)
            2'b00: result_o = aluresult_i;
            2'b01: result_o = dmem_out_i;
            2'b10: result_o = pc_p4_i;
            2'b11: result_o = pc_p4_i;
        endcase
    end
endmodule
