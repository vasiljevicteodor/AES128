module aes128_cnt_mode(
    //input ports
    input pi_clk,
    input pi_rst,
    input [127:0] pi_input_key,
    input [127:0] pi_input_data,
    input pi_start,
    input [119:0] pi_nonse,
    input [7:0] pi_counter,
    
    //output ports
    output po_out
);

reg [127:0] nonse_and_cnt;  //80
reg [7:0] counter;          //48
wire end_of_encryption;
wire [127:0] aes_out;

always@(posedge pi_clk)
begin
    nonse_and_cnt[127:8] = pi_nonse;
    nonse_and_cnt[7:0] = counter;
end

assign po_out = aes_out^pi_input_data;

always@(posedge pi_clk, posedge pi_rst)
begin
    if (pi_rst == 1)
        counter <= pi_counter;
    else if (end_of_encryption == 1)
        counter <= counter + 1;   
end

aes128_top_level_alt aes_block(
    .pi_clk(pi_clk),
    .pi_rst(pi_rst),
    .pi_input_key(pi_input_key),
    .pi_input_data(nonse_and_cnt),
    .pi_start(pi_start),
    .po_end_of_encryption(end_of_encryption),
    .po_out(aes_out)
);

endmodule
