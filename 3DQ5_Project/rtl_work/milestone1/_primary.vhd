library verilog;
use verilog.vl_types.all;
entity milestone1 is
    port(
        CLOCK_50_I      : in     vl_logic;
        Resetn          : in     vl_logic;
        start_bit       : in     vl_logic;
        SRAM_read_data  : in     vl_logic_vector(15 downto 0);
        write_data      : out    vl_logic_vector(15 downto 0);
        address         : out    vl_logic_vector(17 downto 0);
        write_en_n      : out    vl_logic;
        milestone1_finish: out    vl_logic
    );
end milestone1;
