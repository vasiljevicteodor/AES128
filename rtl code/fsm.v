module fsm (
    input pi_clk,
    input pi_rst,
    input pi_keys_generated,
    input pi_sub_bytes_done,
    input pi_mix_column_done,
    input [127:0] pi_input_key,

    output reg po_generate_keys,
    output wire po_initial_round,
    output wire po_final_round,
    output reg po_end_of_encryption,
    output reg po_sub_bytes_en,
    output reg po_mix_column_en,
    output reg po_add_round_key_en,
    output wire [3:0] po_current_round,
    output reg po_update_key
);
    
localparam [2:0]
    st_init = 3'b000,
    st_generate_keys = 3'b001,
    st_add_round_key_enable = 3'b010,
    st_sub_bytes_enable = 3'b011,
    st_mix_column_enable = 3'b100,
    st_signal_output = 3'b101;

reg [2:0] state_reg, next_state;
reg reset_counter_full;
reg [3:0] cnt_val;
reg [127:0] curr_key_r;

/* reg add_round_key_en;
reg mix_column_en;
reg generate_keys;
reg sub_bytes_en;
reg update_key; */

/* wire add_round_key_en_help;
wire mix_column_en_help;
wire generate_keys_help;
wire sub_bytes_en_help;
wire update_key_help; */

//TRANSITION LOGIC
always@(posedge pi_clk, pi_rst)
begin
    if (pi_rst)
    begin
        state_reg <= st_init;
        curr_key_r <= pi_input_key;
    end
    else
        state_reg <= next_state;
end

//NEXT STATE LOGIC
always@(state_reg, pi_keys_generated, po_final_round, pi_sub_bytes_done, pi_mix_column_done)
begin
    next_state <= state_reg;
    if ((curr_key_r^pi_input_key) > 0)
    begin
        next_state <= st_init;
        curr_key_r <= pi_input_key;
    end
    else
    case(state_reg)
        st_init:
            next_state <= st_generate_keys;
        st_generate_keys:
            if (pi_keys_generated == 1)
                next_state <= st_add_round_key_enable;
            //else
                //next_state <= st_generate_keys;
        st_add_round_key_enable:
        begin
            if(po_final_round == 0)
                next_state <= st_sub_bytes_enable;
            else
                next_state <= st_signal_output;
        end
        st_sub_bytes_enable:
        begin
            if(po_final_round == 1)
                next_state <= st_add_round_key_enable;
            else if(pi_sub_bytes_done == 1)
                next_state <= st_mix_column_enable;
        end
        st_mix_column_enable:
        begin
            if(pi_mix_column_done == 1)
                next_state <= st_add_round_key_enable;
            //else
                //next_state <= st_mix_column_enable;
        end
        st_signal_output:
                next_state <= st_init;
    endcase
end

//OUTPUT LOGIC
always@(*)
begin
    po_generate_keys <= 1'b0;
    po_end_of_encryption <= 1'b0;
    po_sub_bytes_en <= 1'b0;
    po_mix_column_en <= 1'b0;
    po_add_round_key_en <= 1'b0;
    po_update_key <= 1'b0;
    reset_counter_full <= 1'b0;

    case(state_reg)
        st_init:
            reset_counter_full <= 1'b1;
        st_generate_keys:
            po_generate_keys <= 1'b1;
        st_add_round_key_enable:
            po_add_round_key_en <= 1'b1;
        st_sub_bytes_enable:
        begin
            po_sub_bytes_en <= 1'b1;
            po_update_key <= 1'b1;
        end
        st_mix_column_enable:
            po_mix_column_en <= 1'b1;
        st_signal_output:
            po_end_of_encryption <= 1'b1;
    endcase
end

//ROUND COUNTER LOGIC
always@(posedge pi_clk, reset_counter_full)
begin
    if (reset_counter_full)
        cnt_val <= 0;
    else if(pi_sub_bytes_done)
        cnt_val <= cnt_val + 1;
end

assign po_current_round = cnt_val;
assign po_initial_round = (cnt_val == 0) ? 1'b1 : 1'b0;
assign po_final_round = (cnt_val == 10) ? 1'b1 : 1'b0;

/* diff diff_add_rnd_key(.pi_clk(pi_clk), .pi_in(add_round_key_en), .po_out(add_round_key_en_help));
diff diff_mix_clm_en(.pi_clk(pi_clk), .pi_in(mix_column_en), .po_out(mix_column_en_help));
diff diff_gen_keys(.pi_clk(pi_clk), .pi_in(generate_keys), .po_out(generate_keys_help));
diff diff_sub_bytes_en(.pi_clk(pi_clk), .pi_in(sub_bytes_en), .po_out(sub_bytes_en_help));
diff diff_update_key(.pi_clk(pi_clk), .pi_in(update_key), .po_out(update_key_help)); */

    /* assign po_add_round_key_en = add_round_key_en_help;
    assign po_mix_column_en = mix_column_en_help;
    assign po_generate_keys = generate_keys_help;
    assign po_sub_bytes_en = sub_bytes_en_help;
    assign po_update_key = update_key_help; */


endmodule