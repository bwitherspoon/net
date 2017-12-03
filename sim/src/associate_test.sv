`include "debug.vh"

module associate_test;
  `define ARGW 8
  `define ARGN 2
  `define RESW 16
  `include "test.svh"

  parameter SEED = 32'hdeadbeef;

  logic [ARGN-1:0][ARGW-1:0] arg [4];
  logic [RESW-1:0] res;
  logic signed [RESW-1:0] tgt [4];
  logic signed [RESW-1:0] act;
  logic signed [ERRW-1:0] err;
  logic [FBKN-1:0][FBKW-1:0] fbk;

  associate #(.ARGN(ARGN), .RATE(1)) uut (.*);

  task train;
  begin
    en = 1;
    repeat (25) begin
      for (int i = 0; i < 4; i++) begin
        forward(arg[i], res);
        act = ($signed(res) < 0) ? 16'h0000 : 16'h00ff;
        err = tgt[i] - act;
        backward(err, fbk);
      end
    end
    en = 0;
    for (int i = 0; i < 4; i++) begin
      forward(arg[i], res);
      act = ($signed(res) < 0) ? 16'h0000 : 16'h00ff;
      err = tgt[i] - act;
      `ASSERT(abs(err) == 0);
    end
  end
  endtask : train

  task fwd_test;
  begin
    forward(16'h0000, res);
    `ASSERT(res == 16'b0);
  end
  endtask : fwd_test

  task bwd_test;
  begin
    en = 1;
    forward(16'h0000, res);
    `ASSERT(res == 16'b0);
    backward(16'h0000, fbk);
    `ASSERT(fbk == 32'b0);
  end
  endtask : bwd_test

  task and_test;
  begin
  // Logical AND function with linear threshold
  arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
  tgt[0] = 16'h0000; tgt[1] = 16'h0000; tgt[2] = 16'h0000; tgt[3] = 16'h00ff;
  train;
  end
  endtask : and_test

  task or_test;
  begin
  // Logical OR function with linear threshold
  arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
  tgt[0] = 16'h0000; tgt[1] = 16'h00ff; tgt[2] = 16'h00ff; tgt[3] = 16'h00ff;
  train;
  end
  endtask : or_test

  task test;
  begin
    fwd_test;
    bwd_test;
    reset;
    and_test;
    reset;
    or_test;
  end
  endtask : test

  integer seed = SEED;
  task init;
  begin
    for (int n = 0; n < ARGN; n++)
      uut.weights[n] = $random(seed) % 2**4;
  end
  endtask : init

  initial begin
    dump;
    init;
    test;
    $finish;
  end

endmodule
