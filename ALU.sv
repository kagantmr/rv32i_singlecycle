module ALU(
    input  logic [31:0]  src1_i,
    input  logic [31:0]  src2_i,
    input  logic [3:0]   sel_i,
    output logic         Z_o,
    output logic [31:0] result_o
    );
    
    wire signed [31:0] src1_s, src2_s;

    assign src1_s = src1_i;
    assign src2_s = src2_i;
    
    always @* begin
        case (sel_i)
            4'b0000: result_o = src1_i + src2_i;               // add
            4'b0001: result_o = src1_i - src2_i;               // sub
            4'b0010: result_o = src1_i << src2_i[4:0];         // sll
            4'b0011: result_o = {31'b0, (src1_s < src2_s)};           // slt signed
            4'b0100: result_o = {31'b0, (src1_i < src2_i)};    // slt unsigned
            4'b0101: result_o = src1_i ^ src2_i;               // xor
            4'b0110: result_o = src1_i >>  src2_i[4:0];        // srl
            4'b0111: result_o = src1_s >>> src2_i[4:0];        // sra
            4'b1000: result_o = src1_i | src2_i;               // or
            4'b1001: result_o = src1_i & src2_i;               // and
            default: result_o = src1_i;                        // send src1 only
        endcase
    end
    
    assign Z_o = (result_o == 0);
endmodule


