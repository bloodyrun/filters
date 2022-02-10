// 5x5 median filter, 25 elements, at least 8 cycles to complete
module median_filter #(
  parameter WIDTH = 8,
  parameter P_WIN = 5
) (

  input  logic [WIDTH*P_WIN*P_WIN-1:0]  filter_win_in,
  input  logic                          filter_in_vld,
  output logic                          filter_in_rdy,

  output logic [WIDTH-1:0]              filter_data_out,
  output logic                          filter_out_vld,
  input  logic                          filter_out_rdy,

  input  logic [5:0]                    r_mf_threshold,

  input  logic clk,
  input  logic rst_n
);
genvar i,j;

wire  filter_act = filter_in_vld && filter_in_rdy;
logic   [WIDTH*P_WIN*P_WIN-1:0] filter_win_reg;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)begin
      filter_win_reg   <= 'd0;
    end else if(filter_act) begin
      filter_win_reg   <= filter_win_in;
    end
end


//select pixels
logic   [WIDTH-1:0]  P00 ;
logic   [WIDTH-1:0]  P01 ;
logic   [WIDTH-1:0]  P02 ;
logic   [WIDTH-1:0]  P03 ;
logic   [WIDTH-1:0]  P04 ;

logic   [WIDTH-1:0]  P10 ;
logic   [WIDTH-1:0]  P11 ;
logic   [WIDTH-1:0]  P12 ;
logic   [WIDTH-1:0]  P13 ;
logic   [WIDTH-1:0]  P14 ;

logic   [WIDTH-1:0]  P20 ;
logic   [WIDTH-1:0]  P21 ;
logic   [WIDTH-1:0]  P22 ;
logic   [WIDTH-1:0]  P23 ;
logic   [WIDTH-1:0]  P24 ;

logic   [WIDTH-1:0]  P30 ;
logic   [WIDTH-1:0]  P31 ;
logic   [WIDTH-1:0]  P32 ;
logic   [WIDTH-1:0]  P33 ;
logic   [WIDTH-1:0]  P34 ;

logic   [WIDTH-1:0]  P40 ;
logic   [WIDTH-1:0]  P41 ;
logic   [WIDTH-1:0]  P42 ;
logic   [WIDTH-1:0]  P43 ;
logic   [WIDTH-1:0]  P44 ;

assign  P00 = filter_win_reg[0*P_WIN*WIDTH+0*WIDTH+:WIDTH];
assign  P01 = filter_win_reg[0*P_WIN*WIDTH+1*WIDTH+:WIDTH];
assign  P02 = filter_win_reg[0*P_WIN*WIDTH+2*WIDTH+:WIDTH];
assign  P03 = filter_win_reg[0*P_WIN*WIDTH+3*WIDTH+:WIDTH];
assign  P04 = filter_win_reg[0*P_WIN*WIDTH+4*WIDTH+:WIDTH];
assign  P10 = filter_win_reg[1*P_WIN*WIDTH+0*WIDTH+:WIDTH];
assign  P11 = filter_win_reg[1*P_WIN*WIDTH+1*WIDTH+:WIDTH];
assign  P12 = filter_win_reg[1*P_WIN*WIDTH+2*WIDTH+:WIDTH];
assign  P13 = filter_win_reg[1*P_WIN*WIDTH+3*WIDTH+:WIDTH];
assign  P14 = filter_win_reg[1*P_WIN*WIDTH+4*WIDTH+:WIDTH];
assign  P20 = filter_win_reg[2*P_WIN*WIDTH+0*WIDTH+:WIDTH];
assign  P21 = filter_win_reg[2*P_WIN*WIDTH+1*WIDTH+:WIDTH];
assign  P22 = filter_win_reg[2*P_WIN*WIDTH+2*WIDTH+:WIDTH];
assign  P23 = filter_win_reg[2*P_WIN*WIDTH+3*WIDTH+:WIDTH];
assign  P24 = filter_win_reg[2*P_WIN*WIDTH+4*WIDTH+:WIDTH];
assign  P30 = filter_win_reg[3*P_WIN*WIDTH+0*WIDTH+:WIDTH];
assign  P31 = filter_win_reg[3*P_WIN*WIDTH+1*WIDTH+:WIDTH];
assign  P32 = filter_win_reg[3*P_WIN*WIDTH+2*WIDTH+:WIDTH];
assign  P33 = filter_win_reg[3*P_WIN*WIDTH+3*WIDTH+:WIDTH];
assign  P34 = filter_win_reg[3*P_WIN*WIDTH+4*WIDTH+:WIDTH];
assign  P40 = filter_win_reg[4*P_WIN*WIDTH+0*WIDTH+:WIDTH];
assign  P41 = filter_win_reg[4*P_WIN*WIDTH+1*WIDTH+:WIDTH];
assign  P42 = filter_win_reg[4*P_WIN*WIDTH+2*WIDTH+:WIDTH];
assign  P43 = filter_win_reg[4*P_WIN*WIDTH+3*WIDTH+:WIDTH];
assign  P44 = filter_win_reg[4*P_WIN*WIDTH+4*WIDTH+:WIDTH];
logic   [24:0]  bit7, bit6, bit5, bit4, bit3, bit2, bit1, bit0;
always@*
begin
    for(int k=0; k<25; k++) begin
        bit7[k] = filter_win_reg[(k*WIDTH+7)+:1];
        bit6[k] = filter_win_reg[(k*WIDTH+6)+:1];
        bit5[k] = filter_win_reg[(k*WIDTH+5)+:1];
        bit4[k] = filter_win_reg[(k*WIDTH+4)+:1];
        bit3[k] = filter_win_reg[(k*WIDTH+3)+:1];
        bit2[k] = filter_win_reg[(k*WIDTH+2)+:1];
        bit1[k] = filter_win_reg[(k*WIDTH+1)+:1];
        bit0[k] = filter_win_reg[(k*WIDTH+0)+:1];
    end
end

//FSM control 
//8 bit need 8 cycles to find median and mux Pxx value
enum logic [1:0] {IDLE=2'd0,ACT=2'd1} mf_cs, mf_ns;
logic   pe_clr, latch_last, latch_last_d1, bv_enable;
logic   [2:0] bit_cnt, bit_cnt_nxt, bit_cnt_d1;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)begin
        mf_cs   <= IDLE;
        bit_cnt <= 3'd0;
    end else begin
        mf_cs   <= mf_ns;
        bit_cnt <= bit_cnt_nxt;
    end
end

always_comb
begin
    mf_ns = mf_cs;
    pe_clr = 1'b0;
    bit_cnt_nxt = 3'd0;
    latch_last = 1'b0;
    filter_in_rdy = 1'b0;
    bv_enable = 1'b0;
    case(mf_cs)
    IDLE: begin
    filter_in_rdy = filter_out_rdy;
       if(filter_in_vld) begin
           pe_clr = 1'b1;
           mf_ns = ACT;
           bit_cnt_nxt = 3'd7;
       end
    end
    ACT: begin
    bv_enable = 1'b1;
        if(bit_cnt!=3'd0) begin
            bit_cnt_nxt = bit_cnt - 1'b1;
        end else begin
            //bit_cnt_nxt = 3'd7;
            mf_ns = IDLE;
            filter_in_rdy = 1'b0;
            latch_last = 1'b1;
        end
    end
    default: mf_ns = IDLE;
    endcase
end

//first stage : 25 PE 
logic [24:0] bit_select_array, bit_pe_out;
assign bit_select_array[ 0] = P00[bit_cnt];
assign bit_select_array[ 1] = P01[bit_cnt];
assign bit_select_array[ 2] = P02[bit_cnt];
assign bit_select_array[ 3] = P03[bit_cnt];
assign bit_select_array[ 4] = P04[bit_cnt];
assign bit_select_array[ 5] = P10[bit_cnt];
assign bit_select_array[ 6] = P11[bit_cnt];
assign bit_select_array[ 7] = P12[bit_cnt];
assign bit_select_array[ 8] = P13[bit_cnt];
assign bit_select_array[ 9] = P14[bit_cnt];
assign bit_select_array[10] = P20[bit_cnt];
assign bit_select_array[11] = P21[bit_cnt];
assign bit_select_array[12] = P22[bit_cnt];
assign bit_select_array[13] = P23[bit_cnt];
assign bit_select_array[14] = P24[bit_cnt];
assign bit_select_array[15] = P30[bit_cnt];
assign bit_select_array[16] = P31[bit_cnt];
assign bit_select_array[17] = P32[bit_cnt];
assign bit_select_array[18] = P33[bit_cnt];
assign bit_select_array[19] = P34[bit_cnt];
assign bit_select_array[20] = P40[bit_cnt];
assign bit_select_array[21] = P41[bit_cnt];
assign bit_select_array[22] = P42[bit_cnt];
assign bit_select_array[23] = P43[bit_cnt];
assign bit_select_array[24] = P44[bit_cnt];

logic   bit_fbbk;

generate
    for(i=0; i<25; i++) begin : gen_median_bv_pe
        median_bv_pe u_median_bv_pe_px(
          .bit_in(bit_select_array[i]),
          .bit_fbbk(bit_fbbk),
          .bit_out(bit_pe_out[i]),
          .bit_clr(pe_clr),
          .clk,
          .rst_n
        );
    end
endgenerate

wire   [5:0]   bit_threshold = r_mf_threshold; //25/2
median_bv_acc u_median_bv_acc(

  .bits_in(bit_pe_out),
  .bit_out(bit_fbbk),
  .bit_clr(pe_clr),
  .bit_threshold(bit_threshold),

  .clk,
  .rst_n
);


logic [WIDTH-1:0] median_binary, median_binary_nxt;
always_comb
begin
    median_binary_nxt = median_binary;
    if(bv_enable) begin
        case(bit_cnt[2:0])
        3'd7: median_binary_nxt = {median_binary[6:0],bit_fbbk};
        3'd6: median_binary_nxt = {median_binary[6:0],bit_fbbk};
        3'd5: median_binary_nxt = {median_binary[6:0],bit_fbbk};
        3'd4: median_binary_nxt = {median_binary[6:0],bit_fbbk};
        3'd3: median_binary_nxt = {median_binary[6:0],bit_fbbk};
        3'd2: median_binary_nxt = {median_binary[6:0],bit_fbbk};
        3'd1: median_binary_nxt = {median_binary[6:0],bit_fbbk};
        3'd0: median_binary_nxt = {median_binary[6:0],bit_fbbk};
        default: median_binary_nxt = median_binary;
        endcase
    end else begin
        median_binary_nxt = median_binary;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)begin
        bit_cnt_d1 <= 3'd0;
        latch_last_d1 <= 1'b0;
    end else begin
        bit_cnt_d1 <= bit_cnt;
        latch_last_d1 <= latch_last;
    end
end
always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)begin
        median_binary <= 'd0;
    end else if(pe_clr) begin
        median_binary <= 'd0;        
    end else if( bv_enable ) begin
        median_binary <= median_binary_nxt;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)begin
        filter_data_out <= 'd0;
    end else if(latch_last) begin
        filter_data_out <= median_binary_nxt;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)begin
        filter_out_vld <= 'd0;
    end else if(filter_out_vld & filter_out_rdy) begin
        filter_out_vld <= 1'b0;
    end else if(latch_last) begin
        filter_out_vld <= 1'b1;
    end
end


endmodule


module median_bv_pe(

  input  logic bit_in,
  input  logic bit_fbbk,
  output logic bit_out,

  input  logic bit_clr,

  input  logic clk,
  input  logic rst_n
);


logic   bit_hold, bit_elim; //elimination bit
logic   st_elim;
always@(posedge clk or negedge rst_n)
    if(~rst_n) begin
        st_elim <= 1'b0;
    end else if(bit_clr) begin
        st_elim <= 1'b0;
    end else if( bit_fbbk!=bit_out && st_elim==0 ) begin
        st_elim <= 1'b1;
    end

always@(posedge clk or negedge rst_n)
    if(~rst_n) begin
        bit_elim <= 1'b0;
    end else if(bit_clr) begin
        bit_elim <= 1'b0;
    end else if( bit_fbbk!=bit_out && st_elim==0 ) begin
        bit_elim <= bit_in;
    end


assign  bit_out = (st_elim & ~bit_clr) ? bit_elim : bit_in ;

endmodule



module median_bv_acc#(
  parameter WIDTH = 8,
  parameter P_WIN = 5
) (

  input  logic  [P_WIN*P_WIN-1:0]   bits_in,
  
  output logic                      bit_out,

  input logic                       bit_clr,
  input logic   [5:0]               bit_threshold,

  input logic clk,
  input logic rst_n
);

logic [5:0] bit_acc;

assign  bit_acc = $countones(bits_in);


always_comb
begin
    
    if(bit_acc > bit_threshold)
        bit_out = 1'b1;
    else
        bit_out = 1'b0;

end

endmodule
