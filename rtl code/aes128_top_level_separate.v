module aes128_top_level_separate(
    //input ports
    input pi_clk,  
    input pi_rst,
    input [127:0] pi_input_key,
    input [127:0] pi_input_data,
    input pi_start,

    //output ports
    output po_end_of_encryption,
    output [127:0] po_out
);

wire [3:0] current_round;
wire generate_keys;
wire update_key;
wire [127:0] round_out;

key_extension_alt key_ex(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_input_key(pi_input_key),
    .pi_current_round(current_round),
    .pi_update_key(update_key),
    .po_round_out(round_out)
);

aes_block aes(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_input_key(round_out),
    .pi_input_data(pi_input_data),
    .pi_start(pi_start),
    .po_end_of_encryption(po_end_of_encryption),
    .po_generate_keys(generate_keys),
    .po_update_keys(update_key),
    .po_current_round(current_round),
    .po_out(po_out)
);

endmodule
