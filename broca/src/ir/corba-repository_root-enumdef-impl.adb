----------------------------------------------
--  This file has been generated automatically
--  by AdaBroker (http://adabroker.eu.org/)
----------------------------------------------

with CORBA.Repository_Root.EnumDef.Skel;

package body CORBA.Repository_Root.EnumDef.Impl is


   ------------
   --  INIT  --
   ------------
   procedure Init (Self : access Object;
                   Real_Object :
                     CORBA.Repository_Root.IRObject.Impl.Object_Ptr;
                   Def_Kind : Corba.Repository_Root.DefinitionKind;
                   Id : CORBA.RepositoryId;
                   Name : CORBA.Identifier;
                   Version : CORBA.Repository_Root.VersionSpec;
                   Defined_In : CORBA.Repository_Root.Container_Forward.Ref;
                   IDL_Type : CORBA.TypeCode.Object;
                   IDLType_View : CORBA.Repository_Root.IDLType.Impl.Object_Ptr;
                   Members : Corba.Repository_Root.EnumMemberSeq) is
   begin
      Typedefdef.Impl.Init (Typedefdef.Impl.Object_Ptr (Self),
                            Real_Object,
                            Def_Kind,
                            Id,
                            Name,
                            Version,
                            Defined_In,
                            IDL_Type,
                            IDLType_View);
      Self.Members := Members;
   end Init;

   function get_members
     (Self : access Object)
     return CORBA.Repository_Root.EnumMemberSeq
   is
      Result : CORBA.Repository_Root.EnumMemberSeq;
   begin

      --  Insert implementation of get_members

      return Result;
   end get_members;


   procedure set_members
     (Self : access Object;
      To : in CORBA.Repository_Root.EnumMemberSeq) is
   begin

      --  Insert implementation of set_members

      null;
   end set_members;

end CORBA.Repository_Root.EnumDef.Impl;
