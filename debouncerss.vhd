library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer_c is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        btn_in  : in  STD_LOGIC;
        btn_out : out STD_LOGIC
    );
end debouncer_c;

architecture Behavioral of debouncer_c is

    constant MAX_COUNT : unsigned(19 downto 0) := to_unsigned(999999, 20);

    signal counter  : unsigned(19 downto 0) := (others => '0');
    signal sync_0   : STD_LOGIC := '0';
    signal sync_1   : STD_LOGIC := '0';
    signal stable_b : STD_LOGIC := '0';

begin

    -- Sincronización
    process(clk)
    begin
        if rising_edge(clk) then
            sync_0 <= btn_in;
            sync_1 <= sync_0;
        end if;
    end process;

    -- Debounce
    process(clk, reset)
    begin
        if reset = '1' then
            counter  <= (others => '0');
            stable_b <= '0';
        elsif rising_edge(clk) then
            if sync_1 /= stable_b then
                counter <= counter + 1;
                if counter = MAX_COUNT then
                    stable_b <= sync_1;
                    counter  <= (others => '0');
                end if;
            else
                counter <= (others => '0');
            end if;
        end if;
    end process;

    btn_out <= stable_b;

end Behavioral;

