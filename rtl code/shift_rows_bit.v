module shift_rows_bit(
    input [15:0] in,
    output [15:0] out
);

reg [15:0] tmp;

integer i,j;

always@(*)
begin
    for (i = 0; i < 4; i = i + 1)
    begin
        for(j = 0; j < 4; j = j + 1)
        begin
            tmp[4*i+j] = in[4*i+(j-i)%4];
        end
    end
end

assign out = tmp;

endmodule