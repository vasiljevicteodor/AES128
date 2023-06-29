/* module diff (
    // input ports
    input pi_clk,
    input pi_rst,
    input pi_in,

    // output ports
    output reg po_out
);

reg old_in;

always @(posedge pi_clk, posedge pi_rst) begin
    if (pi_rst == 1)
    begin
        old_in <= 0;
        po_out <= 0;
    end
    else
    begin
        old_in <= pi_in;
        if (old_in == 0 && pi_in == 1)
            po_out <= 1;
        else
            po_out <= 0;
    end
end

endmodule */

module diff (
    input pi_clk,
    input pi_in,

    output po_out
);

reg sig_dly;

always @(posedge pi_clk)
begin
    sig_dly <= pi_in;
end

assign po_out = pi_in & ~sig_dly;

endmodule