------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                 P O L Y O R B . O B J _ A D A P T E R S                  --
--                                                                          --
--                                 S p e c                                  --
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

--  This package provides the root definition of all Object adapters.
--  An Object Adapter manages the association of references to servants.

--  $Id$

with PolyORB.Any;
with PolyORB.Any.NVList;
with PolyORB.Components;
with PolyORB.Exceptions;
with PolyORB.Objects;
with PolyORB.Servants;
with PolyORB.References;
with PolyORB.Smart_Pointers;
with PolyORB.Types;

package PolyORB.Obj_Adapters is

   type Obj_Adapter is abstract new Smart_Pointers.Entity
     with private;
   type Obj_Adapter_Access is access all Obj_Adapter'Class;

   procedure Create (OA : access Obj_Adapter) is abstract;
   --  Initialize.

   procedure Destroy (OA : access Obj_Adapter) is abstract;
   --  Finalize.

   procedure Set_ORB
     (OA      : access Obj_Adapter;
      The_ORB :        Components.Component_Access);
   --  Set the ORB whose OA is attached to.

   --------------------------------------
   -- Interface to application objects --
   --------------------------------------

   procedure Export
     (OA    : access Obj_Adapter;
      Obj   :        Servants.Servant_Access;
      Key   :        Objects.Object_Id_Access;
      Oid   :    out Objects.Object_Id_Access;
      Error : in out PolyORB.Exceptions.Error_Container)
      is abstract;
   --  Create an identifier for Obj within OA. If Key is
   --  not null, use it as an application-level identifier
   --  for the object (which will be used to construct the
   --  local identifier).

   procedure Unexport
     (OA    : access Obj_Adapter;
      Id    :        Objects.Object_Id_Access;
      Error : in out PolyORB.Exceptions.Error_Container)
      is abstract;
   --  Id is an object identifier attributed by OA.
   --  The corresponding association is suppressed.

   procedure Object_Key
     (OA      : access Obj_Adapter;
      Id      :        Objects.Object_Id_Access;
      User_Id :    out Objects.Object_Id_Access;
      Error   : in out PolyORB.Exceptions.Error_Container)
      is abstract;
   --  If Id is user defined associated with Id, return user
   --  identifier component of Id,  else raise an error.

   ----------------------------------------------------
   -- Interface to ORB (acting on behalf of clients) --
   ----------------------------------------------------

   function Get_Empty_Arg_List
     (OA     : access Obj_Adapter;
      Oid    : access Objects.Object_Id;
      Method : String)
      return Any.NVList.Ref
      is abstract;
   --  Return the parameter profile of the given method, so the
   --  protocol layer can unmarshall the message into a Request object.

   function Get_Empty_Result
     (OA     : access Obj_Adapter;
      Oid    : access Objects.Object_Id;
      Method : String)
      return Any.Any
      is abstract;
   --  Return the result profile of the given method.

   procedure Find_Servant
     (OA      : access Obj_Adapter;
      Id      : access Objects.Object_Id;
      Servant :    out Servants.Servant_Access;
      Error   : in out PolyORB.Exceptions.Error_Container)
      is abstract;
   --  Retrieve the servant managed by OA for logical object Id.
   --  The servant that incarnates the object is returned.

   procedure Release_Servant
     (OA      : access Obj_Adapter;
      Id      : access Objects.Object_Id;
      Servant : in out Servants.Servant_Access)
      is abstract;
   --  Signal to OA that a Servant previously obtained using
   --  Find_Servant won't be used by the client anymore. This
   --  may cause the servant to be destroyed if so is OA's
   --  policy.

   ----------------------------------
   -- Export of object identifiers --
   ----------------------------------

   function Oid_To_Rel_URI
     (OA : access Obj_Adapter;
      Id : access Objects.Object_Id)
     return Types.String;

   function Rel_URI_To_Oid
     (OA  : access Obj_Adapter;
      URI : Types.String)
     return Objects.Object_Id_Access;

   --  Convert an object id from/to its representation as
   --  a relative URI. A default implementation of these
   --  functions is provided; actual object adapters may
   --  overload them if desired.

   --------------------------------
   -- Proxy namespace management --
   --------------------------------

   --  The object id name space is managed entirely by the
   --  object adapter. Consequently, the OA is also responsible
   --  for assigning object IDs to virtual proxy objects
   --  corresponding to object references for which we act as
   --  a proxy.

   function Is_Proxy_Oid
     (OA  : access Obj_Adapter;
      Oid : access Objects.Object_Id)
     return Boolean;

   procedure To_Proxy_Oid
     (OA    : access Obj_Adapter;
      R     :        References.Ref;
      Oid   :    out Objects.Object_Id_Access;
      Error : in out PolyORB.Exceptions.Error_Container);

   function Proxy_To_Ref
     (OA  : access Obj_Adapter;
      Oid : access Objects.Object_Id)
     return References.Ref;

   --  These operations may be left unimplemented by some object
   --  adapter types, in which case the above two operations
   --  shall raise PolyORB.Not_Implemented.

private

   type Obj_Adapter is abstract new Smart_Pointers.Entity with
      record
         ORB : Components.Component_Access;
         --  The ORB the OA is attached to. Needs to be casted into an
         --  ORB_Access when used.
      end record;

end PolyORB.Obj_Adapters;