module key_extension (
    // input ports
    input pi_clk,
    input pi_rst,
    input [127:0] pi_input_key,
    input [3:0] pi_current_round,
    input pi_generate_keys,

    // output ports
    output reg [127:0] po_round_out,
    output po_keys_generated
);

    // registers that hold all the keys
reg [127:0] round_key_array_r [10:0];
    // first byte of each column in rcon matrix (others are 0)
reg [79:0] rcon_row_r = 80'h01020408102040801b36;
    // temporary values of keys, loaded in round_key_array_r registers on the posedge of clk
wire [127:0] keys [9:0];
    // array of columns of rcon matrix
wire [31:0] rcon_val [9:0];
    // counting from 12 to 0 (key extension lasts for 12 clk intervals)
reg [3:0] counter_r;

reg extension_active;
wire keys_generated;

    // assigning the values of rcon columns
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

always @(posedge pi_clk, posedge pi_rst) begin
    if (pi_rst == 1)
    begin
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
        // counter_r set to 12
        counter_r <= 4'hc;
        //po_keys_generated <= 0;
        extension_active <= 0;
    end
    else
    begin
        if (pi_generate_keys == 1)
        begin
            extension_active <= 1;
            counter_r <= 4'hc;
        end
        if (extension_active) begin
            round_key_array_r[0] <= pi_input_key;
            round_key_array_r[1] <= keys[0];
            round_key_array_r[2] <= keys[1];
            round_key_array_r[3] <= keys[2];
            round_key_array_r[4] <= keys[3];
            round_key_array_r[5] <= keys[4];
            round_key_array_r[6] <= keys[5];
            round_key_array_r[7] <= keys[6];
            round_key_array_r[8] <= keys[7];
            round_key_array_r[9] <= keys[8];
            round_key_array_r[10] <= keys[9];
            if(counter_r > 0)
                counter_r <= counter_r - 1;
            else
                extension_active <= 0;
        end
    end
end

    // signal used for handshaking with the control unit - signals that all the keys are ready
assign keys_generated = (counter_r > 0) ? 0 : 1;
diff diff_keys_gen(.pi_clk(pi_clk), .pi_rst(pi_rst), .pi_in(keys_generated), .po_out(po_keys_generated));

    // depending on the current round, coresponding key is set as the output
always@(*)
begin
    case (pi_current_round)
    4'h0 : po_round_out <= round_key_array_r[0];
    4'h1 : po_round_out <= round_key_array_r[1];
    4'h2 : po_round_out <= round_key_array_r[2];
    4'h3 : po_round_out <= round_key_array_r[3];
    4'h4 : po_round_out <= round_key_array_r[4];
    4'h5 : po_round_out <= round_key_array_r[5];
    4'h6 : po_round_out <= round_key_array_r[6];
    4'h7 : po_round_out <= round_key_array_r[7];
    4'h8 : po_round_out <= round_key_array_r[8];
    4'h9 : po_round_out <= round_key_array_r[9];
    4'ha : po_round_out <= round_key_array_r[10];
    default : po_round_out <= 0;
    endcase
end

genvar i;

generate
    for (i = 0; i < 10; i = i + 1)
        calc_key ck0 (.pi_prev_key(round_key_array_r[i]), .pi_rcon_val(rcon_val[i]), .po_out_key(keys[i]));
endgenerate

endmodule