------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--               CORBA.REPOSITORY_ROOT.EXTATTRIBUTEDEF.IMPL                 --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2006-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This specification is derived from the CORBA Specification, and adapted  --
-- for use with PolyORB. The copyright notice above, and the license        --
-- provisions that follow apply solely to the contents neither explicitly   --
-- nor implicitly specified by the CORBA Specification defined by the OMG.  --
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

with CORBA.Repository_Root.AttributeDef.Impl;
with CORBA.Repository_Root.IDLType;
with CORBA.Repository_Root.IRObject.Impl;

package CORBA.Repository_Root.ExtAttributeDef.Impl is

   type Object is new AttributeDef.Impl.Object with private;

   type Object_Ptr is access all Object'Class;

   function get_get_exceptions
     (Self : access Object)
      return ExcDescriptionSeq;

   procedure set_get_exceptions
     (Self : access Object;
      To   : ExcDescriptionSeq);

   function get_set_exceptions
     (Self : access Object)
      return ExcDescriptionSeq;

   procedure set_set_exceptions
     (Self : access Object;
      To   : ExcDescriptionSeq);

   function describe_attribute
     (Self : access Object)
      return ExtAttributeDescription;

   package Internals is

      procedure Init
        (Self           : access Object'Class;
         Real_Object    : IRObject.Impl.Object_Ptr;
         Def_Kind       : DefinitionKind;
         Id             : RepositoryId;
         Name           : Identifier;
         Version        : VersionSpec;
         Defined_In     : Container_Forward.Ref;
         Type_Def       : IDLType.Ref;
         Mode           : AttributeMode;
         Get_Exceptions : ExceptionDefSeq;
         Set_Exceptions : ExceptionDefSeq);
      --  Recursively initialize object fields

   end Internals;

private

   type Object is new AttributeDef.Impl.Object with record
      Get_Exceptions : ExcDescriptionSeq;
      Set_Exceptions : ExcDescriptionSeq;
   end record;

end CORBA.Repository_Root.ExtAttributeDef.Impl;
