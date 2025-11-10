library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity capturar_clave is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        modo_config  : in  STD_LOGIC;                -- 1 = estamos configurando clave
        switches     : in  STD_LOGIC_VECTOR(3 downto 0);
        clave_out    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end capturar_clave;

architecture Behavioral of capturar_clave is

    signal clave_reg : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                clave_reg <= (others => '0');

            elsif modo_config = '1' then
                -- Mientras estás en modo configuración,
                -- la clave sigue el valor de los switches
                clave_reg <= switches;
            end if;

        end if;
    end process;

    clave_out <= clave_reg;

end Behavioral;
