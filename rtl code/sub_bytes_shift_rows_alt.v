module sub_bytes_shift_rows_alt (
    // input ports
    input [127:0] pi_in,
    // output ports
    output [127:0] po_out
);

    // internal signal
wire [127:0] tmp;

sub_bytes sb (.pi_in(pi_in), .po_out(tmp));

shift_rows_alt sra (.pi_in(tmp), .po_out(po_out));

endmodule
