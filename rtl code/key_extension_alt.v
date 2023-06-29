module key_extension_alt (
    // input ports
    input pi_clk,
    input pi_rst,
    input [127:0] pi_input_key,
    input [3:0] pi_current_round,
    //input pi_generate_keys,
    input pi_update_key,

    // output ports
    output reg [127:0] po_round_out
);

reg [127:0] old_key_r;
reg [127:0] new_key_r;
reg [127:0] round_key_array_r [10:0];

wire [127:0] new_key;
wire [127:0] feedback_key;
reg initial_round;

always@(*)
begin
    initial_round <= (pi_current_round == 0) ? 1 : 0; 
end

reg [79:0] rcon_row_r = 80'h01020408102040801b36;
wire [31:0] rcon_val [9:0];
reg [31:0] curr_rcon_val;
assign rcon_val[0][31:24] = rcon_row_r[79:72];
assign rcon_val[0][23:0] = 24'h000000;
assign rcon_val[1][31:24] = rcon_row_r[71:64];
assign rcon_val[1][23:0] = 24'h000000;
assign rcon_val[2][31:24] = rcon_row_r[63:56];
assign rcon_val[2][23:0] = 24'h000000;
assign rcon_val[3][31:24] = rcon_row_r[55:48];
assign rcon_val[3][23:0] = 24'h000000;
assign rcon_val[4][31:24] = rcon_row_r[47:40];
assign rcon_val[4][23:0] = 24'h000000;
assign rcon_val[5][31:24] = rcon_row_r[39:32];
assign rcon_val[5][23:0] = 24'h000000;
assign rcon_val[6][31:24] = rcon_row_r[31:24];
assign rcon_val[6][23:0] = 24'h000000;
assign rcon_val[7][31:24] = rcon_row_r[23:16];
assign rcon_val[7][23:0] = 24'h000000;
assign rcon_val[8][31:24] = rcon_row_r[15:8];
assign rcon_val[8][23:0] = 24'h000000;
assign rcon_val[9][31:24] = rcon_row_r[7:0];
assign rcon_val[9][23:0] = 24'h000000;

always@(*)
begin
    case (pi_current_round)
    4'h0 : curr_rcon_val <= rcon_val[0];
    4'h1 : curr_rcon_val <= rcon_val[1];
    4'h2 : curr_rcon_val <= rcon_val[2];
    4'h3 : curr_rcon_val <= rcon_val[3];
    4'h4 : curr_rcon_val <= rcon_val[4];
    4'h5 : curr_rcon_val <= rcon_val[5];
    4'h6 : curr_rcon_val <= rcon_val[6];
    4'h7 : curr_rcon_val <= rcon_val[7];
    4'h8 : curr_rcon_val <= rcon_val[8];
    4'h9 : curr_rcon_val <= rcon_val[9];
    default : curr_rcon_val <= 0;
    endcase
end

always @(posedge pi_clk, posedge pi_rst) begin
    if (pi_rst == 1)
    begin
        old_key_r <= 0;
        new_key_r <= 0;
        round_key_array_r[0] <= 0;
        round_key_array_r[1] <= 0;
        round_key_array_r[2] <= 0;
        round_key_array_r[3] <= 0;
        round_key_array_r[4] <= 0;
        round_key_array_r[5] <= 0;
        round_key_array_r[6] <= 0;
        round_key_array_r[7] <= 0;
        round_key_array_r[8] <= 0;
        round_key_array_r[9] <= 0;
        round_key_array_r[10] <= 0;
        po_round_out <= 0;
    end
    else
    begin
        old_key_r <= (initial_round == 1) ? pi_input_key : feedback_key;
        if (pi_update_key == 1)
        begin
            new_key_r <= new_key;
            case (pi_current_round)
            4'h0 : round_key_array_r[0] <= pi_input_key;
            4'h1 : round_key_array_r[1] <= new_key_r;
            4'h2 : round_key_array_r[2] <= new_key_r;
            4'h3 : round_key_array_r[3] <= new_key_r;
            4'h4 : round_key_array_r[4] <= new_key_r;
            4'h5 : round_key_array_r[5] <= new_key_r;
            4'h6 : round_key_array_r[6] <= new_key_r;
            4'h7 : round_key_array_r[7] <= new_key_r;
            4'h8 : round_key_array_r[8] <= new_key_r;
            4'h9 : round_key_array_r[9] <= new_key_r;
            4'ha : round_key_array_r[10] <= new_key_r;
            endcase
        end
        po_round_out <= (initial_round == 1) ? old_key_r : new_key_r;
    end
end

assign feedback_key = new_key_r;

calc_key ck (.pi_prev_key(old_key_r), .pi_rcon_val(curr_rcon_val), .po_out_key(new_key));
    
endmodule
