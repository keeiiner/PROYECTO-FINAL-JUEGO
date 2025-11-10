library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------
-- Módulo: guardar_clave
--------------------------------------------------------------------
entity guardar_clave is
    Port (
        clk            : in  STD_LOGIC;                      -- Clock 100 MHz
        reset          : in  STD_LOGIC;                      -- Reset síncrono (activo alto)
        guardar        : in  STD_LOGIC;                      -- Pulso de habilitación
        clave_in       : in  STD_LOGIC_VECTOR(3 downto 0);   -- Entrada desde switches
        clave_guardada : out STD_LOGIC_VECTOR(3 downto 0)    -- Clave almacenada
    );
end guardar_clave;

architecture Behavioral of guardar_clave is
    -- Registro interno de 4 bits
    signal clave_reg : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
begin

    --------------------------------------------------------------------
    -- Proceso: Almacenamiento con habilitación
    -- Captura clave_in cuando guardar='1'
    --------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clave_reg <= (others => '0');
            elsif guardar = '1' then
                clave_reg <= clave_in;  -- Guarda solo cuando se habilita
            end if;
        end if;
    end process;

    clave_guardada <= clave_reg;

end Behavioral;