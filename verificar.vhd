library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------
-- Módulo: verificar_clave (COMPARADOR_CLAVE)
--------------------------------------------------------------------
entity verificar_clave is
    Port (
        clave_ingresada : in  STD_LOGIC_VECTOR(3 downto 0);  -- Desde switches
        clave_guardada  : in  STD_LOGIC_VECTOR(3 downto 0);  -- Desde módulo almacenamiento
        correcta        : out STD_LOGIC                       -- '1' si coinciden
    );
end verificar_clave;

architecture Behavioral of verificar_clave is
begin

    --------------------------------------------------------------------
    -- Comparación combinacional
    -- Genera '1' si ambas claves son idénticas bit a bit
    --------------------------------------------------------------------
    correcta <= '1' when clave_ingresada = clave_guardada else '0';
    
    -- Equivalente a: correcta <= '1' cuando todos los bits coinciden
    -- Se sintetiza como: (NOT XOR de cada bit) AND todos

end Behavioral;