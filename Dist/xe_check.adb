------------------------------------------------------------------------------
--                                                                          --
--                          GNATDIST COMPONENTS                             --
--                                                                          --
--                            X E _ C H E C K                               --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                            1.24                              --
--                                                                          --
--           Copyright (C) 1996 Free Software Foundation, Inc.              --
--                                                                          --
-- GNATDIST is  free software;  you  can redistribute  it and/or  modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 2,  or  (at your option) any later --
-- version. GNATDIST is distributed in the hope that it will be useful, but --
-- WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHANTABI- --
-- LITY or FITNESS  FOR A PARTICULAR PURPOSE.  See the  GNU General  Public --
-- License  for more details.  You should  have received a copy of the  GNU --
-- General Public License distributed with  GNATDIST; see file COPYING.  If --
-- not, write to the Free Software Foundation, 59 Temple Place - Suite 330, --
-- Boston, MA 02111-1307, USA.                                              --
--                                                                          --
--              GNATDIST is maintained by ACT Europe.                       --
--            (email:distribution@act-europe.gnat.com).                     --
--                                                                          --
------------------------------------------------------------------------------
with Osint;            use Osint;
with Namet;            use Namet;
with Opt;
with Output;           use Output;
with Fname;            use Fname;
with ALI;              use ALI;
with Types;            use Types;
with XE_Utils;         use XE_Utils;
with XE;               use XE;
with Make;             use Make;
with GNAT.Os_Lib;      use GNAT.Os_Lib;
package body XE_Check is

   --  Once this procedure has been executed we have the following properties:

   procedure Check is

      Inconsistent : Boolean := False;
      PID  : PID_Type;
      Ali  : ALI_Id;

   begin

      if not No_Recompilation then
         if not Quiet_Output then
            Write_Program_Name;
            Write_Str (": recompiling");
            Write_Eol;
         end if;

         declare
            Compiled : Name_Id;
            Obj      : Name_Id;
            Args     : Argument_List (Gcc_Switches.First .. Gcc_Switches.Last);
            Main     : Boolean;
            Full_Name,
            Name     : File_Name_Type;
            Stamp    : Time_Stamp_Type;
            Internal : Boolean;
         begin
            Display_Commands (Verbose_Mode);
            for Switch in Gcc_Switches.First .. Gcc_Switches.Last loop
               Args (Switch) := Gcc_Switches.Table (Switch);
            end loop;
            for CUID in CUnit.First .. CUnit.Last loop
               Name := CUnit.Table (CUID).CUname;

               Look_For_Full_File_Name :
                  begin
                     Full_Name := Name & ADB_Suffix;
                     if Full_Source_Name (Full_Name) = No_File then
                        Full_Name := Name & ADS_Suffix;
                        if Full_Source_Name (Full_Name) = No_File then
                           Osint.Write_Program_Name;
                           Write_Str (": """);
                           Write_Name (Name);
                           Write_Str (""" cannot be found");
                           Exit_Program (E_Fatal);
                        end if;
                     end if;
                     Internal := Is_Predefined_File_Name (Full_Name);
                  end Look_For_Full_File_Name;

               Opt.Check_Object_Consistency := True;

               Compile_Sources
                 (Main_Source           => Full_Name,
                  Args                  => Args,
                  First_Compiled_File   => Compiled,
                  Most_Recent_Obj_File  => Obj,
                  Most_Recent_Obj_Stamp => Stamp,
                  Main_Unit             => Main,
                  Check_Internal_Files  => Internal,
                  Dont_Execute          => False,
                  Force_Compilations    => Opt.Force_Compilations and
                                           not Internal,
                  Initialize_Ali_Data   => False,
                  Max_Process           => 1);
               if Compiled = No_File then
                  Maybe_Most_Recent_Stamp (Stamp);
               else
                  Sources_Modified := True;
               end if;
            end loop;
         end;
      else
         for U in CUnit.First .. CUnit.Last loop
            Load_All_Units (CUnit.Table (U).CUname);
         end loop;
      end if;

      if not Quiet_Output then
         Write_Program_Name;
         Write_Str (": checking configuration consistency");
         Write_Eol;
      end if;

      --  Set configured unit name key to No_Ali_Id.       (1)
      for U in CUnit.First .. CUnit.Last loop
         Set_ALI_Id (CUnit.Table (U).CUname, No_ALI_Id);
      end loop;

      --  Set unit name key to null.                       (2)
      --  Set configured unit name key to the ali file id. (3)
      for U in Unit.First .. Unit.Last loop
         Set_CUID (Unit.Table (U).Uname, Null_CUID);
         Get_Name_String (Unit.Table (U).Uname);
         Name_Len := Name_Len - 2;
         Set_ALI_Id (Name_Find, Unit.Table (U).My_ALI);
      end loop;

      --  Set partition name key to Null_PID.              (4)
      for P in Partitions.First .. Partitions.Last loop
         Set_PID (Partitions.Table (P).Name, Null_PID);
      end loop;

      --  Check configured name key to detect non-Ada unit.
      for U in CUnit.First .. CUnit.Last loop
         Ali := Get_ALI_Id (CUnit.Table (U).CUname);

         --  Use (3) and (1). If null, then there is no ali
         --  file associated to this configured unit name.
         --  The configured unit is not an Ada unit.
         if Ali = No_ALI_Id then
            Write_Program_Name;
            Write_Str (": unit from configuration file ");
            Write_Name (CUnit.Table (U).CUname);
            Write_Str (" is not an Ada unit");
            Write_Eol;
            Inconsistent := True;
         else

            for I in ALIs.Table (Ali).First_Unit ..
                     ALIs.Table (Ali).Last_Unit loop

               if Unit.Table (I).RCI then

                  --  If not null, we have already set this
                  --  configured rci unit name to a partition.
                  if CUnit.Table (U).My_ALI /= No_ALI_Id then

                     Write_Program_Name;
                     Write_Str  (": RCI unit ");
                     Write_Name (CUnit.Table (U).CUname);
                     Write_Str  (" has been assigned twice");
                     Write_Eol;
                     Inconsistent := True;

                  else
                     --  This RCI has been assigned.              (5)
                     Set_CUID (Unit.Table (I).Uname, U);

                  end if;

               end if;

               if Unit.Table (I).Utype /= Is_Body then
                  CUnit.Table (U).My_Unit := I;
               end if;

            end loop;

            CUnit.Table (U).My_ALI := Ali;

            --  Set partition name to some value.                 (7)
            PID := CUnit.Table (U).Partition;
            Set_PID (Partitions.Table (PID).Name, PID);

         end if;
      end loop;

      --  Use (5) and (2). To check all RCI units are configured.
      for U in Unit.First .. Unit.Last loop
         if Unit.Table (U).RCI and then
            Get_CUID (Unit.Table (U).Uname) = Null_CUID then
            Write_Program_Name;
            Write_Str (": RCI Ada unit ");
            Write_Unit_Name (Unit.Table (U).Uname);
            Write_Str (" has not been assigned to a partition");
            Write_Eol;
            Inconsistent := True;
         end if;
      end loop;

      for P in Partitions.First .. Partitions.Last loop
         PID := Get_PID (Partitions.Table (P).Name);

         --  Use (7). Check that no partition is empty.
         if PID = Null_PID and then
           Partitions.Table (P).Main_Subprogram = No_Name then
            Write_Program_Name;
            Write_Str  (": partition ");
            Write_Name (Partitions.Table (P).Name);
            Write_Str  (" is empty");
            Write_Eol;
            Inconsistent := True;
         end if;
      end loop;

      for U in Unit.First .. Unit.Last loop
         Set_PID (Unit.Table (U).Uname, Null_PID);
      end loop;

      --  At this level, we have the following properties:
      --  Info (Partitions.Table (PID).Name) = PID
      --  Info (Unit.Table (UID).Uname)      = Null_PID
      --  Info (CUnits.Table (CUID).CUname)  = ALI

      if Inconsistent then
         raise Partitioning_Error;
      end if;

   end Check;

   procedure Initialize is
   begin
      Initialize_ALI;
   end Initialize;

end XE_Check;


