library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_sistema_seguridad_basys3 is
    Port (
        clk       : in  STD_LOGIC;  -- 100 MHz Basys 3
        reset_btn : in  STD_LOGIC;

        -- Botones de usuario
        btnl      : in  STD_LOGIC;
        btnc      : in  STD_LOGIC;

        -- Switches para ingresar clave
        sw        : in  STD_LOGIC_VECTOR(3 downto 0);

        -- Salidas del display 7 segmentos
        anodos    : out STD_LOGIC_VECTOR(3 downto 0);
        segmentos : out STD_LOGIC_VECTOR(6 downto 0)
    );
end top_sistema_seguridad_basys3;


architecture Behavioral of top_sistema_seguridad_basys3 is

    --------------------------------------------------------------------
    -- Señales internas
    --------------------------------------------------------------------

    signal reset        : STD_LOGIC;

    -- Botones debounced
    signal btnl_clean   : STD_LOGIC;
    signal btnc_clean   : STD_LOGIC;

    -- Claves
    signal clave_ingresada : STD_LOGIC_VECTOR(3 downto 0);
    signal clave_guardada  : STD_LOGIC_VECTOR(3 downto 0);
    signal clave_ok        : STD_LOGIC;

    -- Intentos
    signal intentos_bin   : STD_LOGIC_VECTOR(1 downto 0);
    signal sin_intentos   : STD_LOGIC;

    -- Bloqueo 30s
    signal segundos_bloqueo : STD_LOGIC_VECTOR(5 downto 0);
    signal bloqueo_activo   : STD_LOGIC;
    signal fin_bloqueo      : STD_LOGIC;

    -- Modo visualización y control
    signal modo_config       : STD_LOGIC;
    signal modo_verificacion : STD_LOGIC;
    signal modo_bloqueo      : STD_LOGIC;

    signal reset_intentos    : STD_LOGIC;
    signal guardar_clave_sig : STD_LOGIC;
    signal iniciar_bloqueo   : STD_LOGIC;

begin

    --------------------------------------------------------------------
    -- Reset limpio
    --------------------------------------------------------------------
    reset <= reset_btn;

    --------------------------------------------------------------------
    -- Debouncers para BTNL y BTNC
    --------------------------------------------------------------------
    deb_l : entity work.debouncer_c
        port map (
            clk => clk,
            reset => reset,
            btn_in => btnl,
            btn_out => btnl_clean
        );

    deb_c : entity work.debouncer_l
        port map (
            clk => clk,
            reset => reset,
            btn_in => btnc,
            btn_out => btnc_clean
        );

    --------------------------------------------------------------------
    -- Capturador de clave (ingreso usando switches)
    --------------------------------------------------------------------
          clave_ingresada <= sw;   -- directo, sin módulo capturador

    --------------------------------------------------------------------
    -- Guardar clave
    --------------------------------------------------------------------
    registro_clave : entity work.guardar_clave
        port map (
            clk => clk,
            reset => reset,
            guardar => guardar_clave_sig,
            clave_in => clave_ingresada,
            clave_guardada => clave_guardada
        );

    --------------------------------------------------------------------
    -- Verificador de clave
    --------------------------------------------------------------------
    verificador : entity work.verificar_clave
        port map (
            clave_ingresada => clave_ingresada,
            clave_guardada => clave_guardada,
            correcta => clave_ok
        );

    --------------------------------------------------------------------
    -- Contador de intentos 3->0
    --------------------------------------------------------------------
    contador : entity work.contador_intentos_3
        port map (
            clk => clk,
            reset => reset,
            reset_intentos => reset_intentos,
            fallo_intento => btnc_clean, -- presionas confirmar y fallas
            intentos => intentos_bin,
            sin_intentos => sin_intentos
        );

    --------------------------------------------------------------------
    -- Temporizador de bloqueo 30 s
    --------------------------------------------------------------------
    timer30 : entity work.temporizador_bloqueo
        port map (
            clk => clk,
            reset => reset,
            start_bloqueo => iniciar_bloqueo,
            segundos_out => segundos_bloqueo,
            bloqueo_activo => bloqueo_activo,
            fin_bloqueo => fin_bloqueo
        );

    --------------------------------------------------------------------
    -- FSM de seguridad
    --------------------------------------------------------------------
    fsm : entity work.fsm_seguridad
        port map (
            clk => clk,
            reset => reset,

            btnl => btnl_clean,
            btnc => btnc_clean,
            clave_correcta => clave_ok,
            sin_intentos => sin_intentos,
            fin_bloqueo => fin_bloqueo,

            modo_config => modo_config,
            modo_verificacion => modo_verificacion,
            modo_bloqueo => modo_bloqueo,

            reset_intentos => reset_intentos,
            guardar_clave => guardar_clave_sig,
            iniciar_bloqueo => iniciar_bloqueo
        );

    --------------------------------------------------------------------
    -- Módulo de visualización básica (intentos y bloqueo)
    --------------------------------------------------------------------
    visual : entity work.visualizacion_basica
        port map (
            clk => clk,
            reset => reset,

            modo_intentos => modo_verificacion,
            modo_bloqueo => modo_bloqueo,

            intentos => intentos_bin,
            segundos_bloqueo => segundos_bloqueo,

            anodos => anodos,
            segmentos => segmentos
        );

end Behavioral;

