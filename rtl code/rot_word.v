module rot_word (
    // input ports
    input [31:0] pi_in,
    
    // output ports
    output [31:0] po_out
);

assign po_out[31:8] = pi_in[23:0];
assign po_out[7:0] = pi_in[31:24];

endmodule