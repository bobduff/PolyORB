------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                    C O R B A . F I X E D _ P O I N T                     --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2001-2004 Free Software Foundation, Inc.           --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
-- not, write to the Free Software Foundation, 59 Temple Place - Suite 330, --
-- Boston, MA 02111-1307, USA.                                              --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--                PolyORB is maintained by ACT Europe.                      --
--                    (email: sales@act-europe.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

--  $Id$

with Ada.Streams;

with PolyORB.Log;

with PolyORB.Representations.CDR.Common;

package body CORBA.Fixed_Point is

   use PolyORB.Log;

   -----------
   -- Debug --
   -----------

   package L is new PolyORB.Log.Facility_Log ("corba.fixed_point");
   procedure O (Message : in Standard.String; Level : Log_Level := Debug)
     renames L.Output;

   ---------------------
   -- this is to help --
   ---------------------

   package CDR_Fixed_F is
      new PolyORB.Representations.CDR.Common.Fixed_Point (F);

   ------------
   -- To_Any --
   ------------

   function To_Any (Item : in F) return CORBA.Any is
      Tco : CORBA.TypeCode.Object;
   begin
      CORBA.TypeCode.Internals.Set_Kind (Tco, PolyORB.Any.Tk_Fixed);
      CORBA.TypeCode.Internals.Add_Parameter
        (Tco, CORBA.To_Any (CORBA.Unsigned_Short (F'Digits)));
      CORBA.TypeCode.Internals.Add_Parameter
        (Tco, CORBA.To_Any (CORBA.Short (F'Scale)));
      declare
         Result : Any := CORBA.Get_Empty_Any_Aggregate (Tco);
         Octets : constant Ada.Streams.Stream_Element_Array
           := CDR_Fixed_F.Fixed_To_Octets (Item);
      begin
         for I in Octets'Range loop
            CORBA.Add_Aggregate_Element
              (Result,
               CORBA.To_Any (CORBA.Octet (Octets (I))));
         end loop;
         return Result;
      end;
   end To_Any;

   ----------------
   --  From_Any  --
   ----------------
   function From_Any (Item : in Any) return F is
      use type PolyORB.Any.TCKind;
   begin
      pragma Debug (O ("From_Any (Fixed) : enter"));
      if TypeCode.Kind (Get_Unwound_Type (Item))
        /= PolyORB.Any.Tk_Fixed
      then
         pragma Debug
           (O ("From_Any (Fixed) : Bad_TypeCode, type is " &
               CORBA.TCKind'Image
               (TypeCode.Kind (Get_Unwound_Type (Item)))));
         raise Bad_TypeCode;
      end if;

      declare
         use Ada.Streams;

         Nb : constant CORBA.Unsigned_Long :=
           CORBA.Get_Aggregate_Count (Item);
         Octets : Stream_Element_Array (1 .. Stream_Element_Offset (Nb)) :=
           (others => 0);
         Element : CORBA.Any;
      begin
         for I in Octets'Range loop
            pragma Debug (O ("From_Any (Fixed) : yet another octet"));
            Element :=
              CORBA.Get_Aggregate_Element (Item,
                                           CORBA.TC_Octet,
                                           CORBA.Unsigned_Long (I - 1));
            Octets (I) := Stream_Element
              (CORBA.Octet'(CORBA.From_Any (Element)));
         end loop;
         pragma Debug (O ("From_Any (Fixed) : return"));
         return CDR_Fixed_F.Octets_To_Fixed (Octets);
      exception when CORBA.Marshal =>
         pragma Debug (O ("From_Any (Fixed) : exception catched" &
                          "while returning"));
         raise CORBA.Bad_TypeCode;
      end;
   end From_Any;

end CORBA.Fixed_Point;