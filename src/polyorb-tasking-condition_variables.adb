------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--  P O L Y O R B - T A S K I N G - C O N D I T I O N _ V A R I A B L E S   --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--             Copyright (C) 1999-2002 Free Software Fundation              --
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
--              PolyORB is maintained by ENST Paris University.             --
--                                                                          --
------------------------------------------------------------------------------

--  A complete implementation of this package is provided for all
--  tasking profiles.

--  $Id$

package body PolyORB.Tasking.Condition_Variables is

   My_Factory : Condition_Factory_Access;
   --  Real factory, corresponding to the chosen tasking profile.

   Initialized : Boolean := False;
   --  Set to True when this package is initialized.

   ---------------------------
   -- Get_Condition_Factory --
   ---------------------------

   function Get_Condition_Factory
     return Condition_Factory_Access is
   begin
      pragma Assert (Initialized);
      return My_Factory;
   end Get_Condition_Factory;

   --------------------------------
   -- Register_Condition_Factory --
   --------------------------------

   procedure Register_Condition_Factory
     (MF : Condition_Factory_Access) is
   begin
      pragma Assert (not Initialized);

      if not Initialized then
         My_Factory := MF;
         Initialized := True;
      end if;
   end Register_Condition_Factory;

end PolyORB.Tasking.Condition_Variables;
