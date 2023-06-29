module fsm_full_expansion (
    input pi_clk,
    input pi_rst,
    input pi_mix_column_done,
    input [127:0] pi_input_key,

    // CHANGED
    input pi_start,

    output po_generate_keys,
    output po_initial_round,
    output po_final_round,
    output reg po_end_of_encryption,
    output po_sub_bytes_en,
    output po_mix_column_en,
    output po_add_round_key_en,
    output [3:0] po_current_round,
    output reg po_update_key,
    output wire [2:0] po_curr_state  //ADDED
);

    
localparam [2:0]
    st_init = 3'b000,
    st_generate_keys = 3'b001,
    st_add_round_key_enable = 3'b010,
    st_sub_bytes_enable = 3'b011,
    st_mix_column_enable = 3'b100,
    st_signal_output = 3'b101,
    st_reg_output = 3'b110;

reg [2:0] state_reg, next_state;
reg reset_counter_full;
reg [3:0] cnt_val;
reg [127:0] curr_key_r;
reg same_key;

reg add_round_key_en_r;
reg mix_column_en_r;
reg generate_keys_r;
reg sub_bytes_en_r;
reg update_key_r;

wire add_round_key_en;
wire add_round_key_en_help;
wire mix_column_en;
wire generate_keys;
wire sub_bytes_en;
wire update_key;

assign add_round_key_en = add_round_key_en_r;
assign mix_column_en = mix_column_en_r;
assign generate_keys = generate_keys_r;
assign sub_bytes_en = sub_bytes_en_r;

assign po_curr_state = state_reg;

//TRANSITION LOGIC
always@(posedge pi_clk, posedge pi_rst)
begin
    curr_key_r <= pi_input_key;
    if (pi_rst)
        state_reg <= st_init;
    else
        state_reg <= next_state;
end

//NEXT STATE LOGIC
always@(state_reg, po_final_round, pi_mix_column_done, pi_start, pi_input_key, curr_key_r, same_key)
begin
    next_state <= state_reg;
    //if ((curr_key_r^pi_input_key) > 0)        //
    //    next_state <= st_init;                //
    //else                                      // Commenting this dissables the change key reset 
    case(state_reg)
        st_init:
            if (pi_start == 1)
                if (same_key == 0)
                    next_state <= st_generate_keys;
                else
                    next_state <= st_add_round_key_enable;
        st_generate_keys:
            next_state <= st_add_round_key_enable;

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
            else
                next_state <= st_mix_column_enable;
        end
        st_mix_column_enable:
        begin
            if(pi_mix_column_done == 1)
                next_state <= st_add_round_key_enable;
        end
        st_signal_output:
            next_state <= st_reg_output;
        st_reg_output:
            next_state <= st_init;
    endcase
end

//OUTPUT LOGIC
always@(*)
begin
    generate_keys_r <= 1'b0;
    sub_bytes_en_r <= 1'b0;
    mix_column_en_r <= 1'b0;
    add_round_key_en_r <= 1'b0;
    po_update_key <= 1'b0;
    reset_counter_full <= 1'b0;    

    case(state_reg)
        st_init:
            reset_counter_full <= 1'b1;
        st_generate_keys:
            generate_keys_r <= 1'b1;
        st_add_round_key_enable:
        begin
            add_round_key_en_r <= 1'b1;
            po_update_key <= 1'b1;
        end
        st_sub_bytes_enable:
        begin
            sub_bytes_en_r <= 1'b1;
            po_update_key <= 1'b0;
        end
        st_mix_column_enable:
            mix_column_en_r <= 1'b1;
    endcase
end

//ROUND COUNTER LOGIC
always@(posedge pi_clk)
begin
    if (reset_counter_full)
        cnt_val <= 0;
    else if(add_round_key_en_help && (cnt_val < 10))
        cnt_val <= cnt_val + 1;
end

assign po_current_round = cnt_val;
assign po_initial_round = (cnt_val == 0) ? 1'b1 : 1'b0;
assign po_final_round = (cnt_val == 10) ? 1'b1 : 1'b0;

always@(posedge pi_clk, posedge pi_rst)
begin
    if (pi_rst == 1)
        po_end_of_encryption <= 1'b0;
    else
        if (state_reg == st_reg_output)
            po_end_of_encryption <= 1'b1;
        else
            po_end_of_encryption <= 1'b0;
end

always@(posedge pi_clk, posedge pi_rst)
begin
    if (pi_rst)
        same_key <= 0;
    else
    begin
        if ((curr_key_r^pi_input_key) > 0)
            same_key <= 1'b0;
        else if (state_reg == st_reg_output)
            same_key <= 1'b1;
    end
end

diff diff_add_rnd_key(.pi_clk(pi_clk), .pi_in(add_round_key_en), .po_out(po_add_round_key_en));
diff diff_add_rnd_key_help(.pi_clk(pi_clk), .pi_in(add_round_key_en), .po_out(add_round_key_en_help));
diff diff_mix_clm_en(.pi_clk(pi_clk), .pi_in(mix_column_en), .po_out(po_mix_column_en));
diff diff_gen_keys(.pi_clk(pi_clk), .pi_in(generate_keys), .po_out(po_generate_keys));
diff diff_sub_bytes_en(.pi_clk(pi_clk), .pi_in(sub_bytes_en), .po_out(po_sub_bytes_en));

endmodule
