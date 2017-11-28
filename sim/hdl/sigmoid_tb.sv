module sigmoid_tb;
`include "testbench.svh"

  parameter ACTIV = "gen/dat/sigmoid_activ.dat";
  parameter DERIV = "gen/dat/sigmoid_deriv.dat";

  bit clk = 0;
  always #5 clk = ~clk;

  bit rst = 0;
  bit en = 0;

  logic arg_stb = 0;
  logic arg_rdy;
  logic [15:0] arg_dat;

  logic res_stb;
  logic res_rdy = 0;
  logic [7:0] res_dat;

  logic err_stb = 0;
  logic err_rdy;
  logic [15:0] err_dat;

  logic fbk_stb;
  logic fbk_rdy = 0;
  logic [15:0] fbk_dat;

  logic [7:0] res;
  logic [15:0] fbk;

  sigmoid #(ACTIV, DERIV) uut (.*);

  initial begin
    dumpargs;
    // Test 1
    en = 0;
    forward(16'h0000, res);
    `ASSERT(res == 8'h80);
    forward(16'h07ff, res);
    `ASSERT(res == 8'hff);
    forward(16'hf800, res);
    `ASSERT(res == 8'h00);
    // Test 2 FIXME
    reset;
    en = 1;
    forward(0, res);
    `ASSERT(res == 8'h80);
    backward(256, fbk);
    `ASSERT(fbk == 16'h0040);
    // Success
    $finish;
  end

endmodule
