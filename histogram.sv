// 5x5 histogram, 25 elements, 256bin
module histogram_filter #(
  parameter WIDTH = 8,
  parameter P_WIN = 5
) (

  input logic [WIDTH*P_WIN*P_WIN-1:0]   filter_win_in,
  input logic                           filter_vld_in,

  output logic [WIDTH-1:0]              filter_dat_out,
  output logic                          filter_vld_out,

  input logic [WIDTH-1:0]               r_vote_ratio_s,
  input logic [WIDTH-1:0]               r_vote_ratio_h,

  input logic clk,
  input logic rst_n
);

integer i, j;

function [256-1:0] demuxer(input [7:0] x);
    return ((1'b1)<<x);
endfunction

function [5:0] countones(input [P_WIN*P_WIN-1:0] in);
    return  $countones(in);
endfunction

function void max8(input [WIDTH-1:0] a,b,c,d,e,f,g,h,d_a,d_b,d_c,d_d,d_e,d_f,d_g,d_h, output [WIDTH-1:0] max, d);
    logic   [WIDTH-1:0] temp_10,temp_11,temp_12,temp_13,temp_20,temp_21,temp_30;
    logic   [WIDTH-1:0] tempd_10,tempd_11,tempd_12,tempd_13,tempd_20,tempd_21,tempd_30;
    if(a>b) begin
        temp_10 = a;
        tempd_10 = d_a;
    end else begin
        temp_10 = b;
        tempd_10 = d_b;
    end
    if(c>d) begin
        temp_11 = c;
        tempd_11 = d_c;
    end else begin
        temp_11 = d;
        tempd_11 = d_d;
    end
    if(e>f) begin
        temp_12 = e;
        tempd_12 = d_e;
    end else begin
        temp_12 = f;
        tempd_12 = d_f;
    end
    if(g>h) begin
        temp_13 = g;
        tempd_13 = d_g;
    end else begin
        temp_13 = h;
        tempd_13 = d_h;
    end

    if(temp_10>temp_11) begin
        temp_20 = temp_10;
        tempd_20 = tempd_10;
    end else begin
        temp_20 = temp_11;
        tempd_20 = tempd_11;
    end
    if(temp_12>temp_13) begin
        temp_21 = temp_12;
        tempd_21 = tempd_12;
    end else begin
        temp_21 = temp_13;
        tempd_21 = tempd_13;
    end
    if(temp_20>temp_21) begin
        temp_30 = temp_20;
        tempd_30 = tempd_20;
    end else begin
        temp_30 = temp_21;
        tempd_30 = tempd_21;
    end
    max = temp_30;
    d = tempd_30;
endfunction


function void max4(input [WIDTH-1:0] a,b,c,d,d_a,d_b,d_c,d_d, output [WIDTH-1:0] max, d);
    logic   [WIDTH-1:0] temp_10,temp_11,temp_20;
    logic   [WIDTH-1:0] tempd_10,tempd_11,tempd_20;
    if(a>b) begin
        temp_10 = a;
        tempd_10 = d_a;
    end else begin
        temp_10 = b;
        tempd_10 = d_b;
    end
    if(c>d) begin
        temp_11 = c;
        tempd_11 = d_c;
    end else begin
        temp_11 = d;
        tempd_11 = d_d;
    end

    if(temp_10>temp_11) begin
        temp_20 = temp_10;
        tempd_20 = tempd_10;
    end else begin
        temp_20 = temp_11;
        tempd_20 = tempd_11;
    end
 
    max = temp_20;
    d = tempd_20;
endfunction
//select pixels
logic   [WIDTH-1:0]  P00 = filter_win_in[0*P_WIN*WIDTH+0*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P01 = filter_win_in[0*P_WIN*WIDTH+1*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P02 = filter_win_in[0*P_WIN*WIDTH+2*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P03 = filter_win_in[0*P_WIN*WIDTH+3*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P04 = filter_win_in[0*P_WIN*WIDTH+4*WIDTH+:WIDTH];

logic   [WIDTH-1:0]  P10 = filter_win_in[1*P_WIN*WIDTH+0*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P11 = filter_win_in[1*P_WIN*WIDTH+1*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P12 = filter_win_in[1*P_WIN*WIDTH+2*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P13 = filter_win_in[1*P_WIN*WIDTH+3*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P14 = filter_win_in[1*P_WIN*WIDTH+4*WIDTH+:WIDTH];

logic   [WIDTH-1:0]  P20 = filter_win_in[2*P_WIN*WIDTH+0*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P21 = filter_win_in[2*P_WIN*WIDTH+1*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P22 = filter_win_in[2*P_WIN*WIDTH+2*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P23 = filter_win_in[2*P_WIN*WIDTH+3*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P24 = filter_win_in[2*P_WIN*WIDTH+4*WIDTH+:WIDTH];

logic   [WIDTH-1:0]  P30 = filter_win_in[3*P_WIN*WIDTH+0*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P31 = filter_win_in[3*P_WIN*WIDTH+1*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P32 = filter_win_in[3*P_WIN*WIDTH+2*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P33 = filter_win_in[3*P_WIN*WIDTH+3*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P34 = filter_win_in[3*P_WIN*WIDTH+4*WIDTH+:WIDTH];

logic   [WIDTH-1:0]  P40 = filter_win_in[4*P_WIN*WIDTH+0*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P41 = filter_win_in[4*P_WIN*WIDTH+1*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P42 = filter_win_in[4*P_WIN*WIDTH+2*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P43 = filter_win_in[4*P_WIN*WIDTH+3*WIDTH+:WIDTH];
logic   [WIDTH-1:0]  P44 = filter_win_in[4*P_WIN*WIDTH+4*WIDTH+:WIDTH];


logic [255:0] demux_array[P_WIN*P_WIN-1:0];

assign  demux_array[5*0+0] = demuxer(P00);
assign  demux_array[5*0+1] = demuxer(P01);
assign  demux_array[5*0+2] = demuxer(P02);
assign  demux_array[5*0+3] = demuxer(P03);
assign  demux_array[5*0+4] = demuxer(P04);
assign  demux_array[5*1+0] = demuxer(P10);
assign  demux_array[5*1+1] = demuxer(P11);
assign  demux_array[5*1+2] = demuxer(P12);
assign  demux_array[5*1+3] = demuxer(P13);
assign  demux_array[5*1+4] = demuxer(P14);
assign  demux_array[5*2+0] = demuxer(P20);
assign  demux_array[5*2+1] = demuxer(P21);
assign  demux_array[5*2+2] = demuxer(P22);
assign  demux_array[5*2+3] = demuxer(P23);
assign  demux_array[5*2+4] = demuxer(P24);
assign  demux_array[5*3+0] = demuxer(P30);
assign  demux_array[5*3+1] = demuxer(P31);
assign  demux_array[5*3+2] = demuxer(P32);
assign  demux_array[5*3+3] = demuxer(P33);
assign  demux_array[5*3+4] = demuxer(P34);
assign  demux_array[5*4+0] = demuxer(P40);
assign  demux_array[5*4+1] = demuxer(P41);
assign  demux_array[5*4+2] = demuxer(P42);
assign  demux_array[5*4+3] = demuxer(P43);
assign  demux_array[5*4+4] = demuxer(P44);

//need pipeline here : TBD

// 24x255 -> 255x24
logic [P_WIN*P_WIN-1:0] onesbus [0:255];

    for(j=0; j<256; j++) begin
        for(i=0; i<P_WIN*P_WIN; i++) begin
            onesbus[j][i] = demux_array[i][j];
        end
    end


logic   [5:0] hist_array[0:255];
generate
    for(i=0; i<256; i++) begin : gen_hist_array
    always@(posedge clk or negedge rst_n)
        if(~rst_n)
            hist_array[i] <= 'd0;
        else
            hist_array[i] <= countones(onesbus[i]);
    end
endgenerate
//need pipeline here : done
//find max in 256 bins
logic   [5:0] temp8_lv1_w [0:31];
logic   [5:0] tempd8_lv1_w [0:31];
logic   [5:0] temp8_lv1 [0:31];
logic   [5:0] tempd8_lv1 [0:31];
logic   [7:0] votecnt;
assign  votecnt = 8'd25 - hist_array[255] - hist_array[254] - hist_array[253];
//level 1 32 results
generate
    for(i=0; i<256; i=i+8) begin : gen_max8_lv1
        max8(hist_array[i],hist_array[i+1],hist_array[i+2],hist_array[i+3],hist_array[i+4],hist_array[i+5],hist_array[i+6],hist_array[i+7],
            i,i+1,i+2,i+3,i+4,i+5,i+6,i+7, 
            temp8_lv1_w[i/8], tempd8_lv1_w[i/8] );

    always@(posedge clk or negedge rst_n)
        if(~rst_n) begin
            temp8_lv1[i/8]  <= 'd0;
            tempd8_lv1[i/8] <= 'd0;
        end else begin
            temp8_lv1[i/8]  <= temp8_lv1_w[i/8];
            tempd8_lv1[i/8] <= tempd8_lv1_w[i/8];
        end
    end

    end
endgenerate
//need pipeline here : done
//level 2 4 results
logic   [5:0] temp8_lv2_w [0:3];
logic   [5:0] tempd8_lv2_w [0:3];
logic   [5:0] temp8_lv2 [0:3];
logic   [5:0] tempd8_lv2 [0:3];
generate
    for(i=0; i<32; i=i+8) begin : gen_max8_lv2
        max8(temp8_lv1[i],temp8_lv1[i+1],temp8_lv1[i+2],temp8_lv1[i+3],temp8_lv1[i+4],temp8_lv1[i+5],temp8_lv1[i+6],temp8_lv1[i+7],
            tempd8_lv1[i],tempd8_lv1[i+1],tempd8_lv1[i+2],tempd8_lv1[i+3],tempd8_lv1[i+4],tempd8_lv1[i+5],tempd8_lv1[i+6],tempd8_lv1[i+7],
            temp8_lv2_w[i/8], tempd8_lv2_w[i/8]);

    always@(posedge clk or negedge rst_n)
        if(~rst_n) begin
            temp8_lv2[i/8]  <= 'd0;
            tempd8_lv2[i/8] <= 'd0;
        end else begin
            temp8_lv2[i/8]  <= temp8_lv2_w[i/8];
            tempd8_lv2[i/8] <= tempd8_lv2_w[i/8];
        end
    end

    end
endgenerate
//need pipeline here : done
//level 3 1 results
logic   [5:0] temp8_lv3_w, temp8_lv3;
logic   [5:0] tempd8_lv3_w, tempd8_lv3;

        max4(temp8_lv2[i],temp8_lv2[i+1],temp8_lv2[i+2],temp8_lv2[i+3],
            tempd8_lv2[i],tempd8_lv2[i+1],tempd8_lv2[i+2],tempd8_lv2[i+3],
            temp8_lv3, tempd8_lv3);
    always@(posedge clk or negedge rst_n)
        if(~rst_n) begin
            temp8_lv3[i/8]  <= 'd0;
            tempd8_lv3[i/8] <= 'd0;
        end else begin
            temp8_lv3[i/8]  <= temp8_lv3_w[i/8];
            tempd8_lv3[i/8] <= tempd8_lv3_w[i/8];
        end
    end


logic   [WIDTH-1:0] pixel_out;
always_comb
begin
    if( P22>8'd252 && (votecnt>((r_vote_ratio_s*8'd25)>>6)) && (temp8_lv3 > ((r_vote_ratio_h*votecnt)>>6)) )
        pixel_out = tempd8_lv3;
    else
        pixel_out = P22;
end

assign  filter_data_out = pixel_out;
assign  filter_vld_out = filter_vld_in;

endmodule
