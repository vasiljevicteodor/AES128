module calc_key (
    // input ports
    input [127:0] pi_prev_key,
    input [31:0] pi_rcon_val,

    // output ports
    output reg [127:0] po_out_key
);

    // internal signals: previous key in column representation
wire [31:0] prev_column_0;
wire [31:0] prev_column_1;
wire [31:0] prev_column_2;
wire [31:0] prev_column_3;

    // internal signals: output key in column representation 
wire [31:0] out_column_3;
wire [31:0] out_column_2;
wire [31:0] out_column_1;
wire [31:0] out_column_0;
    
assign prev_column_3[31:24] = pi_prev_key[127:120];
assign prev_column_3[23:16] = pi_prev_key[95:88];
assign prev_column_3[15:8] = pi_prev_key[63:56];
assign prev_column_3[7:0] = pi_prev_key[31:24];

assign prev_column_2[31:24] = pi_prev_key[119:112];
assign prev_column_2[23:16] = pi_prev_key[87:80];  
assign prev_column_2[15:8] = pi_prev_key[55:48];  
assign prev_column_2[7:0] = pi_prev_key[23:16];  

assign prev_column_1[31:24] = pi_prev_key[111:104];
assign prev_column_1[23:16] = pi_prev_key[79:72];
assign prev_column_1[15:8] = pi_prev_key[47:40];
assign prev_column_1[7:0] = pi_prev_key[15:8];

assign prev_column_0[31:24] = pi_prev_key[103:96];
assign prev_column_0[23:16] = pi_prev_key[71:64];
assign prev_column_0[15:8] =  pi_prev_key[39:32];
assign prev_column_0[7:0] =   pi_prev_key[7:0];

calc_4k c4k (.pi_closer(prev_column_0), .pi_further(prev_column_3), .pi_rcon_val(pi_rcon_val), .po_out(out_column_3));
assign out_column_2 = out_column_3^prev_column_2;
assign out_column_1 = out_column_2^prev_column_1;
assign out_column_0 = out_column_1^prev_column_0;

    // transformation from column representation to serialized output key
always@(*)
begin
    po_out_key[127:120] <= out_column_3[31:24];
    po_out_key[95:88] <= out_column_3[23:16];
    po_out_key[63:56] <= out_column_3[15:8];
    po_out_key[31:24] <= out_column_3[7:0];

    po_out_key[119:112] <= out_column_2[31:24];
    po_out_key[87:80] <= out_column_2[23:16];
    po_out_key[55:48] <= out_column_2[15:8];
    po_out_key[23:16] <= out_column_2[7:0];

    po_out_key[111:104] <= out_column_1[31:24];
    po_out_key[79:72] <= out_column_1[23:16];
    po_out_key[47:40] <= out_column_1[15:8];
    po_out_key[15:8] <= out_column_1[7:0];

    po_out_key[103:96] <= out_column_0[31:24];
    po_out_key[71:64] <= out_column_0[23:16];
    po_out_key[39:32] <= out_column_0[15:8];
    po_out_key[7:0] <= out_column_0[7:0];
end

endmodule