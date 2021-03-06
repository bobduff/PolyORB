------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--        P O L Y O R B . S E R V I C E S . N A M I N G . T O O L S         --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2002-2013, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with PolyORB.Services.Naming.NamingContext.Client;
with PolyORB.Services.Naming.NamingContext.Helper;

package body PolyORB.Services.Naming.Tools is

   use PolyORB.Services.Naming.NamingContext.Helper;
   use PolyORB.Services.Naming.NamingContext.Client;
   use PolyORB.Services.Naming.NamingContext;

   subtype NameComponent_Array is
     PolyORB.Services.Naming.SEQUENCE_NameComponent.Element_Array;

   RNS  : PolyORB.Services.Naming.NamingContext.Ref;
   --  Reference to the Naming Service in use.
   --  XXX use a mechanism similar to Resolve_Initial_References.

   function Retrieve_Context
     (Name   : PolyORB.Services.Naming.Name)
     return PolyORB.Services.Naming.NamingContext.Ref;
   --  Return a CosNaming.NamingContext.Ref that designates the
   --  NamingContext registered as Name.

   ----------
   -- Init --
   ----------

   procedure Init (Ref : PolyORB.References.Ref) is
   begin
      RNS := To_Ref (Ref);
   end Init;

   ------------
   -- Locate --
   ------------

   function Locate
     (Name : PolyORB.Services.Naming.Name)
     return PolyORB.References.Ref is
   begin
      return Resolve (RNS, Name);
   end Locate;

   ------------
   -- Locate --
   ------------

   function Locate
     (Context : PolyORB.Services.Naming.NamingContext.Ref;
      Name    : PolyORB.Services.Naming.Name)
     return PolyORB.References.Ref
   is
   begin
      return Resolve (Context, Name);
   end Locate;

   ------------
   -- Locate --
   ------------

   function Locate
     (IOR_Or_Name : String;
      Sep : Character := '/')
     return PolyORB.References.Ref
   is
      Res : PolyORB.References.Ref;
   begin
      if IOR_Or_Name (IOR_Or_Name'First .. IOR_Or_Name'First + 3) = "IOR:" then
         PolyORB.References.String_To_Object (IOR_Or_Name, Res);
         return Res;
      end if;

      return Locate (Parse_Name (IOR_Or_Name, Sep));
   end Locate;

   ------------
   -- Locate --
   ------------

   function Locate
     (Context     : PolyORB.Services.Naming.NamingContext.Ref;
      IOR_Or_Name : String;
      Sep         : Character := '/')
      return PolyORB.References.Ref
   is
      Res : PolyORB.References.Ref;
   begin
      if IOR_Or_Name (IOR_Or_Name'First .. IOR_Or_Name'First + 3) = "IOR:" then
         PolyORB.References.String_To_Object (IOR_Or_Name, Res);
         return Res;
      end if;

      return Locate (Context, Parse_Name (IOR_Or_Name, Sep));
   end Locate;

   ----------------------
   -- Retrieve_Context --
   ----------------------

   function Retrieve_Context
     (Name   : PolyORB.Services.Naming.Name)
     return PolyORB.Services.Naming.NamingContext.Ref
   is
      Cur : PolyORB.Services.Naming.NamingContext.Ref := RNS;
      Ref : PolyORB.Services.Naming.NamingContext.Ref;
      N : PolyORB.Services.Naming.Name;

      NCA : constant NameComponent_Array
        := PolyORB.Services.Naming.To_Element_Array (Name);

   begin
      for I in NCA'Range loop
         N := PolyORB.Services.Naming.To_Sequence ((1 => NCA (I)));
         begin
            Ref := To_Ref (Resolve (Cur, N));
         exception
            when NotFound =>
               Ref := Bind_New_Context (Cur, N);
         end;
         Cur := Ref;
      end loop;
      return Cur;
   end Retrieve_Context;

   --------------
   -- Register --
   --------------

   procedure Register
     (Name   : String;
      Ref    : PolyORB.References.Ref;
      Rebind : Boolean := False;
      Sep    : Character := '/')
   is
      Context : NamingContext.Ref;
      NCA : constant NameComponent_Array :=
        PolyORB.Services.Naming.To_Element_Array (Parse_Name (Name, Sep));
      N : constant PolyORB.Services.Naming.Name
        := PolyORB.Services.Naming.To_Sequence ((1 => NCA (NCA'Last)));
   begin
      if NCA'Length = 1 then
         Context := RNS;
      else
         Context := Retrieve_Context
           (PolyORB.Services.Naming.To_Sequence
            (NCA (NCA'First .. NCA'Last - 1)));
      end if;

      Bind (Context, N, Ref);
   exception
      when NamingContext.AlreadyBound =>
         if Rebind then
            PolyORB.Services.Naming.NamingContext.Client.Rebind
              (Context, N, Ref);
         else
            raise;
         end if;
   end Register;

   ----------------
   -- Parse_Name --
   ----------------

   function Parse_Name
     (Name : String;
      Sep  : Character := '/')
     return PolyORB.Services.Naming.Name
   is
      Result    : PolyORB.Services.Naming.Name;
      Unescaped : String (Name'Range);
      First     : Integer := Unescaped'First;
      Last      : Integer := Unescaped'First - 1;
      Last_Unescaped_Period : Integer := Unescaped'First - 1;

      Seen_Backslash : Boolean := False;
      End_Of_NC : Boolean := False;
   begin
      for I in Name'Range loop
         if not Seen_Backslash and then Name (I) = '\' then
            Seen_Backslash := True;
         else
            --  Seen_Backslash and seeing an escaped character
            --  *or* seeing a non-escaped non-backslash character.

            if not Seen_Backslash and then Name (I) = Sep then
               --  Seeing a non-escaped Sep
               End_Of_NC := True;
            else
               --  Seeing a non-escaped non-backslash, non-Sep
               --  character, or seeing an escaped character.
               Last := Last + 1;
               Unescaped (Last) := Name (I);
               End_Of_NC := I = Name'Last;
            end if;

            if not Seen_Backslash and then Name (I) = '.' then
               Last_Unescaped_Period := Last;
            end if;

            if End_Of_NC then
               if Last_Unescaped_Period < First then
                  Last_Unescaped_Period := Last + 1;
               end if;
               Append
                 (Result, NameComponent'
                  (id   => To_PolyORB_String
                   (Unescaped (First .. Last_Unescaped_Period - 1)),
                   kind => To_PolyORB_String
                   (Unescaped (Last_Unescaped_Period + 1 .. Last))));
               Last_Unescaped_Period := Last;
               First := Last + 1;
            end if;

            Seen_Backslash := Name (I) = '\' and then not Seen_Backslash;
         end if;
      end loop;

      return Result;
   end Parse_Name;

   ----------------
   -- Unregister --
   ----------------

   procedure Unregister (Name : String) is
      N : PolyORB.Services.Naming.Name;
   begin
      Append (N,
        NameComponent'
          (id => To_PolyORB_String (Name), kind => To_PolyORB_String ("")));
      Unbind (RNS, N);
   end Unregister;

end PolyORB.Services.Naming.Tools;
