module data_memory #(
    parameter size = 16,
    parameter DMemInitFile  = "dmem.mem" 
)(
    input  logic        clk_i,
    input  logic [31:0] addr_i,
    input  logic [31:0] data_i,
    input  logic        wr_en_i,
    output logic [31:0] data_o
    );
    
    reg [31:0] DMEM_Q [0:size - 1];
    
    initial begin
        $readmemh(DMemInitFile, DMEM_Q);
    end
    
    
    always_ff @(posedge clk_i) begin
       if (wr_en_i) begin
           DMEM_Q[addr_i] <= data_i;
       end
    end
    
    assign data_o = DMEM_Q[addr_i];
endmodule
