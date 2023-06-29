module sub_bytes (
    // input ports
    input [127:0] pi_in,

    // output ports
    output [127:0] po_out
);

genvar i,j;

generate
    for (i = 0; i < 4; i = i + 1)
        for(j = 0; j < 4; j = j + 1)
            sbox sb0 (pi_in[(32*i+8*j+7):(32*i+8*j)], po_out[(32*i+8*j+7):(32*i+8*j)]);
endgenerate

endmodule