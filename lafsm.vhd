library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_seguridad is
    Port (
        clk            : in  STD_LOGIC;
        reset          : in  STD_LOGIC;

        -- Entradas
        btnl           : in  STD_LOGIC;  -- Entrar a configuración
        btnc           : in  STD_LOGIC;  -- Confirmar acción
        clave_correcta : in  STD_LOGIC;  -- Del comparador
        sin_intentos   : in  STD_LOGIC;  -- Del contador (intentos=0)
        fin_bloqueo    : in  STD_LOGIC;  -- Del temporizador

        -- Salidas de modo (para displays/LEDs)
        modo_config         : out STD_LOGIC;
        modo_verificacion   : out STD_LOGIC;
        modo_bloqueo        : out STD_LOGIC;
        acceso_concedido    : out STD_LOGIC;

        -- Señales de control (pulsos hacia otros módulos)
        reset_intentos      : out STD_LOGIC;
        decrementar_intento : out STD_LOGIC;
        guardar_clave       : out STD_LOGIC;
        iniciar_bloqueo     : out STD_LOGIC
    );
end fsm_seguridad;

architecture Behavioral of fsm_seguridad is

    type estado_t is (
        ESPERA_CONFIG,      -- Estado inicial, esperando configuración
        CONFIG_CLAVE,       -- Usuario programa la clave
        VERIFICAR,          -- Usuario intenta ingresar clave
        ERROR_CLAVE,        -- Clave incorrecta (decrementa intentos)
        BLOQUEO,            -- Bloqueado por 30 segundos
        Acceso_grato    -- Clave correcta, puede acceder al juego
    );

    signal estado, next_estado : estado_t := ESPERA_CONFIG;

begin

    --------------------------------------------------------------------
    -- REGISTRO DE ESTADO (proceso secuencial)
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            estado <= ESPERA_CONFIG;
        elsif rising_edge(clk) then
            estado <= next_estado;
        end if;
    end process;

    --------------------------------------------------------------------
    -- LÓGICA DE TRANSICIÓN (proceso combinacional)
    --------------------------------------------------------------------
    process(estado, btnl, btnc, clave_correcta, sin_intentos, fin_bloqueo)
    begin
        -- Por defecto, se mantiene en el estado actual
        next_estado <= estado;

        case estado is

            when ESPERA_CONFIG =>
                -- Espera a que el usuario presione BTNL para configurar
                if btnl = '1' then
                    next_estado <= CONFIG_CLAVE;
                end if;

            when CONFIG_CLAVE =>
                -- Espera confirmación de la clave con BTNC
                if btnc = '1' then
                    next_estado <= VERIFICAR;
                end if;

            when VERIFICAR =>
                -- Solo evalúa cuando el usuario presiona BTNC
                if btnc = '1' then
                    if clave_correcta = '1' then
                        next_estado <= Acceso_grato;
                    elsif sin_intentos = '1' then
                        -- Ya no quedan intentos, va directo a bloqueo
                        next_estado <= BLOQUEO;
                    else
                        -- Clave incorrecta pero quedan intentos
                        next_estado <= ERROR_CLAVE;
                    end if;
                end if;

            when ERROR_CLAVE =>
                -- Estado transitorio, regresa inmediatamente a VERIFICAR
                next_estado <= VERIFICAR;

            when BLOQUEO =>
                -- Permanece bloqueado hasta que el temporizador termine
                if fin_bloqueo = '1' then
                    next_estado <= VERIFICAR;
                end if;

            when Acceso_grato =>
                -- Se mantiene aquí hasta reset externo
                -- El módulo superior detecta esta señal y habilita el juego
                next_estado <= Acceso_grato;

        end case;
    end process;

    --------------------------------------------------------------------
    -- LÓGICA DE SALIDAS (Moore - solo depende del estado)
    --------------------------------------------------------------------
    process(estado)
    begin
        -- Valores por defecto (todas las salidas en '0')
        modo_config         <= '0';
        modo_verificacion   <= '0';
        modo_bloqueo        <= '0';
        acceso_concedido    <= '0';

        -- Estas señales se manejan fuera como Mealy
        -- pero las inicializamos aquí por claridad
        -- (serán sobrescritas por las asignaciones concurrentes)
        reset_intentos      <= '0';
        decrementar_intento <= '0';
        guardar_clave       <= '0';
        iniciar_bloqueo     <= '0';

        case estado is

            when ESPERA_CONFIG =>
                -- Sistema esperando configuración inicial
                -- Opcional: podrías no activar ningún modo aquí
                modo_verificacion <= '1';

            when CONFIG_CLAVE =>
                modo_config <= '1';
                -- guardar_clave se maneja como señal Mealy fuera del process

            when VERIFICAR =>
                modo_verificacion <= '1';

            when ERROR_CLAVE =>
                modo_verificacion   <= '1';
                decrementar_intento <= '1';  -- Decrementa contador de intentos

            when BLOQUEO =>
                modo_bloqueo    <= '1';
                iniciar_bloqueo <= '1';  -- Activa el temporizador de 30s

            when Acceso_grato =>
                acceso_concedido <= '1';  -- Habilita el módulo de juego

        end case;
    end process;

    --------------------------------------------------------------------
    -- SEÑALES DE PULSO (Lógica Mealy - depende de estado + entradas)
    --------------------------------------------------------------------
    -- Estas señales generan pulsos de 1 ciclo cuando se cumplen condiciones
    
    -- guardar_clave: pulso cuando se confirma la clave en CONFIG_CLAVE
    guardar_clave <= '1' when (estado = CONFIG_CLAVE and btnc = '1') else '0';

    -- reset_intentos: pulso cuando termina el bloqueo
    -- También podrías resetear al entrar a CONFIG_CLAVE si quieres
    reset_intentos <= '1' when (estado = BLOQUEO and fin_bloqueo = '1') else '0';

end Behavioral;