with Ada.Exceptions;
with CORBA.Object;

with AdaBroker.Debug;
pragma Elaborate (AdaBroker.Debug);

package body CORBA.Forward is

   Flag : constant Natural := AdaBroker.Debug.Is_Active ("corba.forward");
   procedure O is new AdaBroker.Debug.Output (Flag);

   ------------
   -- To_Ref --
   ------------

   function To_Ref
     (The_Ref : in CORBA.Object.Ref'Class)
      return Ref
   is
      Dummy_Result : Ref;
   begin
      Ada.Exceptions.Raise_Exception
        (Constraint_Error'Identity,
         "CORBA.Forward.To_Ref is illegal on a forwarded type" & CORBA.CRLF &
         "use From_Forward first to convert it into a non forwarded type");
      return Dummy_Result;
   end To_Ref;

   -------------
   -- Convert --
   -------------

   package body Convert is

      ------------------
      -- From_Forward --
      ------------------

      function From_Forward
        (The_Forward : in Ref)
         return Ref_Type
      is
      begin
         pragma Debug (O ("CORBA.Forward.From_Forward : entering"));
         return To_Ref (The_Forward);
      end From_Forward;

      ----------------
      -- To_Forward --
      ----------------

      function To_Forward
        (The_Ref : in Ref_Type)
         return Ref
      is
         Result : Ref;
      begin
         pragma Debug (O ("CORBA.Forward.To_Forward : enter"));
         CORBA.Object.Internal_Copy (The_Ref, Result);
         pragma Debug (O ("CORBA.Forward.To_Forward : leave"));
         return Result;
      end To_Forward;

   end Convert;

   ----------
   -- Free --
   ----------

   procedure Free (Self : in out Ref_Ptr) is
   begin
      Private_Free (Self);
   end Free;

end CORBA.Forward;

