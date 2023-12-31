`define WIDTH 3
`define DATA_WIDTH 8

module mem_ctr (
    input clk,
    input rst,
    input WE_N,
    input RE_N,
    input [`WIDTH-1:0] R_ADR,
    input [`WIDTH-1:0] W_ADR,
    input [`DATA_WIDTH-1:0] DI,
    //----------single port ram_0 signal----------//
    output ENABLE_0,
    output WE_0,
    output [`WIDTH-2:0] A_0,
    output [`DATA_WIDTH-1:0] DI_0,
    //----------single port ram_0 signal----------//
    output ENABLE_1,
    output WE_1,
    output [`WIDTH-2:0] A_1,
    output [`DATA_WIDTH-1:0] DI_1
);
    wire R_bit, W_bit;
    wire [`WIDTH-2:0] R_A;
    wire [`WIDTH-2:0] W_A;
    wire CONFLICT;

    //--- write signal  register --------//
    reg W_bit_D;
    reg [`WIDTH-2:0] W_A_D;
    reg [`DATA_WIDTH-1:0] DI_D;
    reg flag;
    //----------------------------------//
    assign {R_A, R_bit} = R_ADR;
    assign {W_A, W_bit} = W_ADR;

    //----------  read & write conflct check--------//
    assign CONFLICT = (RE_N & WE_N) && (R_bit ^~ W_bit) ? 1'b1 : 1'b0;
    // if conflict ,use reg to  keep write signal for 1 clk 

    always @(posedge clk) begin
        if (rst) begin

            W_bit_D <= 1'b0;
            W_A_D <= 0;
            DI_D <= 0;
            flag <= 1'b0;
        end else if (CONFLICT) begin
            W_bit_D <= W_bit ;
            W_A_D <= W_A   ;
            DI_D <= DI  ;
            flag <= 1'b1 ;
        end else begin
            flag <= 1'b0;

        end

    end





    assign ENABLE_0 = (RE_N & ~R_bit) | (WE_N & ~W_bit) | (flag & ~W_bit_D);
    assign ENABLE_1 = (RE_N & R_bit) | (WE_N & W_bit) | (flag & W_bit_D);

    assign WE_0 = (~(RE_N & ~R_bit)) & (WE_N & ~W_bit) | (flag & ~W_bit_D);
    assign WE_1 = (~(RE_N & R_bit)) & (WE_N & W_bit) | (flag & W_bit_D);


    assign A_0 = (RE_N & ~R_bit) ? R_A : (flag & ~W_bit_D) ? W_A_D : (WE_N & ~W_bit) ? W_A : R_A;

    assign A_1 = (RE_N & R_bit) ? R_A : (flag & W_bit_D) ? W_A_D : (WE_N & W_bit) ? W_A : R_A;

    assign DI_0 = (flag & ~W_bit_D) ? DI_D : (WE_N & ~W_bit) ? DI : DI_D;

    assign DI_1 = (flag & W_bit_D) ? DI_D : (WE_N & W_bit) ? DI : DI_D;





endmodule
