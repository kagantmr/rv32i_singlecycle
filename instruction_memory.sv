module instruction_memory #(
    parameter size = 16,
    parameter INITIAL_ADDRESS = 32'h8000_0000,
    parameter IMemInitFile  = "imem.mem" 
)(
    input       [31:0] addr_i,
    output      [31:0] data_o
    );
    
    reg [31:0] IMEM_Q [0: size - 1];
    
    initial begin
        $readmemh(IMemInitFile, IMEM_Q);
    end
    
    wire [31:0] actual_address;
    assign actual_address = {2'b0, addr_i[31:2]};
    
    assign data_o = IMEM_Q[actual_address];
endmodule
