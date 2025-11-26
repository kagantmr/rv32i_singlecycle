//`include "pkg/riscv_pkg.sv"
/* verilator lint_off IMPORTSTAR */

module riscv_singlecycle
import riscv_pkg::*;
#(
    parameter DMemInitFile  = "dmem.mem",       // data memory initialization file
    parameter IMemInitFile  = "imem.mem"       // instruction memory initialization file
)(
    input  logic             clk_i,       // system clock
    input  logic             rstn_i,      // system reset
    input  logic  [XLEN-1:0] addr_i,      // memory adddres input for reading
    
    output logic  [XLEN-1:0] data_o,      // memory data output for reading
    output logic             update_o,    // retire signal
    output logic  [XLEN-1:0] pc_o,        // retired program counter
    output logic  [XLEN-1:0] instr_o,     // retired instruction
    output logic  [     4:0] reg_addr_o,  // retired register address
    output logic  [XLEN-1:0] reg_data_o,  // retired register data
    output logic  [XLEN-1:0] mem_addr_o,  // retired memory address
    output logic  [XLEN-1:0] mem_data_o,  // retired memory data
    output logic             mem_wrt_o,   // retired memory write enable signal
    output logic             mem_read_o
);
    
    localparam MEM_W = 65536;
    localparam INITIAL_ADDRESS = 32'h8000_0000;
    
    reg  [31:0] PC;
    wire [3:0]  alu_sel;
    wire [2:0]  result_ext_sel, imm_src_sel, dmem_in_ext;
    wire [1:0]  result_mux_sel;
    wire [31:0] instruction;
    wire [31:0] result_mux_out, src1_mux_out, src2_mux_out, rf_out1, rf_out2, alu_result, imm_extended, dmem_in, dmem_out, rf_in;
    wire [31:0] pc_plus4, pc_target, pcnext_mux_out, result_extend_out, pc_trg_src1;
    wire        rf_write_enable, alu_zero, alu_src1_sel, alu_src2_sel, pcnext_sel, dmem_write_enable, pc_trg_src1_sel, alu_slt, rf_in_sel;  
    
    
    // ---------------------------------------------------------------- MODULE INSTANTIATION
    control_unit CU(
        .op_i(instruction[6:0]),
        .funct3_i(instruction[14:12]),
        .funct75_i(instruction[30]),
        .Z_i(alu_zero),
        .SLT_i(alu_slt),
        .pc_trg_src1_sel_o(pc_trg_src1_sel),
        .pc_sel_o(pcnext_sel),
        .result_sel_o(result_mux_sel),
        .result_ext_o(result_ext_sel),
        .dmem_en_o(dmem_write_enable),
        .dmem_in_ext_o(dmem_in_ext),
        .ALU_sel_o(alu_sel),
        .ALU_src1_sel_o(alu_src1_sel),        
        .ALU_src2_sel_o(alu_src2_sel),
        .imm_src_o(imm_src_sel),
        .rf_in_sel_o(rf_in_sel),
        .rf_en_o(rf_write_enable)
        
    );
    
    rf_datain_mux RFDATAINMUX(                      
        .result_ext_i(result_extend_out),     
        .imm_ext_i   (imm_extended),     
        .sel_i       (rf_in_sel),     
        .rf_data_in_o(rf_in)      
    );                                     
                                           
   
    register_file RF(
        .addr1_i(instruction[19:15]),
        .addr2_i(instruction[24:20]),
        .addr3_i(instruction[11:7]),
        .data_i(rf_in),
        .wr_en_i(rf_write_enable),
        .rst_ni(rstn_i),
        .clk_i(clk_i),
        .data1_o(rf_out1),
        .data2_o(rf_out2)
    );

    sign_extend IMMEXT(
        .data_i(instruction[31:7]),
        .sel_i(imm_src_sel),
        .ext_data_o(imm_extended)
    );

    src1_mux SRC1MUX(
        .rf_out1_i(rf_out1),
        .pc_i(PC),
        .sel_i(alu_src1_sel),
        .src1_o(src1_mux_out)
    );
    
    src2_mux SRC2MUX(
        .immext_i(imm_extended),
        .rd2_i(rf_out2),
        .sel_i(alu_src2_sel),
        .src2_o(src2_mux_out)
    );
     
    ALU ALU(
        .src1_i(src1_mux_out),
        .src2_i(src2_mux_out),
        .sel_i (alu_sel),
        .Z_o(alu_zero),
        .result_o(alu_result)
    );
    
    result_mux RSLTMUX(
        .aluresult_i(alu_result),
        .dmem_out_i(dmem_out),
        .pc_p4_i(pc_plus4),
        .sel_i(result_mux_sel),
       
    );
    

    
    instruction_memory #(MEM_W, INITIAL_ADDRESS, IMemInitFile) IMEM
    (
    .addr_i(PC),
    .data_o(instruction)
    );
    
    data_memory #(MEM_W, DMemInitFile) DMEM
    (
        .clk_i(clk_i),
        .addr_i(alu_result),
        .data_i(dmem_in),
        .wr_en_i(dmem_write_enable),
        .data_o(dmem_out)
    );
    
    sign_extend_loadstore RSLTEXT(
        .data_i(result_mux_out),
        .sel_i(result_ext_sel),
        .ext_data_o(result_extend_out)
    );
    
    sign_extend_loadstore DMEMINEXT(
        .data_i(rf_out2),
        .sel_i(dmem_in_ext),
        .ext_data_o(dmem_in)
    );
    
    pctarget_mux PCTRGSRC1MUX(
        .pc_i(PC),
        .rf_rd1_i(rf_out1),
        .sel_i(pc_trg_src1_sel),
        .pctarget_src1_o(pc_trg_src1)
     );

    pcnext_mux PCMUX(
        .pc_target_i(pc_target),
        .pc_p4_i(pc_plus4),
        .sel_i(pcnext_sel),
        .pc_next_o(pcnext_mux_out)
    );

    // --------------------------------------------------------------------------------------
    
    // ---------------------------------------------------------------- INTERMEDIATE LOGIC
    
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            PC <= INITIAL_ADDRESS;
//            update_o <= 0;
        end else begin

            PC <= pcnext_mux_out;
//            update_o <= 1;
        end
    end
    
    assign pc_plus4 = PC + 4;
    assign pc_target = pc_trg_src1 + imm_extended;
    assign alu_slt = alu_result[0];

    // --------------------------------------------------------------------------------------
    
    // ---------------------------------------------------------------- OUTPUT LOGIC
    
    instr_t op;
    assign op = CU.op_i;
    assign data_o     = 32'b0;             // memory data output for reading
    assign update_o   = rstn_i;            // retire signal
    assign pc_o       = PC;                // retired program counter
    assign instr_o    = instruction;       // retired instruction
    assign reg_addr_o = (op == BRANCH | op == STORE) ?  'd0 : instruction[11:7]; // retired register address
    assign mem_addr_o = alu_result;        // retired memory address
    assign reg_data_o = rf_in;             // retired register data
    assign mem_data_o = dmem_in;           // retired memory data
    
    always_comb begin
        mem_wrt_o = 1'b0;
        mem_read_o = 1'b0;
        case (op)
            LOAD             : begin
                mem_wrt_o = 1'b0;
                mem_read_o = 1'b1;            
            end
            STORE            : begin 
                mem_wrt_o = 1'b1;
                mem_read_o = 1'b0;     
            end
            default : begin 
                mem_wrt_o = 1'b0;
                mem_read_o = 1'b0;     
            end   
       endcase
    end


endmodule
