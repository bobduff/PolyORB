------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--                            B R O C A . O R B                             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1999-2000 ENST Paris University, France.          --
--                                                                          --
-- AdaBroker is free software; you  can  redistribute  it and/or modify it  --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. AdaBroker  is distributed  in the hope that it will be  useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with AdaBroker; see file COPYING. If  --
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
--             AdaBroker is maintained by ENST Paris University.            --
--                     (email: broker@inf.enst.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with CORBA.Sequences.Unbounded;
with CORBA.Impl;

with Broca.IOP;
with Broca.Exceptions;
with Broca.CDR;
with Broca.Object;
with Broca.Repository;
with Broca.IIOP;
with Broca.IOP;

with Broca.Debug;
pragma Elaborate_All (Broca.Debug);

package body Broca.ORB is

   Flag : constant Natural := Broca.Debug.Is_Active ("broca.orb");
   procedure O is new Broca.Debug.Output (Flag);

   use CORBA.ORB;

   The_ORB : ORB_Ptr := null;

   package IDL_SEQUENCE_Ref is
     new CORBA.Sequences.Unbounded (CORBA.Object.Ref);

   Identifiers : ObjectIdList;
   References  : IDL_SEQUENCE_Ref.Sequence;

   -------------------
   -- IOR_To_Object --
   -------------------

   procedure IOR_To_Object
     (IOR : access Broca.Buffers.Buffer_Type;
      Ref : out CORBA.Object.Ref'Class)
   is
      use Broca.CDR;

      Nbr_Profiles : CORBA.Unsigned_Long;
      Tag : Broca.IOP.Profile_Tag;
      Type_Id : CORBA.String;
   begin
      pragma Debug (O ("IOR_To_Object : enter"));

      --  Unmarshall type id.
      Type_Id := Unmarshall (IOR);
      pragma Debug (O ("IOR_To_Object : Type_Id unmarshalled : "
                       & CORBA.To_Standard_String (Type_Id)));

      declare
         A_Ref : CORBA.Object.Ref'Class :=
           Broca.Repository.Create (CORBA.RepositoryId (Type_Id));
      begin
         if CORBA.Object.Is_Nil (A_Ref) then
            --  No classes for the string was found.
            --  Create a CORBA.Object.Ref.
            pragma Debug (O ("IOR_To_Object : A_Ref is nil."));
            --  Broca.Refs.Set (Broca.Refs.Ref (A_Ref),
            --                new Broca.Object.Object_Type);
            CORBA.Object.Set
              (A_Ref,
               CORBA.Impl.Object_Ptr'(new Broca.Object.Object_Type));
         end if;

         pragma Assert (not CORBA.Object.Is_Nil (A_Ref));

         Nbr_Profiles := Unmarshall (IOR);

         declare
            --  Get the access to the internal object.
            Obj : constant Broca.Object.Object_Ptr
              := Broca.Object.Object_Ptr
              (CORBA.Object.Object_Of (A_Ref));
         begin
            Obj.Type_Id  := Type_Id;
            Obj.Profiles := new IOP.Profile_Ptr_Array (1 .. Nbr_Profiles);
            for I in 1 .. Nbr_Profiles loop
               Tag := Unmarshall (IOR);
               case Tag is
                  when Broca.IOP.Tag_Internet_IOP =>
                     Broca.IIOP.Create_Profile
                       (IOR, Obj.Profiles (I));
                  when others =>
                     Broca.Exceptions.Raise_Bad_Param;
               end case;
            end loop;
         end;

         CORBA.Object.Set (Ref, CORBA.Object.Object_Of (A_Ref));

         --  We want to write
         --    Ref := A_Ref;
         --  but, since Ref is an out classwide parameter,
         --  its tag is constrained by the value passed
         --  to us by the caller. If that value is of a
         --  specialised reference type, i. e. any particular
         --  reference type generated in an interface stub
         --  package, we cannot assign A_Ref into it because
         --  A_Ref may be created as a CORBA.Object.Ref if
         --  no factory is registered for the unmarshalled
         --  repository ID.
         --
         --  We thus have to trust the user to pass us a proper
         --  reference type, and bypass any dynamic tag check
         --  on the reference type.

      end;

   end IOR_To_Object;

   ---------------------------
   -- List_Initial_Services --
   ---------------------------

   function List_Initial_Services return ObjectIdList is
   begin
      return Identifiers;
   end List_Initial_Services;

   --------------------------------
   -- Resolve_Initial_References --
   --------------------------------

   function Resolve_Initial_References
     (Identifier : ObjectId)
     return CORBA.Object.Ref'Class is
      use CORBA.ORB.IDL_SEQUENCE_ObjectId;
      use IDL_SEQUENCE_Ref;
   begin
      for I in 1 .. Length (Identifiers) loop
         if Element_Of (Identifiers, I) = Identifier then
            return Element_Of (References, I);
         end if;
      end loop;
      raise CORBA.InvalidName;
   end Resolve_Initial_References;

   --------------------------------
   -- Register_Initial_Reference --
   --------------------------------

   procedure Register_Initial_Reference
     (Identifier : in CORBA.ORB.ObjectId;
      Reference  : in CORBA.Object.Ref'Class)
   is
      use CORBA.ORB.IDL_SEQUENCE_ObjectId;
      use IDL_SEQUENCE_Ref;
   begin
      Append (Identifiers, Identifier);
      Append (References, CORBA.Object.Ref (Reference));
   end Register_Initial_Reference;

   ------------------
   -- Register_ORB --
   ------------------

   procedure Register_ORB (ORB : ORB_Ptr) is
   begin
      if The_ORB /= null then
         --  Only one ORB can register.
         Broca.Exceptions.Raise_Internal (1000, CORBA.Completed_No);
      end if;
      The_ORB := ORB;
   end Register_ORB;

   ---------
   -- Run --
   ---------

   procedure Run is
   begin
      if The_ORB = null then
         return;
      else
         Run (The_ORB.all);
      end if;
   end Run;

   -----------------------
   -- POA_State_Changed --
   -----------------------

   procedure POA_State_Changed
     (POA : in Broca.POA.Ref) is
   begin
      POA_State_Changed (The_ORB.all, POA);
   end POA_State_Changed;

end Broca.ORB;
