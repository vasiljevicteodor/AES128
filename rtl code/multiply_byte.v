module multiply_byte (
    // input ports
    input pi_enable,
    input [7:0] pi_data_byte,
    input [1:0] pi_matrix_coef,

    // output ports
    output [7:0] po_out
);

    // internal signals from the RTL architecture
reg [7:0] data_r;
reg [1:0] matrix_coef_r;
reg [7:0] polynomial_r = 8'b00011011;
wire [7:0] shifted_data;
wire [7:0] data_times_two;
wire [7:0] xor_out_0;
wire [7:0] xor_out_1;
wire [7:0] calculated_data;

    // check the multiply_byte design microarchitecture
always@(posedge pi_enable)
begin  
    data_r <= pi_data_byte;
    matrix_coef_r <= pi_matrix_coef;
end

assign shifted_data[7:1] = data_r[6:0];
assign shifted_data[0] = 0; 

assign xor_out_0 = polynomial_r^shifted_data;

assign data_times_two = (data_r[7] == 0) ? shifted_data : xor_out_0;

assign xor_out_1 = data_r^data_times_two;

assign calculated_data = (matrix_coef_r[0] == 0) ? data_times_two : xor_out_1;

assign po_out = (matrix_coef_r[1] == 0) ? data_r : calculated_data; 

endmodule