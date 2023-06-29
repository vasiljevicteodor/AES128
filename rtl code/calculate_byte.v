module calculate_byte (
    // input ports
    input pi_enable,
    input [31:0] pi_data_column,
    input [7:0] pi_matrix_row,

    // output ports
    output [7:0] po_out_byte
);
    // internal signals of the RTL architecture
wire [7:0] mul_0;
wire [7:0] mul_1;
wire [7:0] mul_2;
wire [7:0] mul_3;
wire [7:0] xor_0;
wire [7:0] xor_1;

multiply_byte m0 (.pi_enable(pi_enable), .pi_data_byte(pi_data_column[7:0]), .pi_matrix_coef(pi_matrix_row[1:0]), .po_out(mul_0));
multiply_byte m1 (.pi_enable(pi_enable), .pi_data_byte(pi_data_column[15:8]), .pi_matrix_coef(pi_matrix_row[3:2]), .po_out(mul_1));
multiply_byte m2 (.pi_enable(pi_enable), .pi_data_byte(pi_data_column[23:16]), .pi_matrix_coef(pi_matrix_row[5:4]), .po_out(mul_2));
multiply_byte m3 (.pi_enable(pi_enable), .pi_data_byte(pi_data_column[31:24]), .pi_matrix_coef(pi_matrix_row[7:6]), .po_out(mul_3));

assign xor_0 = mul_0^mul_1;
assign xor_1 = mul_2^mul_3;

assign po_out_byte = xor_0^xor_1;

endmodule