module barrel_shifter (
    input [5:0] fn, // fn code
    input  [31:0] in_data,   // shift ´ë»ó
    input  [31:0]  shamt_32,     // shift amount
    input  [1:0]  ALUFunc,      // 00=ROT, 01=SRL, 10=SLL, 11=SRA
    output reg [31:0] out_data
);


wire [4:0] shamt = shamt_32[10:6];
wire [4:0] shamt_rt = shamt_32[4:0];

always @(*) begin
    case (ALUFunc)
        2'b00: out_data = (in_data << shamt_rt) | (in_data >> (32 - shamt_rt));
        2'b01: out_data = in_data << shamt;
        2'b10: out_data = in_data >> shamt;
        2'b11: out_data = $signed(in_data) >>> shamt;
        default: out_data = 32'b0;
    endcase
end


endmodule
