/**
 * @file top.v
 * 
 * This module implements all the modules of the RISC-V processor,
 * connecting the instruction memory, and data memory with the riscv_cpu module.
 * Also, it has a simple clock divider logic, to see the output of the cpu logic in 1Hz,
 * instead of the standard 100MHz generated by the FPGA.
 *
 * @input clk_in          Inputs clock signal.
 * @input reset           Inputs reset signal.
 * 
*/

module top (
    input   clk_in, 
            reset,
    inout   
);

wire [07:0] led;
wire [31:0] PC;
wire [31:0] Instr;
wire        MemWrite_rv32;
wire [31:0] DataAdr_rv32, WriteData_rv32;
wire [31:0] ReadData;

assign ProgramCounter = PC;
clock_divider   clker       (clk_in, reset, clk);
riscv_cpu       rvsingle    (.clk(clk), .reset(reset), .PC(PC), .Instr(Instr), .MemWrite(MemWrite_rv32), .Mem_WrAddr(DataAdr_rv32), .Mem_WrData(WriteData_rv32), .ReadData(ReadData));
data_mem        dmem        (clk, MemWrite_rv32, PC, DataAdr_rv32, WriteData_rv32, ReadData, Instr);
GPIO_Controller io          (clk, IO_pins[31:16], IO_pins[15:0], )
endmodule

module clock_divider (
    input wire clk_in,      // Input clock signal
    input wire reset,       // Reset signal
    output reg clk_out      // Output divided clock signal
);
    parameter DIVISOR = 100000000;  // Clock division factor (must be even)
    
    integer counter = 0;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == (DIVISOR / 2) - 1) begin
                clk_out <= ~clk_out; // Toggle the output clock
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
