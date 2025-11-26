module sign_extend_loadstore(
    input  logic [31:0]  data_i,
    input  logic [2:0]   sel_i,
    output logic [31:0]  ext_data_o
);
    always @* begin
        case (sel_i)
            3'b000: ext_data_o = {{24{data_i[7]}}, data_i[7:0]};    // BYTE SIGN_EXTEND
            3'b001: ext_data_o = {{16{data_i[15]}}, data_i[15:0]};  // HWORD SIGN_EXTEND
            3'b010: ext_data_o = {24'b0, data_i[7:0]};             // BYTE ZERO_EXTEND
            3'b011: ext_data_o = {16'b0, data_i[15:0]};            // HWORD ZERO_EXTEND
            default: ext_data_o = data_i;
        endcase
    end

endmodule
