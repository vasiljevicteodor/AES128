module add_round_key_alt (
    // input ports
    input [127:0] pi_block,
    input [127:0] pi_key,

    // output ports
    output [127:0] po_out
);

assign po_out = pi_block^pi_key;
    
endmodule
