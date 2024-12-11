--Fijarse archivo decisiones.txt en carpeta para obtener mayor insight en decisiones tomadas
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Main is
   -- Variable global de terminación
   Global_Terminate : Boolean := False;

   -- Declaraciones globales
   task type Semaforo is
      entry Init(X : Integer);
      entry Wait;
      entry Signal;
   end Semaforo;

   task body Semaforo is
      S : Integer;
   begin
      accept Init(X : Integer) do
         S := X;
      end Init;
      loop
         exit when Global_Terminate; -- Finaliza si se solicita terminación global
         select
            when S > 0 =>
               accept Wait do
                  S := S - 1;
               end Wait;
         or
            accept Signal do
               S := S + 1;
            end Signal;
         or
            terminate;
         end select;
      end loop;
   end Semaforo;

   task type MemDEBUG is
      entry Read(Pos : in Integer; Valor : out Integer);
      entry Write(Pos, Valor : Integer);
   end MemDEBUG;

   task body MemDEBUG is
      Mi_Memoria : array (0 .. 127) of Integer := (others => 0);
   begin
      loop
         exit when Global_Terminate; -- Finaliza si se solicita terminación global
         select
            accept Write(Pos, Valor : Integer) do
               Mi_Memoria(Pos) := Valor;
            end Write;
         or
            accept Read(Pos : in Integer; Valor : out Integer) do
               Valor := Mi_Memoria(Pos);
            end Read;
         end select;
      end loop;
   end MemDEBUG;

   Valor : Integer := 8;
   MEMORIA : MemDEBUG;
   Miss_Semaforos : array (0 .. 14) of Semaforo;

   task type CPU(ID : Integer) is
      entry Start;
      entry Status;
   end CPU;

   task body CPU is
      A : Integer := 0; -- Acumulador
      IP : Integer := 1; -- Instruction Pointer
      Instruction : Integer; -- Instrucción temporal
      Temp_Value_A : Integer; -- Valor temporal
      Temp_Value_L : Integer;
      Temp_Value_S : Integer;
      Temp_Value_B : Integer;
   begin
      -- Sincronización: espera hasta que se le indique iniciar
      accept Start;
      -- Ejecución principal
      loop
         exit when Global_Terminate; -- Finaliza si se solicita terminación global
        select
         accept Status do
            Put_Line("Identificador del CPU " & Integer'Image(ID));
            Put_Line("Acumulador A: " & Integer'Image(A));
            Put_Line("Instruction Pointer IP: " & Integer'Image(IP));
         end Status;
      or
         delay 0.01; -- Evita bloqueo si no hay `entry` listo
      end select;
         MEMORIA.Read(IP, Instruction);
         Put_Line("Instrucción leída: " & Integer'Image(Instruction) & " por el CPU " & Integer'Image(ID));
         case Instruction is
            when 1 => -- LOAD
               IP := IP + 1;
               MEMORIA.Read(IP, Temp_Value_L);
               MEMORIA.Read(Temp_Value_L, A);
               IP := IP + 1;
            when 2 => -- STORE
               IP := IP + 1;
               MEMORIA.Read(IP, Temp_Value_S);
               MEMORIA.Write(Temp_Value_S, A);
               IP := IP + 1;
            when 3 => -- ADD
               IP := IP + 1;
               MEMORIA.Read(IP, Temp_Value_A);
               A := A + Temp_Value_A;
               Put_Line("Hice la suma y el valor del acumulador es: " & Integer'Image(A) & " y soy el CPU " & Integer'Image(ID));
               IP := IP + 1;
            when 4 => -- SUB
               IP := IP + 1;
               MEMORIA.Read(IP, Temp_Value_A);
               A := A - Temp_Value_A;
               IP := IP + 1;
            when 5 => -- BRCPU
               MEMORIA.Read(IP + 1, Temp_Value_B);
               if ID = Temp_Value_B then
                  MEMORIA.Read(IP + 2, Temp_Value_B);
                  IP := Temp_Value_B;
               else
                  IP := IP + 3;
               end if;
            when 6 => -- SEMINIT
               IP := IP + 1;
               MEMORIA.Read(IP, Temp_Value_S);
               Miss_Semaforos(Temp_Value_S).Init(0);
               IP := IP + 1;
            when 7 => -- SEMWAIT
               IP := IP + 1;
               MEMORIA.Read(IP, Temp_Value_S);
               Miss_Semaforos(Temp_Value_S).Wait;
               IP := IP + 1;
            when 8 => -- SEMSIGNAL
               IP := IP + 1;
               MEMORIA.Read(IP, Temp_Value_S);
               Miss_Semaforos(Temp_Value_S).Signal;
               IP := IP + 1;
            when 9 => -- Equipara la variable valor al valor del acumulador
               Valor := A;
               IP := IP + 1;
            when others =>
               -- Notificar terminación
               Put_Line("Resultado final: " & Integer'Image(Valor) & " y soy el CPU " & Integer'Image(ID));
               Global_Terminate := True;
               exit; -- Salir del bucle de la CPU actual
         end case;
      end loop;
   end CPU;

   CPU_0 : CPU(0);
   CPU_1 : CPU(1);


   type LargoInstrucciones is range 1 .. 33;
   type MisInstrucciones is array (LargoInstrucciones) of Integer;
   Codigo : constant MisInstrucciones := (5, 1, 20, 6, 1, 1, 0, 3, 13, 2, 70, 8, 0, 7, 1, 1, 71, 9, 0, 6, 0, 7, 0, 1, 70, 3, 27, 2, 71, 8, 1, 7, 0);

begin
   MEMORIA.Write(0, Valor);
   -- Carga de instrucciones en memoria
   for I in LargoInstrucciones loop
      MEMORIA.Write(Integer(I), Codigo(I));
   end loop;

   -- Sincronizar y comenzar las CPUs
   CPU_0.Start;
   CPU_1.Start;
  -- delay(0.09);
  -- CPU_0.Status;
end Main;
