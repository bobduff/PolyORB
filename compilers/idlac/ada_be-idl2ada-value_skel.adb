------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--            A D A _ B E . I D L 2 A D A . V A L U E _ S K E L             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1999-2001 ENST Paris University, France.          --
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

with Idl_Fe.Types;          use Idl_Fe.Types;
with Idl_Fe.Tree;           use Idl_Fe.Tree;
with Idl_Fe.Tree.Synthetic; use Idl_Fe.Tree.Synthetic;

with Ada_Be.Identifiers;    use Ada_Be.Identifiers;

with Ada_Be.Debug;
pragma Elaborate_All (Ada_Be.Debug);

package body Ada_Be.Idl2Ada.Value_Skel is

   Flag : constant Natural := Ada_Be.Debug.Is_Active
     ("ada_be.idl2ada.value_skel");
   procedure O is new Ada_Be.Debug.Output (Flag);

   -------------------
   -- Gen_Node_Spec --
   -------------------

   procedure Gen_Node_Spec
     (CU   : in out Compilation_Unit;
      Node : Node_Id) is
   begin
      case Kind (Node) is

         when K_ValueType =>
            --  we have to generate code for the is_a operation
            NL (CU);
            PL (CU, "function Is_A");
            Add_With (CU, "CORBA");
            PL (CU, "  (Logical_Type_Id : Standard.String)");
            PL (CU, "  return CORBA.Boolean;");
            NL (CU);

         when K_Operation =>

            if not Abst (Parent_Scope (Node)) then
               Add_Elaborate_Body (CU);
            end if;

            --  Write the store only if the operation
            --  is not inherited from another valuetype.
            if Oldest_Supporting_ValueType (Node) = Parent_Scope (Node) then
               declare
                  Opname : constant String
                    := Ada_Operation_Name (Node);
               begin
                  Add_With (CU, "CORBA.Impl");
                  Add_With (CU, "Broca.Value.Operation_Store");
                  NL (CU);
                  Put (CU,
                       "type "
                       & Opname
                       & "_Type is access ");
                  Gen_Operation_Profile
                    (CU, Node, "CORBA.Impl.Object_Ptr",
                     With_Name => False);
                  PL (CU, ";");
                  NL (CU);
                  PL (CU,
                      "package "
                      & Opname
                      & "_Store is new Broca.Value.Operation_Store");
                  II (CU);
                  PL (CU,
                      "("
                      & Opname
                      & "_Type);");
                  DI (CU);
                  NL (CU);
               end;
            end if;

         when others =>
            null;
      end case;
   end Gen_Node_Spec;

   -------------------
   -- Gen_Node_Body --
   -------------------

   procedure Gen_Node_Body
     (CU   : in out Compilation_Unit;
      Node : Node_Id) is
   begin
      pragma Debug (O ("Gen_Node_Body : enter"));
      pragma Debug (O ("Gen_Node_Body ("
                       & Node_Kind'Image (Kind (Node))
                       & ")"));
      case Kind (Node) is

         when K_ValueType =>

            Ada_Be.Idl2Ada.Gen_Local_Is_A (CU, Node);

            Divert (CU, Elaboration);
            Add_With (CU, "Broca.Value.Value_Skel");
            PL (CU,
                "Broca.Value.Value_Skel.Is_A_Store.Register_Operation");
            PL (CU,
                "  ("
                & Ada_Full_Name (Node)
                & ".Value_Impl.Object'Tag,");
            PL (CU,
                "   "
                & Ada_Full_Name (Node)
                & ".Value_Skel.Is_A'Access);");
            NL (CU);
            Divert (CU, Visible_Declarations);


         when K_Operation =>

            declare
               Opname : constant String := Ada_Operation_Name (Node);
               V_Impl_Name : constant String
                 := Parent_Scope_Name (Node) & ".Value_Impl";
            begin
               Add_With (CU, V_Impl_Name);
               Gen_Operation_Profile
                 (CU, Node,
                  "CORBA.Impl.Object_Ptr");
               PL (CU, " is");
               PL (CU, "begin");
               II (CU);

               if Kind (Operation_Type (Node)) /= K_Void then
                  Put (CU, "return ");
               end if;

               PL (CU,
                   V_Impl_Name & "."
                   & Opname);
               Put (CU, "  ("
                    & V_Impl_Name
                    & ".Object_Ptr (Self)");
               II (CU);

               --  Other formal parameters

               declare
                  It : Node_Iterator;
                  P_Node : Node_Id;
               begin
                  Init (It, Parameters (Node));
                  while not Is_End (It) loop
                     Get_Next_Node (It, P_Node);
                     PL (CU, ",");
                     Gen_Node_Default (CU, Declarator (P_Node));
                  end loop;
               end;
               PL (CU, ");");
               DI (CU);
               DI (CU);
               PL (CU, "end " & Opname & ";");
               NL (CU);

               --  Register this operation in the proper Operation_Store.

               Divert (CU, Elaboration);
               declare
                  Original_VT_Name : constant String
                    := Ada_Full_Name
                    (Oldest_Supporting_ValueType (Node));
               begin
                  Put (CU,
                       Original_VT_Name);
                  Add_With (CU,
                            Original_VT_Name
                            & ".Value_Skel");
                  PL (CU,
                      ".Value_Skel."
                      & Opname
                      & "_Store.Register_Operation");
                  PL (CU,
                      "  ("
                      & V_Impl_Name
                      & ".Object'Tag,");
                  PL (CU,
                      "   "
                      & Parent_Scope_Name (Node)
                      & ".Value_Skel."
                      & Opname
                      & "'Access);");
                  NL (CU);
               end;

               Divert (CU, Visible_Declarations);

            end;

         when others =>
            null;
      end case;
   end Gen_Node_Body;

end Ada_Be.Idl2Ada.Value_Skel;
