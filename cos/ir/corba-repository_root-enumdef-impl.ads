----------------------------------------------
--  This file has been generated automatically
--  by AdaBroker (http://adabroker.eu.org/)
----------------------------------------------

with CORBA.Repository_Root.IRObject.Impl;
with CORBA.Repository_Root.IDLType.Impl;
with CORBA.Repository_Root.TypedefDef.Impl;

package CORBA.Repository_Root.EnumDef.Impl is

   type Object is
     new CORBA.Repository_Root.TypedefDef.Impl.Object with private;

   type Object_Ptr is access all Object'Class;

   --  To transform a forward_ref in impl.object_ptr.
   function To_Object (Fw_Ref : EnumDef_Forward.Ref)
                       return Object_Ptr;

   --  To transform an object_ptr into Forward_ref
   function To_Forward (Obj : Object_Ptr)
                        return EnumDef_Forward.Ref;

   --  method used to initialize recursively the object fields.
   procedure Init
     (Self : access Object;
      Real_Object : CORBA.Repository_Root.IRObject.Impl.Object_Ptr;
      Def_Kind : CORBA.Repository_Root.DefinitionKind;
      Id : CORBA.RepositoryId;
      Name : CORBA.Identifier;
      Version : CORBA.Repository_Root.VersionSpec;
      Defined_In : CORBA.Repository_Root.Container_Forward.Ref;
      IDLType_View : CORBA.Repository_Root.IDLType.Impl.Object_Ptr;
      Members : CORBA.Repository_Root.EnumMemberSeq);

   --  overload the get_type from IDLType
   function get_type
     (Self : access Object)
     return CORBA.TypeCode.Object;

   function get_members
     (Self : access Object)
      return CORBA.Repository_Root.EnumMemberSeq;

   procedure set_members
     (Self : access Object;
      To : in CORBA.Repository_Root.EnumMemberSeq);

private

   type Object is new CORBA.Repository_Root.TypedefDef.Impl.Object with record
      Members : CORBA.Repository_Root.EnumMemberSeq;
   end record;

end CORBA.Repository_Root.EnumDef.Impl;
