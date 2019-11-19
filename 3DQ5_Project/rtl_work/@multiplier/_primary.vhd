library verilog;
use verilog.vl_types.all;
entity Multiplier is
    port(
        Mult_op_1       : in     integer;
        Mult_op_2       : in     integer;
        Mult_result     : out    integer
    );
end Multiplier;
