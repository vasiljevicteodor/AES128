module calculate_column (
    // input ports
    input pi_enable,
    input [31:0] pi_input_column,
    input [31:0] pi_matrix,

    // output ports
    output [31:0] po_column_out
);
    
calculate_byte cb0(.pi_enable(pi_enable), .pi_data_column(pi_input_column), .pi_matrix_row(pi_matrix[7:0]), .po_out_byte(po_column_out[7:0]));
calculate_byte cb1(.pi_enable(pi_enable), .pi_data_column(pi_input_column), .pi_matrix_row(pi_matrix[15:8]), .po_out_byte(po_column_out[15:8]));
calculate_byte cb2(.pi_enable(pi_enable), .pi_data_column(pi_input_column), .pi_matrix_row(pi_matrix[23:16]), .po_out_byte(po_column_out[23:16]));
calculate_byte cb3(.pi_enable(pi_enable), .pi_data_column(pi_input_column), .pi_matrix_row(pi_matrix[31:24]), .po_out_byte(po_column_out[31:24]));

endmodule