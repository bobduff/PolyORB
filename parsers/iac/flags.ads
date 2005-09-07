------------------------------------------------------------------------------
--                                                                          --
--                            POLYORB COMPONENTS                            --
--                                   IAC                                    --
--                                                                          --
--                                F L A G S                                 --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                           Copyright (c) 2005                             --
--            Ecole Nationale Superieure des Telecommunications             --
--                                                                          --
-- IAC is free software; you  can  redistribute  it and/or modify it under  --
-- terms of the GNU General Public License  as published by the  Free Soft- --
-- ware  Foundation;  either version 2 of the liscence or (at your option)  --
-- any  later version.                                                      --
-- IAC is distributed  in the hope that it will be  useful, but WITHOUT ANY --
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or        --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for --
-- more details.                                                            --
-- You should have received a copy of the GNU General Public License along  --
-- with this program; if not, write to the Free Software Foundation, Inc.,  --
-- 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.            --
--                                                                          --
------------------------------------------------------------------------------

with GNAT.OS_Lib;

with Types;

package Flags is

   Main_Source     : Types.Name_Id := Types.No_Name;
   --  IDL source name

   Gen_Impl_Tmpl   : Boolean       := False;
   --  True when we generate implementation templates

   Gen_Delegate    : Boolean       := False;
   --  True when we generate delegates

   Gen_Dyn_Inv     : Boolean       := True;
   --  True when we generate dynamic invocation

   Gen_Intf_Rep    : Boolean       := True;
   --  True when we generate a registration to an interface repository

   Print_Full_Tree : Boolean       := False;
   --  Output tree

   Preprocess_Only : Boolean       := False;
   --  True when we only preprocess the IDL source file and output it

   Compile_Only    : Boolean       := False;
   --  True when we only compile the IDL source file and exit

   D_Analyzer      : Boolean       := False;
   D_Scopes        : Boolean       := False;

   CPP_Arg_Values : GNAT.OS_Lib.Argument_List (1 .. 64);
   CPP_Arg_Count  : Natural := 0;

   procedure Add_CPP_Flag (S : String);
   --  Add argument S to the preprocessor flags

   procedure Scan_Flags;
   --  Scan arguments from command line and update flags above

end Flags;