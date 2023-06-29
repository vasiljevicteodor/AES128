module add_round_key (
    // input ports
    input pi_clk,
    input pi_rst,
    input [127:0] pi_block,
    input [127:0] pi_key,
    input pi_enable,

    // output ports
    output reg [127:0] po_out
);
    
always@(posedge pi_clk, posedge pi_rst)
begin
    if (pi_rst == 1)
        po_out <= 0;
    else if (pi_enable == 1)
        po_out <= pi_block^pi_key;
end

endmodule