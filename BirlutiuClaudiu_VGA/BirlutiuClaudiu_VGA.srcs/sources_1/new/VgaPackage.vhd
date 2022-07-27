----------------------------------------------------------------------------------
--Birlutiu Claudiu-Andrei 
-- UTCN CTI-ro
-- pachet cu constante VGA
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package VgaPackage is 
 --diagramele de timing detaliate se gasesc in documnetatie
  --am folosit constante pentru a fi usor modificarea rezolutiei ca metoda de dezvoltare ulterioara a programului

  --CONSTANTELE DE TIMING PENTRU 640/480
  --PENTRU AXA ORIZONTALA 
  constant HD :     integer := 640;    --zona de display pe orizontala
  constant HF :     integer := 16;     --front porch -regiunea inainte de retrace
  constant HB :     integer := 48;     --back porch - regiunea dupa retrace
  constant HR :     integer := 96;     --retrace (se intoarce la prima coloana )
  constant H_max :  integer := 800; --reprezinta timpul total pentru orizontala ->(scanarea pe orizontala)
  --vertical 
  constant VD : integer := 480;   --display area
  constant VF : integer := 10;    --front porch -regiunea inainte de retrace
  constant VB : integer := 33;    --back porch - regiunea dupa retrace
  constant VR : integer := 2;     --vertical retrace (se intoarce la prima linie)	  
  constant V_max : integer := 525;--reprezinta timpul total pentru verticala -> scanarea pe verticala

  --polaritate 0 la 640x480 @60Hz, la alte rezolutii aceasta e 1
  constant H_pol : std_logic := '0';
  constant V_pol : std_logic := '0';

  --definirea starilor pentru autmotul pentru sincronizare pe orizontala si verticala
  type STATE_H is ( S_HD, S_HF, S_HR, S_HB);
  type STATE_V is ( S_VD, S_VF, S_VR, S_VB);
end package;
