with Idl_Fe.Tree; use Idl_Fe.Tree;
with Idl_Fe.Types; use Idl_Fe.Types;

package Idl_Fe.Display_Tree is

   Offset : constant Natural := 2;

   procedure Disp_Tree (Tree : N_Root'Class);

   --  display a node list
   procedure Disp_List (List : Node_List; Indent : Natural; Full : Boolean);

private

   --  display the indentation
   procedure Disp_Indent (Indent : Natural; S : String := "");

   --  displays a binary operator
   procedure Disp_Binary (N : N_Binary_Expr'Class;
                          Indent : Natural;
                          Full : Boolean;
                          Op : String);

   --  displays a unary operator
   procedure Disp_Unary (N : N_Unary_Expr'Class;
                         Indent : Natural;
                         Full : Boolean;
                         Op : String);

end Idl_Fe.Display_Tree;
