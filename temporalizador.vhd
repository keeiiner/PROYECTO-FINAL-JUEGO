library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_bloqueo is
    Port (
        clk             : in  STD_LOGIC;         -- 100 MHz
        reset           : in  STD_LOGIC;

        start_bloqueo   : in  STD_LOGIC;         -- Pulso desde FSM
        segundos_out    : out STD_LOGIC_VECTOR(5 downto 0); -- 30..0
        bloqueo_activo  : out STD_LOGIC;         -- 1 mientras cuenta
        fin_bloqueo     : out STD_LOGIC          -- Pulso cuando llega a 0
    );
end temporizador_bloqueo;

architecture Behavioral of temporizador_bloqueo is

    --------------------------------------------------------------------
    -- Divisor exacto a 1 Hz
    --------------------------------------------------------------------
    constant DIV_MAX : integer := 100_000_000 - 1;
    signal div_cnt   : integer range 0 to DIV_MAX := 0;
    signal tick_1hz  : std_logic := '0';

    --------------------------------------------------------------------
    -- Temporizador 30s
    --------------------------------------------------------------------
    signal segundos  : integer range 0 to 30 := 30;
    signal activo    : std_logic := '0';
    signal fin_pulso : std_logic := '0';

begin

    --------------------------------------------------------------------
    -- Generación del pulso 1 Hz
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            div_cnt  <= 0;
            tick_1hz <= '0';

        elsif rising_edge(clk) then
            if div_cnt = DIV_MAX then
                div_cnt  <= 0;
                tick_1hz <= '1';   -- pulso 1 ciclo
            else
                div_cnt  <= div_cnt + 1;
                tick_1hz <= '0';
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Contador regresivo de 30 a 0
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            segundos  <= 30;
            activo    <= '0';
            fin_pulso <= '0';

        elsif rising_edge(clk) then
            fin_pulso <= '0';   -- por defecto, pulso solo 1 ciclo

            -- Inicio del bloqueo
            if start_bloqueo = '1' then
                segundos <= 30;
                activo   <= '1';
            end if;

            -- Mientras está activo, cuenta a 1 Hz
            if activo = '1' and tick_1hz = '1' then
                if segundos > 0 then
                    segundos <= segundos - 1;
                else
                    activo    <= '0';
                    fin_pulso <= '1'; -- Pulso de fin
                end if;
            end if;

        end if;
    end process;

    --------------------------------------------------------------------
    -- Salidas
    --------------------------------------------------------------------
    segundos_out   <= std_logic_vector(to_unsigned(segundos, 6));
    bloqueo_activo <= activo;
    fin_bloqueo    <= fin_pulso;

end Behavioral;
