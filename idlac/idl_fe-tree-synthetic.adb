------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--                I D L _ F E . T R E E . S Y N T H E T I C                 --
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
--             AdaBroker is maintained by ENST Paris University.            --
--                     (email: broker@inf.enst.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with Idl_Fe.Types;
with Idl_Fe.Tree; use Idl_Fe.Tree;

package body Idl_Fe.Tree.Synthetic is

   function Is_Interface_Type
     (Node : Node_Id)
     return Boolean is
   begin
      case Kind (Node) is
         when
           K_Interface         |
           K_Forward_Interface =>
            return True;

         when K_Scoped_Name =>
            return Is_Interface_Type
              (Node_Id (Value (Node)));

         when K_Declarator =>
            declare
               P_Node : constant Node_Id
                 := Parent (Node);
            begin
               pragma Assert (Is_Type_Declarator (P_Node));

               if Is_Empty (Array_Bounds (Node)) then
                  return Is_Interface_Type (T_Type (P_Node));
               else
                  return False;
               end if;
            end;

         when others =>
            return False;
      end case;
   end Is_Interface_Type;

   function Is_Gen_Scope
     (Node : Node_Id)
     return Boolean
   is
      K : constant Node_Kind
        := Kind (Node);
   begin
      return (False
        or else K = K_Repository
        or else K = K_Ben_Idl_File
        or else K = K_Module
        or else K = K_Interface
        or else K = K_ValueType);
   end Is_Gen_Scope;

   function Name
     (Node : in Node_Id)
     return String is
   begin
      if Definition (Node) /= null then
         return Definition (Node).Name.all;
      elsif True
        and then (Kind (Node) = K_Forward_Interface
                  or else Kind (Node) = K_Forward_ValueType)
        and then Forward (Node) /= No_Node
      then
         return Name (Forward (Node));
      else
         return "##null##";
      end if;
   end Name;

   function Parent_Scope
     (Node : in Node_Id)
     return Node_Id
   is
      Override : constant Node_Id
        := Parent_Scope_Override (Node);
   begin
      if Override /= No_Node then
         return Override;
      else
         return Original_Parent_Scope (Node);
      end if;
   end Parent_Scope;

   function Original_Parent_Scope
     (Node : in Node_Id)
     return Node_Id is
   begin
      if Definition (Node) /= null then
         return Definition (Node).Parent_Scope;
      elsif True
        and then (Kind (Node) = K_Forward_Interface
                  or else Kind (Node) = K_Forward_ValueType)
        and then Forward (Node) /= No_Node
      then
         return Original_Parent_Scope (Forward (Node));
      else
         return No_Node;
      end if;
   end Original_Parent_Scope;

   procedure Set_Parent_Scope
     (Node : in Node_Id;
      To : in Node_Id) is
   begin
      Set_Parent_Scope_Override (Node, To);
   end Set_Parent_Scope;

   function Idl_Repository_Id
     (Node : in Node_Id)
     return String
   is
      Repository_Id_Node : constant Node_Id
        := Repository_Id (Node);
   begin
      pragma Assert (Repository_Id_Node /= No_Node);

      return String_Value (Repository_Id_Node);
   end Idl_Repository_Id;

   function All_Ancestors
     (Node : Node_Id;
      Exclude : Node_List := Nil_List)
     return Node_List
   is
      It : Node_Iterator;
      I_Node : Node_Id;
      --  A scoped name in the inheritance spec.

      P_Node : Node_Id;
      --  The corresponding actual parent node.

      Result : Node_List
        := Nil_List;
   begin
      Init (It, Parents (Node));

      while not Is_End (It) loop
         Get_Next_Node (It, I_Node);

         P_Node := Value (I_Node);
         if not (False
           or else Is_In_List (Exclude, P_Node)
           or else Is_In_List (Result, P_Node)) then
            Append_Node (Result, P_Node);
            Merge_List
              (Into => Result,
               From => All_Ancestors (P_Node));
         end if;
      end loop;

      return Result;
   end All_Ancestors;

   function Integer_Value
     (Node : Node_Id)
     return Integer is
   begin
      return Integer (Expr_Value (Node).Integer_Value);
   end Integer_Value;

   function String_Value
     (Node : Node_Id)
     return String is
   begin
      return Expr_Value (Node).String_Value.all;
   end String_Value;

   function Boolean_Value
     (Node : Node_Id)
     return Boolean is
   begin
      return Expr_Value (Node).Boolean_Value;
   end Boolean_Value;

   procedure Set_String_Value
     (Node : Node_Id;
      Val  : String) is
   begin
      Set_Expr_Value
        (Node, new Constant_Value (Kind => C_String));
      Expr_Value (Node).String_Value := new String'(Val);
   end Set_String_Value;

   function Default_Repository_Id
     (Node : Node_Id)
     return String
   is
      P_Node : constant Node_Id
        := Parent_Scope (Node);
   begin
      if Kind (P_Node) = K_Repository then
         return Name (Node);
      else
         return Default_Repository_Id (Parent_Scope (Node))
           & "/" & Name (Node);
      end if;
   end Default_Repository_Id;

end Idl_Fe.Tree.Synthetic;
