
--  This package is wrapped around a C++ class whose name is BOA declared
--  in file CORBA.h.  It provides two types of methods : the C functions of
--  the BOA class and their equivalent in Ada. (the first ones have a C_
--  prefix.)

with AdaBroker.Sysdep;  use AdaBroker.Sysdep;
with AdaBroker.OmniORB; use AdaBroker.OmniORB;

package body CORBA.BOA is

   -------------------------------
   -- C_Implementation_Is_Ready --
   -------------------------------

   procedure C_Implementation_Is_Ready
     (Self                  : in Object;
      ImplementationDef_Ptr : in System.Address;
      Non_Blocking          : in Bool);
   pragma Import
     (CPP, C_Implementation_Is_Ready,
      "impl_is_ready__FPQ25CORBA3BOAPQ25CORBA17ImplementationDefb");
   --  Corresponds to Ada_CORBA_Boa method impl is ready see
   --  Ada_CORBA_Boa.hh

   -----------------------------
   -- Implementation_Is_Ready --
   -----------------------------
   procedure Implementation_Is_Ready
     (Self         : in Object;
      Non_Blocking : in Boolean := False)
   is
      Tmp : System.Address    := System.Null_Address;
      NB  : Bool := To_Bool (Non_Blocking);
   begin
      C_Implementation_Is_Ready (Self, Tmp, NB);
   end Implementation_Is_Ready;

   ---------------------
   -- Object_Is_Ready --
   ---------------------

   procedure Object_Is_Ready
     (Self : in Object;
      Obj  : in ImplObject'Class)
   is
   begin
      --  It does not take the BOA into account because thereis only one
      --  BOA in omniORB2. ( See corbaBoa.cc)
      Object_Is_Ready (Obj);
   end Object_Is_Ready;

   ---------------------
   -- Object_Is_Ready --
   ---------------------

   procedure Dispose_Object
     (Self : in Object;
      Obj  : in ImplObject'Class)
   is
   begin
      --  It does not take the BOA into account because thereis only one
      --  BOA in omniORB2. ( See corbaBoa.cc)
      Dispose_Object (Obj);
   end Dispose_Object;

end CORBA.BOA;
