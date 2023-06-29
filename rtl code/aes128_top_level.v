module aes128_top_level (
    // input ports
    input pi_clk,
    input pi_rst,
    input [127:0] pi_input_key,
    input [127:0] pi_input_data,
    input pi_start,

    // output ports
    output [127:0] po_out
);

    // control signals

    // FSM outputs
wire initial_round;
wire final_round;
wire end_of_encryption;
wire sub_bytes_en;
wire mix_column_en;
wire add_round_key_en;
wire generate_keys;
wire [3:0] current_round;
wire update_key;

    // FSM inputs
wire keys_generated;
wire sub_bytes_done;
wire mix_column_done;

    // intermediary signals
wire [127:0] round_key;
wire [127:0] add_round_key_input_data;
wire [127:0] add_round_key_output_data;
wire [127:0] sub_bytes_shift_rows_output_data;
wire [127:0] mix_column_output_data;
wire [127:0] sub_and_mix_output_data;

assign add_round_key_input_data = (initial_round == 1) ? pi_input_data : sub_and_mix_output_data;

//key_extension key_ex(
//    .pi_clk(pi_clk),
//    .pi_rst(pi_rst),
//    .pi_input_key(pi_input_key),
//    .pi_current_round(current_round),
//    .pi_generate_keys(generate_keys),
//    .po_round_out(round_key),
//    .po_keys_generated(keys_generated)
//);

key_extension_alt key_ex_alt(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_input_key(pi_input_key),
    .pi_current_round(current_round),
    .pi_generate_keys(generate_keys),
    .pi_update_key(update_key),
    .po_round_out(round_key)
    //.po_keys_generated(keys_generated)
);

add_round_key add_rnd_key(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_block(add_round_key_input_data),
    .pi_key(round_key),
    .pi_enable(add_round_key_en),
    .po_out(add_round_key_output_data)
);

sub_bytes_shift_rows sbsr (
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_in(add_round_key_output_data),
    .pi_sub_bytes_en(sub_bytes_en),
    .po_out(sub_bytes_shift_rows_output_data)
);

mix_columns mix_cols(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_enable(mix_column_en),
    .pi_in(sub_bytes_shift_rows_output_data),
    .po_mix_column_done(mix_column_done),
    .po_out(mix_column_output_data)
);

assign sub_and_mix_output_data = (final_round == 0) ? mix_column_output_data : sub_bytes_shift_rows_output_data;

assign po_out = (end_of_encryption == 1) ? add_round_key_output_data : 0;

fsm_full_expansion the_fsm(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_keys_generated(keys_generated),
    //.pi_sub_bytes_done(sub),
    .pi_mix_column_done(mix_column_done),
    .pi_input_key(pi_input_key),
    .pi_start(pi_start),
    .po_generate_keys(generate_keys),
    .po_initial_round(initial_round),
    .po_final_round(final_round),
    .po_end_of_encryption(end_of_encryption),
    .po_sub_bytes_en(sub_bytes_en),
    .po_mix_column_en(mix_column_en),
    .po_add_round_key_en(add_round_key_en),
    .po_current_round(current_round),
    .po_update_key(update_key)
);

endmodule
