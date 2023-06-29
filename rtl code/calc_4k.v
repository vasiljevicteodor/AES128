module calc_4k (
    // input ports
    input [31:0] pi_closer,
    input [31:0] pi_further,
    input [31:0] pi_rcon_val,

    // output ports
    output [31:0] po_out
);

    // internal signals
wire [31:0] rotated;
wire [31:0] mapped;

rot_word rw (.pi_in(pi_closer), .po_out(rotated));

sbox sb0 (.a(rotated[7:0]), .c(mapped[7:0]));
sbox sb1 (.a(rotated[15:8]), .c(mapped[15:8]));
sbox sb2 (.a(rotated[23:16]), .c(mapped[23:16]));
sbox sb3 (.a(rotated[31:24]), .c(mapped[31:24]));

assign po_out = mapped^pi_further^pi_rcon_val;
    
endmodule