module aes128_top_level_alt (
    // input ports
    input pi_clk,
    input pi_rst,
    input [127:0] pi_input_key,
    input [127:0] pi_input_data,
    input pi_start,

    // output ports
    output po_end_of_encryption,
    output reg[127:0] po_out
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
wire [2:0] current_state;

localparam [2:0]
    st_init = 3'b000,
    st_generate_keys = 3'b001,
    st_add_round_key_enable = 3'b010,
    st_sub_bytes_enable = 3'b011,
    st_mix_column_enable = 3'b100,
    st_signal_output = 3'b101,
    st_reg_output = 3'b110;

    // FSM inputs
wire sub_bytes_done;
wire mix_column_done;

    // intermediary signals
wire [127:0] round_key;
wire [127:0] add_round_key_output_data;
wire [127:0] sub_bytes_shift_rows_output_data;
wire [127:0] mix_column_output_data;
reg [127:0] register_input;
reg [127:0] register_output;
wire [127:0] register_val;

wire enable;

assign enable = pi_start | generate_keys | add_round_key_en | sub_bytes_en | mix_column_done;

always@(*)
begin
    case(current_state)
        st_init: register_input = pi_input_data;
        st_generate_keys: register_input = pi_input_data; 
        st_mix_column_enable: register_input = mix_column_output_data;
        st_sub_bytes_enable: register_input = sub_bytes_shift_rows_output_data;//mix_column_output_data;
        st_add_round_key_enable: register_input = add_round_key_output_data;
        default: register_input = 0;
    endcase
end

//REGISTER LOGIC
always@(posedge pi_clk)
begin
    if (pi_rst == 1)
        register_output <= 0;
    else if (enable == 1)
        register_output <= register_input;
end

assign register_val = register_output;

assign po_end_of_encryption = end_of_encryption;
always@(posedge pi_clk, posedge pi_rst)
begin
    if (pi_rst == 1)
        po_out <= 0;
    else if (end_of_encryption == 1)
        po_out <= register_output;
end

key_extension_alt key_ex_alt(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_input_key(pi_input_key),
    .pi_current_round(current_round),
    //.pi_generate_keys(generate_keys),
    .pi_update_key(update_key),
    .po_round_out(round_key)
);

add_round_key_alt add_rnd_key(
    .pi_block(register_output), 
    .pi_key(round_key), 
    .po_out(add_round_key_output_data)
);

mix_columns_alt mix_clmn(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_enable(mix_column_en),
    .pi_in(register_output),

    .po_mix_column_done(mix_column_done),
    .po_out(mix_column_output_data)
);

sub_bytes_shift_rows_alt sub_b_shift_r (
    .pi_in(register_output),
    .po_out(sub_bytes_shift_rows_output_data)
);
 
fsm_full_expansion the_fsm(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
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
    .po_update_key(update_key),
    .po_curr_state(current_state)
);      

endmodule
