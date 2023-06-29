module shift_rows_alt(
    // input ports
    //input pi_clk,
    //input pi_rst,
    input [127:0] pi_in,
    //input pi_enable,

    // output porst
    output [127:0] po_out
);

    // internal signal
wire [127:0] tmp;

integer i,j,k,help;

assign tmp[127:96] = pi_in[127:96];

assign tmp[95:72] = pi_in[87:64];
assign tmp[71:64] = pi_in[95:88];

assign tmp[63:48] = pi_in[47:32];
assign tmp[47:32] = pi_in[63:48];

assign tmp[31:24] = pi_in[7:0];
assign tmp[23:0] = pi_in[31:8];

    // alternate solution
/* always@(*)
begin
    for (i = 0; i < 4; i = i + 1)
        for(j = 0; j < 4; j = j + 1)
            for(k = 0; k < 8; k = k + 1)
            begin
                //if (j>=i)
                //    help = j-i;
                //else
                //    help = j-i+4;
                //tmp[32*i+8*j+k] <= pi_in[32*i+8*help+k];   //LSB is the start of matrix

                //help = (j+i)%4;                                     
                tmp[127-(32*i+8*j+k)] <= pi_in[127-(32*i+8*((j+i)%4)+k)];    //MSB is the start of matrix
            end
end */

assign po_out = tmp;

endmodule
