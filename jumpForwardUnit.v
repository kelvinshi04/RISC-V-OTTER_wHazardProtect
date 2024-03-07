`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CPE 333
// Engineer: Kelvin Shi
// 
// Create Date: 02/23/2024 04:29:02 PM
// Design Name: 
// Module Name: jumpForwardUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A forwarding unit for the jump address generator since it is a separate module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module jumpForwardUnit(
    input [4:0] rsAddy,
    input [6:0] curOp,
    input [4:0] if_ex_rd,
    input [6:0] ieOp,
    input [4:0] ex_mem_rd,
    input [6:0] emOp,
    input [4:0] mem_wb_rd,
    input [6:0] mwOp,
    output reg [1:0] rsSelect,
    output reg stallJump
    );
    
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        CSR    = 7'b1110011
    } opcode_t;
    opcode_t curOpp; //- define variable of new opcode type
    opcode_t ieOpp;
    opcode_t emOpp;
    opcode_t mwOpp;
    assign curOpp = opcode_t'(curOp); //- Cast input enum 
    assign ieOpp = opcode_t'(ieOp);
    assign emOpp = opcode_t'(emOp);
    assign mwOpp = opcode_t'(mwOp);
    
    always @(*) begin
        rsSelect = 2'b00; //avoids latch
        if (curOpp == JALR) begin
            if ((rsAddy == if_ex_rd) && (if_ex_rd != 5'b00000)) begin
                case (ieOpp)
                    LUI, AUIPC, JALR, OP_IMM, OP_RG3, CSR:
                        rsSelect = 2'b11;
                    LOAD:
                        stallJump = 1'b1;
                    default:
                        rsSelect = 2'b00;
                endcase
            end    
                
            if ((rsAddy == ex_mem_rd) && (ex_mem_rd != 5'b00000) && (ex_mem_rd != if_ex_rd)) begin
                case (emOpp)
                    LUI, AUIPC, JALR, OP_IMM, OP_RG3, CSR:
                        rsSelect = 2'b10;
                    LOAD:
                        stallJump = 1'b1;
                    default:
                        rsSelect = 2'b00;
                endcase
            end
            
            if ((rsAddy == mem_wb_rd) && (mem_wb_rd != 5'b00000) && (ex_mem_rd != mem_wb_rd) && (mem_wb_rd != if_ex_rd)) begin
                case (mwOpp)
                    LUI, AUIPC, JALR, OP_IMM, OP_RG3, CSR, LOAD:
                        rsSelect = 2'b01;
                    default:
                        rsSelect = 2'b00;
                endcase
            end
        end
    end
    
    
endmodule
