library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity visualizacion_basica is
    Port (
        clk              : in  STD_LOGIC;
        reset            : in  STD_LOGIC;

        -- Modo visual (solo uno debe estar activo)
        modo_intentos    : in  STD_LOGIC;
        modo_bloqueo     : in  STD_LOGIC;

        -- Datos
        intentos         : in  STD_LOGIC_VECTOR(1 downto 0); -- 0..3
        segundos_bloqueo : in  STD_LOGIC_VECTOR(5 downto 0); -- 0..30

        -- Salidas
        anodos           : out STD_LOGIC_VECTOR(3 downto 0);
        segmentos        : out STD_LOGIC_VECTOR(6 downto 0)
    );
end visualizacion_basica;

architecture Behavioral of visualizacion_basica is

    --------------------------------------------------------------------
    -- Multiplexado a ~1kHz
    --------------------------------------------------------------------
    constant DIVISOR : integer := 100_000;
    signal div_cnt   : integer range 0 to DIVISOR := 0;
    signal mux_idx   : integer range 0 to 3 := 0;

    --------------------------------------------------------------------
    -- Valores de cada dígito
    --------------------------------------------------------------------
    signal d0, d1, d2, d3 : integer range 0 to 9 := 0;

    --------------------------------------------------------------------
    -- Decodificador
    --------------------------------------------------------------------
    function to7seg(n : integer) return STD_LOGIC_VECTOR is
    begin
        case n is
            when 0 => return "0000001";
            when 1 => return "1001111";
            when 2 => return "0010010";
            when 3 => return "0000110";
            when 4 => return "1001100";
            when 5 => return "0100100";
            when 6 => return "0100000";
            when 7 => return "0001111";
            when 8 => return "0000000";
            when 9 => return "0000100";
            when others => return "1111111";
        end case;
    end function;

begin

    --------------------------------------------------------------------
    -- LOGICA DE SELECCIÓN DE QUÉ MOSTRAR (sin latches)
    --------------------------------------------------------------------
    process(modo_intentos, modo_bloqueo, intentos, segundos_bloqueo)
        variable val  : integer;
        variable dec  : integer;
        variable uni  : integer;
    begin
        -- Default
        d0 <= 0;
        d1 <= 0;
        d2 <= 0;
        d3 <= 0;

        if modo_intentos = '1' then
            d3 <= to_integer(unsigned(intentos));

        elsif modo_bloqueo = '1' then
            val := to_integer(unsigned(segundos_bloqueo)); -- 0..30
            dec := val / 10;
            uni := val mod 10;

            d2 <= dec;
            d3 <= uni;
        end if;
    end process;

    --------------------------------------------------------------------
    -- DIVISOR DE FRECUENCIA PARA MULTIPLEXAR LOS 4 DIGITOS
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            div_cnt <= 0;
            mux_idx <= 0;

        elsif rising_edge(clk) then
            if div_cnt = DIVISOR then
                div_cnt <= 0;
                mux_idx <= (mux_idx + 1) mod 4;
            else
                div_cnt <= div_cnt + 1;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- MUX DE LOS 4 DIGITOS (ANODOS + SEGMENTOS)
    --------------------------------------------------------------------
    process(mux_idx, d0, d1, d2, d3)
    begin
        case mux_idx is
            when 0 =>
                anodos    <= "0111";   -- AN0
                segmentos <= to7seg(d0);

            when 1 =>
                anodos    <= "1011";   -- AN1
                segmentos <= to7seg(d1);

            when 2 =>
                anodos    <= "1101";   -- AN2
                segmentos <= to7seg(d2);

            when 3 =>
                anodos    <= "1110";   -- AN3
                segmentos <= to7seg(d3);

            when others =>
                anodos    <= "1111";
                segmentos <= "1111111";
        end case;
    end process;

end Behavioral;
