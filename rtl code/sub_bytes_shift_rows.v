module sub_bytes_shift_rows (
    // input ports
    input pi_clk,
    input pi_rst,
    input [127:0] pi_in,
    input pi_sub_bytes_en,
    // output ports
    output [127:0] po_out
);

    // internal signal
wire [127:0] tmp;

sub_bytes sb (.pi_in(pi_in), .po_out(tmp));

shift_rows sr (.pi_clk(pi_clk), .pi_rst(pi_rst), .pi_in(tmp), .pi_enable(pi_sub_bytes_en), .po_out(po_out));

endmodule