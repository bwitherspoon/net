`ifndef DEBUG_INCLUDED
`define DEBUG_INCLUDED

`ifndef SYNTHESIS
  `define DEBUG(msg) \
    do begin \
      `ifndef NDEBUG \
        $display("DEBUG: %s:%0d: %s", `__FILE__, `__LINE__, (msg)); \
      `endif \
    end while (0)

  `define INFO(msg) $display("INFO: %s:%0d: %s", `__FILE__, `__LINE__, (msg))

  `define WARN(msg) $display("WARNING: %s:%0d: %s", `__FILE__, `__LINE__, (msg))

  `define ERROR(msg) $display("ERROR: %s:%0d: %s", `__FILE__, `__LINE__, (msg))

  `define FATAL(msg) \
    do begin \
      $display("FATAL: %s:%0d: %s", `__FILE__, `__LINE__, (msg)); \
      `ifndef FINISH \
        $stop; \
      `else \
        $finish; \
      `endif \
    end while (0)

    `define ASSERT_EQUAL(lhs, rhs) \
      do begin \
        if ((lhs) !== (rhs)) begin \
          $display("FATAL: %s:%0d: failed assertion: %s, %s = %h, %s = %h", \
            `__FILE__, `__LINE__, `"lhs != rhs`", `"lhs`", (lhs), `"rhs`", (rhs)); \
          `ifndef FINISH \
            $stop; \
          `else \
            $finish; \
          `endif \
        end \
      end while (0)
`else
  `define DEBUG(msg) do while (0)
  `define INFO(msg) do while (0)
  `define WARN(msg) do while (0)
  `define ERROR(msg) do while (0)
  `define FATAL(msg) do while (0)
  `define ASSERT(exp) do while (0)
`endif

`endif