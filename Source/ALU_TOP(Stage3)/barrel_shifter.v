module barrel_shifter (
    input  [31:0] in_data,   // shift ´ë»ó
    input  [31:0]  shamt_32,     // shift amount
    input  [1:0]  ALUFunc,      // 00=ROT, 01=SRL, 10=SLL, 11=SRA
    output reg [31:0] out_data
);
wire [4:0] shamt;
assign shamt = shamt_32[10:6];

always @(*) begin
    case (ALUFunc)
        //ROT
        2'b00: begin
            out_data = (in_data << shamt) | (in_data >> (32 - shamt));
        end
        //Shift Right Logical
        2'b01: begin
            out_data = in_data >> shamt;
        end
        //Shift Left Logical
        2'b10: begin
            out_data = in_data << shamt;
        end
        //Shift Right Arithmetic
        2'b11: begin
            out_data = $signed(in_data) >>> shamt;
        end
    endcase
end

endmodule
