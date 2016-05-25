`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RassIndustries & BL(B�ias Lindo) LDA
// Engineers: Grupo 2/4
// 
// Create Date: 05/13/2016 03:46:15 PM
// Design Name: VICtor Borges
// Module Name: vic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Vectored Interrupt Controller
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module vic_ctrl(
   input clk,
   input rst,
   input [31:0] i_PC,
   input i_reti,
   input [4:0] i_ISR_addr,
   input i_IRQ,
   input [3:0] i_CCodes,
   input i_NOT_FLUSH,
   output reg o_IRQ_PC,
   output reg [31:0] o_VIC_iaddr,
   output reg [3:0] o_VIC_CCodes,
   output reg o_IRQ_VIC,
   output reg o_VIC_CCodes_ctrl
   //output reg o_Flush_signal-------------> REMEMBER BIIIITCH
   );

    reg [31:0]saved_PC; // stores the PC value   
    reg [3:0] saved_CC;
    reg EX_not_ready_for_interrupt;
    always @(posedge i_IRQ) 
    begin    
           /* APAGAR QUANDO SE VALIDAR O COMENTADO */
           /* o_IRQ_VIC = 1'b1;    //rises the flag to externalVIC
            o_IRQ_PC = 1'b1;       //signal to fetch?
            
            if(~i_reti) //In case of sequencial interrupts we don't need to resave the program counter
            begin
                saved_PC = i_PC;
                saved_CC = i_CCodes;
            end   
            else        //safety implementation, keeps the saved_PC
            begin
                saved_PC = saved_PC;  
                saved_CC = saved_CC;  
            end
                
            o_VIC_iaddr = ({27'b0000_0000_0000_0000_0000_0000_000,i_ISR_addr}) << 4;   //addr of ISR to fetch*/
            o_IRQ_VIC = 1'b1;
            if(i_reti)
            begin  
                o_IRQ_PC = 1'b1;
                saved_PC = saved_PC;  
                saved_CC = saved_CC;
                o_VIC_iaddr = ({27'b0000_0000_0000_0000_0000_0000_000,i_ISR_addr}) << 4;   //addr of ISR to fetch*/
            end
            else
            begin
                if(i_NOT_FLUSH)
                begin
                   o_IRQ_PC = 1'b1;
                   saved_PC = i_PC;
                   saved_CC = i_CCodes;
                   o_VIC_iaddr = ({27'b0000_0000_0000_0000_0000_0000_000,i_ISR_addr}) << 4;   //addr of ISR to fetch*/
                end
                else
                begin
                    EX_not_ready_for_interrupt=1;
                end
            end

    end
    
    always @(posedge (i_NOT_FLUSH && EX_not_ready_for_interrupt))
    begin
       o_IRQ_PC = 1'b1;
       saved_PC = i_PC;
       saved_CC = i_CCodes;
       o_VIC_iaddr = ({27'b0000_0000_0000_0000_0000_0000_000,i_ISR_addr}) << 4;   //addr of ISR to fetch*/
       EX_not_ready_for_interrupt=0;
    end
    
    always @(posedge clk) 
    begin
        if(rst)
        begin
            o_IRQ_VIC = 1'b0;
        end
        
        o_IRQ_PC = 1'b0;     //sujeita a erros ---> problemas de timing
        
        if(!i_reti) 
        begin
            o_VIC_CCodes_ctrl = 1'b0;    
        end
    end
    
    //When a ISR is finished
    always @(posedge i_reti) begin
        o_VIC_iaddr = saved_PC;
        o_VIC_CCodes = saved_CC;
        o_IRQ_VIC   = 1'b0;
        o_VIC_CCodes_ctrl = 1'b1;

    end

endmodule
