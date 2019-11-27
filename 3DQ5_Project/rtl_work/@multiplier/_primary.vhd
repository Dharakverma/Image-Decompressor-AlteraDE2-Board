library verilog;
use verilog.vl_types.all;
entity Multiplier is
    port(
        op1             : in     integer;
        op2             : in     integer;
        \out\           : out    integer
    );
end Multiplier;
