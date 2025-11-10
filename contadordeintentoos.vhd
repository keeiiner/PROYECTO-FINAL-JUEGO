library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador_intentos_3 is
    Port (
        clk            : in  STD_LOGIC;   -- Reloj 100 MHz Basys 3
        reset          : in  STD_LOGIC;   -- Reset general
        reset_intentos : in  STD_LOGIC;   -- Reinicia el contador a 3
        fallo_intento  : in  STD_LOGIC;   -- 1 cuando la clave es incorrecta
        intentos       : out STD_LOGIC_VECTOR(1 downto 0);  -- Valor 3,2,1,0
        sin_intentos   : out STD_LOGIC    -- 1 cuando llega a 0
    );
end contador_intentos_3;

architecture Behavioral of contador_intentos_3 is

    signal cnt : integer range 0 to 3 := 3;

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                cnt <= 3;

            elsif reset_intentos = '1' then
                cnt <= 3;

            elsif fallo_intento = '1' then
                if cnt > 0 then
                    cnt <= cnt - 1;
                end if;
            end if;

        end if;
    end process;

    -- Salida en binario (para módulo de visualización)
    intentos <= std_logic_vector(to_unsigned(cnt, 2));

    -- Señal para FSM
    sin_intentos <= '1' when cnt = 0 else '0';

end Behavioral;

