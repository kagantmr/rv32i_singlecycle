module register_file(
    input  logic [4:0]  addr1_i,
    input  logic [4:0]  addr2_i,
    input  logic [4:0]  addr3_i,
    input  logic [31:0] data_i,
    input  logic        wr_en_i,
    input  logic        rst_ni,
    input  logic        clk_i,
    output logic [31:0] data1_o,
    output logic [31:0] data2_o
    );
    
    logic [31:0] Q [31:0];
    
    always_comb begin

        
        data1_o = Q[addr1_i];
        data2_o = Q[addr2_i];
        
    end
    
    
    integer i;
    always_ff @(posedge clk_i) begin
        if (~rst_ni) begin
            for (i = 0; i < 32; i = i + 1) begin
                Q[i] <= 0;
            end
        end else begin
            Q[0] <= 0;
            if (wr_en_i & addr3_i != 0) begin
                Q[addr3_i] <= data_i;
            end
        end
    end
    
    
    
endmodule
