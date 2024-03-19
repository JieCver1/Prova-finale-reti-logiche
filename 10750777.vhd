----------------------------------------------------------------------------------
-- Università: Politecnico di Milano
-- Autore: Jie Chen
-- 
-- Create Date: 03/05/2024 10:26:34 AM
-- Module Name: project_reti_logiche - project_reti_logiche_arch
-- Project Name: Prova Finale di Reti Logiche anno accademico 2023-2024
----------------------------------------------------------------------------------

-- L'elenco delle entità usate:

-- Lettore_address: legge i_add in ingresso e manda in output o_mem_addr
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- per l'utilizzo delle funzioni aritmetiche

entity Lettore_address is
    port(
          i_clk: in std_logic;
          i_rst: in std_logic;
          input: in std_logic_vector(15 downto 0);
          output: out std_logic_vector(15 downto 0);
          sel: in std_logic;
          enable: in std_logic
          );
end Lettore_address;

architecture Lettore_address_arch of Lettore_address is
       signal stored_value: std_logic_vector(15 downto 0):= "0000000000000000"; -- per salvare l'indirizzo da trasformare come o_mem_addr.
begin
     output<=stored_value;
     
     process (i_clk,i_rst)
     -- sequenziale
     begin
          if i_rst='1' then --se reset=1, allora ripristina il registro.
              stored_value<="0000000000000000";
          elsif i_clk'event and i_clk='1' then 
              if sel='1'  then -- sel='1' segna la partenza, dove output è uguale a input.
                        stored_value<=input;
              else -- sel='0' per i successivi indirizzi
                 if enable='1' then -- enable='1' allora incrementa l'indirizzo
                        stored_value<=stored_value + "0000000000000001";
                 else -- altrimenti l'indirizzo rimane invariato
                       stored_value<=stored_value;
                 end if;
              end if;
          end if;
     end process;

end Lettore_address_arch;

-- Modificatore_sequenza: serve per modificare sequenza W nel caso in cui ci siano degli zeri nella stringa
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Modificatore_sequenza is
    Port ( 
      i_clk: in std_logic;
      i_rst: in std_logic;
      input: in std_logic_vector( 7 downto 0);
      sel: in std_logic;
      azzera: in std_logic;
      enable: in std_logic;
      output: out std_logic_vector( 7 downto 0)
     );
end Modificatore_sequenza;

architecture Modificatore_sequenza_arch of Modificatore_sequenza is
         signal stored_value: std_logic_vector(7 downto 0):="00000000"; -- per salvare l'ultimo valore diverso da zero.
begin
     output<=stored_value;
     
     process (i_clk,i_rst)
     begin
          if i_rst='1' then
              stored_value<="00000000"; --se reset=1, allora ripristina il registro.
          elsif i_clk'event and i_clk='1' then
              if sel='0' then -- caso: valore diverso da zero 
                 if azzera<='0' then 
                     if enable<='0' then
                        stored_value<=stored_value;
                     else
                        stored_value<=input;
                     end if;
                 else
                     if enable<='0' then
                        stored_value<=stored_value;
                     else
                        stored_value<="00000000";
                     end if; 
                 end if;
              else -- caso: valore uguale a zero
                  if azzera<='0' then
                     if enable<='0' then
                        stored_value<=stored_value;
                     else
                        stored_value<=stored_value;
                     end if;
                  else
                     if enable<='0' then
                        stored_value<=stored_value;
                     else
                        stored_value<="00000000";
                     end if; 
                 end if;
              end if;
          end if;
     end process;
     
end Modificatore_sequenza_arch;

-- Modificatore_cred: serve per completare sequenza con le credibilità
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Modificatore_cred is
    port(
          i_clk: in std_logic;
          i_rst: in std_logic;
          output: out std_logic_vector(7 downto 0);
          azzera:in std_logic;
          sel1,sel2: in std_logic;
          enable: in std_logic
          );
end Modificatore_cred;

architecture Modificatore_cred of Modificatore_cred is
        signal stored_value: std_logic_vector(7 downto 0):="00000000";
begin
     output<=stored_value;
     
     process (i_clk,i_rst)
     begin
          if i_rst='1' then
              stored_value<="00000000";
          elsif i_clk'event and i_clk='1' then
            if enable='1' then
               if (azzera='1' and sel1='0' )or (azzera='1' and sel1='1')then
                    stored_value<="00000000";
               elsif(azzera='0' and sel1='0') then
                    stored_value<="00011111";
               elsif(azzera='0' and sel1='1') then
                   stored_value<=stored_value;
               end if;
            else
                if sel1='1'and sel2='1' and stored_value>"00000000" then
                     stored_value<=stored_value-"00000001";
                elsif sel1='1'and sel2='1' and stored_value="00000000" then
                     stored_value<="00000000";
                else 
                    stored_value<=stored_value;
                end if;
            end if;
         end if;
end process;

end Modificatore_cred;


--Verificatore_zero: serve per verificare se i_mem_data è uguale a zero oppure no
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Verificatore_zero is
    Port ( 
        i_clk: in std_logic;
        i_rst: in std_logic;
        input:in std_logic_vector( 7 downto 0);
        enable: in std_logic;
        output: out std_logic
        );
end Verificatore_zero;

architecture Verificatore_zero_arch of Verificatore_zero is
      signal reg: std_logic:='1';
begin
    output<=reg;
    process(i_clk,i_rst)
         begin
         if i_rst='1' then
              reg<= '1'; -- per reset, verificatore assume valore uguale a zero
         elsif i_clk'event and i_clk='1' then
            if enable='1' then
                if(input="00000000")then
                    reg<='1';
                else
                    reg<='0';
                end if;
            else 
               reg<=reg;
            end if;
         end if;
    end process;   
    
end Verificatore_zero_arch;

--Contatore: per decrementare i_k in modo da tener in conto della fine della sequenza da controllare
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Contatore is
   Port ( 
          i_clk: in std_logic;
          i_rst: in std_logic;
          i_start:in std_logic;
          input: in std_logic_vector(9 downto 0);
          output: out std_logic;
          sel: in std_logic;
          enable: in std_logic
          );
end Contatore;

architecture Contatore_arch of Contatore is
    signal stored_value: std_logic_vector(9 downto 0):="0000000000";

begin

 process (i_clk,i_rst)
     -- sequenziale
     begin
          
          if i_rst='1' then
             output<='0';
          elsif i_clk'event and i_clk='1' then
              if i_start='0' then
                 output<='0';
              else
                 if enable='1' then -- attiva contatore a decrementare i_k
                     if sel='1' then
                        stored_value<=input;
                     else
                        if stored_value>"0000000001" then 
                           stored_value<=stored_value-"0000000001";
                        else -- fino al valore uguale a 1, quando arriva a 1 significa aver finito il controllo della sequenza per l'ultimo valore.
                           output<='1'; 
                         end if;
                    end if;
                else
                     if stored_value>"0000000001" then
                        stored_value<=stored_value;
                     else
                        stored_value<=stored_value;
                     end if;
               end if;
             end if;
            end if;
 end process;
             
end Contatore_arch;

-- FSM: trasmette usando i segnali per controllare il funzionamento del progetto. 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
port(
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        iniz: out std_logic; 
        rm_load : out std_logic;
        rk_load : out std_logic;
        rk_sel : out std_logic;
        en_zero : out std_logic;
        en_k: out std_logic;
        en_w : out std_logic;
        en_c : out std_logic;
        en_prec : out std_logic;
        can_sel: out std_logic;
        de_sel : out std_logic;
        o_mem_en : out std_logic;
        o_mem_we: out std_logic
    );
end FSM;

architecture FSM_arch of FSM is
    type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10); -- 11 stati 
    signal curr_state : S;
begin

    process(i_clk, i_rst)
    -- Sequenziale
    begin
        if i_rst = '1' then
            curr_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            case curr_state is
                when S0 =>
                    if i_start = '1' then
                        curr_state <= S1;
                    end if;
                when S1=>
                    curr_state <= S2;
                when S2=>
                    if i_start= '0' then
                    curr_state <= S0;
                    else
                    curr_state <= S3;
                    end if;
                when S3=>
                    curr_state <= S4;
                when S4=>
                    curr_state <= S5;
                when S5=>
                    curr_state <= S6;
                when S6=>
                    curr_state <= S7;
                when S7=>
                    curr_state <= S8;
                when S8=>
                    if i_start= '0' then
                        curr_state <= S0;
                    else 
                        curr_state <= S9;
                    end if;
                when S9=>
                        curr_state <= S10;
                when S10=>
                     curr_state <= S2;
                
            end case;
        end if;
    end process;
    
    process(curr_state)
    begin
            iniz <='0';
            rm_load <='0';
            rk_load <='0';
            rk_sel <='0';
            en_zero <='0';
            en_k <='0';
            en_w <='0';
            en_c <='0';
            en_prec<='0';
            can_sel <='0';
            de_sel <='0';
            o_mem_en <='0';
            o_mem_we <='0';
        if curr_state = S0 then
            iniz <='1';
        elsif curr_state = S1 then
            iniz <='1';
            rm_load <='1';
            rk_sel<='1';
            rk_load <='1';
            en_w <='1';
            en_c <='1';
            can_sel <='1';
            o_mem_en<='1';
        elsif curr_state = S2 then
            de_sel<='1'; --verificatore di zero w
            en_zero<='1';
        elsif curr_state = S3 then
            --en_zero<='1';
            de_sel<='1';
            en_w<='1';
        elsif curr_state = S4 then
            de_sel<='1';
            o_mem_en<='1'; 
            o_mem_we<='1';
        elsif curr_state = S5 then --inizia C
            rm_load <='1'; -- aggiorna indirizzo
            en_prec<='1';
        elsif curr_state = S6 then
            en_c<='1';
        elsif curr_state = S7 then
            o_mem_en<='1';
            o_mem_we<='1';
        elsif curr_state = S8 then
            --diminuisce contatore
            rk_load <='1';
        elsif curr_state = S9 then
            --  w successivi
            de_sel<='1';
            rm_load <='1'; 
            en_k<='1';--aggiona indirizzo
          elsif curr_state = S10 then 
            o_mem_en<='1';
end if;

 end process;

end FSM_arch;

-- Mux: gestisce i dati da scrivere in memoria: W oppure C
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux is
 port(
		input1,input2:	in std_logic_vector(7 downto 0);
		sel:	in std_logic;
		output:	out std_logic_vector(7 downto 0)
	);
end Mux;

architecture Mux_arch of Mux is

begin  
       output<=input1 when sel='1' else
               input2;

end Mux_arch;

-- Done: controlla il segnale Done in modo che scende a 0 nel clk successivo quando start ritorna a zero
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Done is
  Port (
    i_clk: in std_logic;
    i_rst: in std_logic;
    i_start: in std_logic;
    input: in std_logic;
    output:out std_logic );
end Done;

architecture Done_arch of Done is
     signal stored_value: std_logic:='0';
begin
   output<=stored_value;
    
   process (i_clk,i_rst,stored_value)
     begin
          if i_rst='1' then
              stored_value<='0';
           elsif i_clk'event and i_clk = '1' then
               if i_start='1' then
                  stored_value<=input;
               else
                  stored_value<='0';
               end if;
          end if;       
      end process;

end Done_arch;


--Project_reti_logiche: gestisce la communicazione con la memoria
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity project_reti_logiche is
    port (
                i_clk : in std_logic;
                i_rst : in std_logic;
                i_start : in std_logic;
                i_add : in std_logic_vector(15 downto 0);
                i_k   : in std_logic_vector(9 downto 0);
                
                o_done : out std_logic;
                
                o_mem_addr : out std_logic_vector(15 downto 0);
                i_mem_data : in  std_logic_vector(7 downto 0);
                o_mem_data : out std_logic_vector(7 downto 0);
                o_mem_we   : out std_logic;
                o_mem_en   : out std_logic
        );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is

-- creare dei componenti
component Lettore_address is
    port(
          i_clk: in std_logic;
          i_rst: in std_logic;
          input: in std_logic_vector(15 downto 0);
          output: out std_logic_vector(15 downto 0);
          sel: in std_logic;
          enable: in std_logic
    );
end component Lettore_address;

component Verificatore_zero is
     Port ( 
        i_clk: in std_logic;
        i_rst: in std_logic;
        input:in std_logic_vector( 7 downto 0);
        enable: in std_logic;
        output: out std_logic
        );
end component Verificatore_zero;

component Modificatore_cred is
    port(
          i_clk: in std_logic;
          i_rst: in std_logic;
          output: out std_logic_vector(7 downto 0);
          azzera:in std_logic;
          sel1: in std_logic;
          sel2: in std_logic;
          enable: in std_logic);
end component Modificatore_cred;

component Modificatore_sequenza is
     Port ( 
      i_clk: in std_logic;
      i_rst: in std_logic;
      input: in std_logic_vector( 7 downto 0);
      sel: in std_logic;
      azzera: in std_logic;
      enable: in std_logic;
      output: out std_logic_vector( 7 downto 0)
     );
end component Modificatore_sequenza;

component Contatore is
   Port ( 
          i_clk: in std_logic;
          i_rst: in std_logic;
          i_start: in std_logic;
          input: in std_logic_vector(9 downto 0);
          output: out std_logic;
          sel: in std_logic;
          enable: in std_logic
          );
end component Contatore;

component FSM is
port(
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        iniz: out std_logic; 
        rm_load : out std_logic;
        rk_load : out std_logic;
        rk_sel : out std_logic;
        en_zero : out std_logic;
        en_k: out std_logic;
        en_w : out std_logic;
        en_c : out std_logic;
        en_prec : out std_logic;
        can_sel: out std_logic;
        de_sel : out std_logic;
        o_mem_en : out std_logic;
        o_mem_we: out std_logic
        
    );
end component FSM;

component Mux is
 port(  
		input1,input2:	in std_logic_vector(7 downto 0);
		sel:	in std_logic;
		output:	out std_logic_vector(7 downto 0)
	);
end component Mux;

component Done is
  Port (
    i_clk: in std_logic;
    i_rst: in std_logic;
    i_start: in std_logic;
    input: in std_logic;
    output:out std_logic );
end component Done;

signal iniz: std_logic:='0'; 
signal rm_load :  std_logic:='0';
signal rk_load : std_logic:='0';
signal rk_sel : std_logic:='0';
signal en_zero : std_logic:='0';
signal en_k: std_logic:='0';
signal en_prec : std_logic:='0';
signal en_w : std_logic:='0';
signal en_c : std_logic:='0';
signal can_sel: std_logic:='0';
signal de_sel :  std_logic:='0';
signal data_w : std_logic_vector (7 downto 0):="00000000";
signal w_sel : std_logic:='0';
signal data_c : std_logic_vector (7 downto 0):="00000000";
signal c_sel : std_logic:='0';
signal data_k : std_logic_vector (9 downto 0):="0000000000";
signal fine : std_logic:='0';

-- istanziare i componenti
begin
     lettore_add: Lettore_address port map(
          i_clk => i_clk,
          i_rst => i_rst,
          input => i_add,
          output => o_mem_addr,
          sel => iniz,
          enable => rm_load
        );
     
     modificatore_w: Modificatore_sequenza port map(
          i_clk => i_clk,
          i_rst => i_rst,
          input => i_mem_data,
          output => data_w,
          azzera => can_sel,
          sel => w_sel,
          enable => en_w
        );
        
    modificatore_c: Modificatore_cred port map(
          i_clk => i_clk,
          i_rst => i_rst,
          output => data_c,
          azzera => can_sel,
          sel1 => w_sel,
          sel2=> en_prec,
          enable => en_c
        );
        
    verificatore_w: Verificatore_zero port map(
        i_clk => i_clk,
        i_rst => i_rst,
        input => i_mem_data,
        enable => en_zero,
        output => w_sel
       );
       
          
        
    contatore_k: Contatore port map(
          i_clk => i_clk,
          i_rst => i_rst,
          i_start=> i_start,
          input => i_k,
          output => fine,
          sel => rk_sel,
          enable => rk_load
          );
        
           
    fsm1: FSM port map(
        i_clk =>i_clk ,
        i_rst =>i_rst ,
        i_start=>i_start,
        iniz=>iniz,
        rm_load=>rm_load,
        rk_load=>rk_load,
        rk_sel=>rk_sel,
        en_zero=>en_zero,
        en_k=>en_k,
        en_w=>en_w,
        en_c =>en_c ,
        en_prec=>en_prec,
        can_sel=>can_sel,
        de_sel=>de_sel,
        o_mem_en =>o_mem_en,
        o_mem_we=>o_mem_we
        
    );
    
    mux1: mux port map(
         input1=> data_w,
         input2=> data_c,
         sel=>de_sel,
         output=>o_mem_data
    );
    
    done1: Done port map(
        i_clk => i_clk,
        i_rst => i_rst,
        input => fine,
        i_start => i_start,
        output => o_done
       );
end project_reti_logiche_arch;