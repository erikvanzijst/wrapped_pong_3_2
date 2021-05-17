`default_nettype none
`timescale 1ns/1ns
//`ifdef FORMAL
    `define MPRJ_IO_PADS 38    
//`endif
module wrapper (
    // interface as user_proj_example.v
    input wire wb_clk_i,
    input wire wb_rst_i,
    input wire wbs_stb_i,
    input wire wbs_cyc_i,
    input wire wbs_we_i,
    input wire [3:0] wbs_sel_i,
    input wire [31:0] wbs_dat_i,
    input wire [31:0] wbs_adr_i,
    output wire wbs_ack_o,
    output wire [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    // only provide first 32 bits to reduce wiring congestion
    input  wire [31:0] la_data_in,
    output wire [31:0] la_data_out,
    input  wire [31:0] la_oen,

    // IOs
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb,
    
    // active input, only connect tristated outputs if this is high
    input wire active
);

    // all outputs must be tristated before being passed onto the project
    wire buf_wbs_ack_o;
    wire [31:0] buf_wbs_dat_o;
    wire [31:0] buf_la_data_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_oeb;

    `ifdef FORMAL
    // formal can't deal with z, so set all outputs to 0 if not active
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'b0;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'b0;
    assign la_data_out  = active ? buf_la_data_out  : 32'b0;
    assign io_out       = active ? buf_io_out       : `MPRJ_IO_PADS'b0;
    assign io_oeb       = active ? buf_io_oeb       : `MPRJ_IO_PADS'b0;
    `include "properties.v"
    `else
    // tristate buffers
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'bz;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'bz;
    assign la_data_out  = active ? buf_la_data_out  : 32'bz;
    assign io_out       = active ? buf_io_out       : `MPRJ_IO_PADS'bz;
    assign io_oeb       = active ? buf_io_oeb       : `MPRJ_IO_PADS'bz;
    `endif

    // permanently set oeb so that outputs are always enabled: 0 is output, 1 is high-impedance
    assign buf_io_oeb = `MPRJ_IO_PADS'h0;
    // instantiate your module here, connecting what you need of the above signals

    pong #(.GAMECLK(8)) pong0 (
        .clk(wb_clk_i),
        .reset(la_data_in[0]),
        
        .start(io_in[8]),

        .player1_a(io_in[9]),
        .player1_b(io_in[10]),
        .player2_a(io_in[11]),
        .player2_b(io_in[12]),

        // 7-segment scoreboards:
        .seg_a(buf_io_out[13]),
        .seg_b(buf_io_out[14]),
        .seg_c(buf_io_out[15]),
        .seg_d(buf_io_out[16]),
        .seg_e(buf_io_out[17]),
        .seg_f(buf_io_out[18]),
        .seg_g(buf_io_out[19]),
        .cath(buf_io_out[20]),

        // 16x16 Matrix display:
        .RCLK(buf_io_out[21]),
        .RSDI(buf_io_out[22]),
        .OEB(buf_io_out[23]),
        .CSDI(buf_io_out[24]),
        .CCLK(buf_io_out[25]),
        .LE(buf_io_out[26])
    );

endmodule 
`default_nettype wire
