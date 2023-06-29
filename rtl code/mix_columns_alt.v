module mix_columns_alt (
    // input ports
    input pi_clk,
    input pi_rst,
    input pi_enable,
    input [127:0] pi_in,

    // output ports
    output po_mix_column_done,
    output [127:0] po_out
);

    // internal signal: since mix columns operation takes 2 clk periods, this signal is used
reg start_mix_r;
reg mix_column_done_r;

assign po_mix_column_done = mix_column_done_r;
//assign po_mix_column_done = pi_enable;


    // internal signals: column representation of the input
wire [31:0] column_0;
wire [31:0] column_1;
wire [31:0] column_2;
wire [31:0] column_3;
    // internal signal: column represented serialized output
wire [127:0] unsorted_out;
    // internal signal: regular serialized output
wire [127:0] sorted_out;
    // matrix used for the mix_columns calculation (4x4x2b)
reg [31:0] matrix_r = 32'b10110101011011010101101111010110;

always@(posedge pi_clk, posedge pi_rst)
begin
    if (pi_rst == 1)
    begin
        start_mix_r <= 0;
        mix_column_done_r <= 0;
    end
    else
    begin
    if (pi_enable == 1)
        start_mix_r <= 1;
    else
        start_mix_r <= 0;
    if (start_mix_r == 1)
        mix_column_done_r <= 1;
    else
        mix_column_done_r <= 0;
    end
end

assign column_0[31:24] = pi_in[127:120];
assign column_0[23:16] = pi_in[95:88];
assign column_0[15:8] = pi_in[63:56];
assign column_0[7:0] = pi_in[31:24];

assign column_1[31:24] = pi_in[119:112];
assign column_1[23:16] = pi_in[87:80];
assign column_1[15:8] = pi_in[55:48];
assign column_1[7:0] = pi_in[23:16];

assign column_2[31:24] = pi_in[111:104];
assign column_2[23:16] = pi_in[79:72];
assign column_2[15:8] = pi_in[47:40];
assign column_2[7:0] = pi_in[15:8];

assign column_3[31:24] = pi_in[103:96];
assign column_3[23:16] = pi_in[71:64];
assign column_3[15:8] = pi_in[39:32];
assign column_3[7:0] = pi_in[7:0];

calculate_column cc0(.pi_enable(start_mix_r), .pi_input_column(column_0), .pi_matrix(matrix_r), .po_column_out(unsorted_out[127:96]));
calculate_column cc1(.pi_enable(start_mix_r), .pi_input_column(column_1), .pi_matrix(matrix_r), .po_column_out(unsorted_out[95:64]));
calculate_column cc2(.pi_enable(start_mix_r), .pi_input_column(column_2), .pi_matrix(matrix_r), .po_column_out(unsorted_out[63:32]));
calculate_column cc3(.pi_enable(start_mix_r), .pi_input_column(column_3), .pi_matrix(matrix_r), .po_column_out(unsorted_out[31:0]));

assign sorted_out[127:120] = unsorted_out[127:120];
assign sorted_out[95:88] = unsorted_out[119:112];
assign sorted_out[63:56] = unsorted_out[111:104];
assign sorted_out[31:24] = unsorted_out[103:96];

assign sorted_out[119:112] = unsorted_out[95:88];
assign sorted_out[87:80] = unsorted_out[87:80];
assign sorted_out[55:48] = unsorted_out[79:72];
assign sorted_out[23:16] = unsorted_out[71:64];

assign sorted_out[111:104] = unsorted_out[63:56];
assign sorted_out[79:72] = unsorted_out[55:48];
assign sorted_out[47:40] = unsorted_out[47:40];
assign sorted_out[15:8] = unsorted_out[39:32];

assign sorted_out[103:96] = unsorted_out[31:24];
assign sorted_out[71:64] = unsorted_out[23:16];
assign sorted_out[39:32] = unsorted_out[15:8];
assign sorted_out[7:0] = unsorted_out[7:0];

assign po_out = sorted_out;
    // registering the output value, 1 clk cycle after the start
//always@(posedge pi_clk, posedge pi_rst)
//begin
//    if (pi_rst == 1)
//        po_out <= 0;
//    else if (start_mix_r == 1)
//            po_out <= sorted_out;
//end

endmodule
