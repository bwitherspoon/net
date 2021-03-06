`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"
`include "utility.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 8;
  localparam ARGD = 2;
  localparam RESW = 16;
  localparam ERRW = 16;
  localparam FBKW = 16;
  localparam FBKD = 2;

  `clock()
  `reset
  `master(arg_, ARGW, ARGD)
  `slave(res_, RESW)
  `master(err_, ERRW)
  `slave(fbk_, FBKW, FBKD)

  logic en = 0;
  logic [ARGD-1:0][ARGW-1:0] arg [4];
  logic [RESW-1:0] res;
  logic signed [RESW-1:0] tgt [4];
  logic signed [RESW-1:0] act;
  logic signed [ERRW-1:0] err;
  logic [FBKD-1:0][FBKW-1:0] fbk;

  associate #(.ARGD(ARGD), .RATE(1)) uut (.*);

  task train;
  begin
    en = 1;
    repeat (25) for (int i = 0; i < 4; i++) begin
        arg_xmt(arg[i]);
        res_rcv(res);
        act = $signed(res) < 0 ? 16'h0000 : 16'h00ff;
        err = tgt[i] - act;
        err_xmt(err);
        fbk_rcv(fbk);
    end
    en = 0;
    for (int i = 0; i < 4; i++) begin
      arg_xmt(arg[i]);
      res_rcv(res);
      act = $signed(res) < 0 ? 16'h0000 : 16'h00ff;
      err = tgt[i] - act;
      `check_equal(abs(err), 0);
    end
  end
  endtask : train

  task fwd_test;
  begin
    en = 0;
    arg_xmt(16'h0000);
    res_rcv(res);
    `check_equal(res, 16'b0);
  end
  endtask : fwd_test

  task bwd_test;
  begin
    en = 1;
    arg_xmt(16'h0000);
    res_rcv(res);
    `check_equal(res, 16'b0);
    err_xmt(16'h0000);
    fbk_rcv(res);
    `check_equal(res, 32'b0);
    en = 0;
  end
  endtask : bwd_test

  task and_test;
  begin
  // Logical AND function
  arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
  tgt[0] = 16'h0000; tgt[1] = 16'h0000; tgt[2] = 16'h0000; tgt[3] = 16'h00ff;
  train;
  end
  endtask : and_test

  task or_test;
  begin
  // Logical OR function
  arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
  tgt[0] = 16'h0000; tgt[1] = 16'h00ff; tgt[2] = 16'h00ff; tgt[3] = 16'h00ff;
  train;
  end
  endtask : or_test

  task test;
  fork
    begin : timeout
      repeat (1e6) @(posedge clk);
      disable worker;
      `ifdef __ICARUS__
        $error("testbench timeout");
        $stop;
      `else
        $fatal(0, "testbench timeout");
      `endif
    end : timeout
    begin : worker
      fwd_test;
      bwd_test;
      reset;
      init;
      and_test;
      reset;
      init;
      or_test;
      disable timeout;
    end : worker
  join
  endtask : test

  task init;
  begin
    for (int i = 0; i < ARGD; i++)
      uut.weights[i] = random(2**4);
  end
  endtask : init

  initial begin
    dump;
    seed;
    init;
    test;
    $finish;
  end

endmodule
