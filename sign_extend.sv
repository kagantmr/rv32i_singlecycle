module sign_extend(
    input  logic [31:7]  data_i,
    input  logic [2:0]   sel_i,
    output logic [31:0]  ext_data_o
);
    always @* begin
        case (sel_i)
            3'b000: ext_data_o = {{20{data_i[31]}}, data_i[31:20]};                                     // I-type extend
            3'b001: ext_data_o = {{20{data_i[31]}}, data_i[31:25], data_i[11:7]};                       // S-type extend
            3'b010: ext_data_o = {{20{data_i[31]}}, data_i[7], data_i[30:25], data_i[11:8], 1'b0};      // B-type extend
            3'b011: ext_data_o = {data_i[31:12], 12'b0};                                                // U-type "extend"
            3'b100: ext_data_o = {{12{data_i[31]}}, data_i[19:12], data_i[20], data_i[30:21], 1'b0};    // J-type extend
            default: ext_data_o = 'b0;
        endcase
    end

endmodule
