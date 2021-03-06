------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                 B A C K E N D . B E _ C O R B A _ A D A                  --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2005-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
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

--  This is the package responsible of generating the CORBA Ada tree
--  from the IDL tree according to the CORBA Ada mapping
--  specifications.

with GNAT.Perfect_Hash_Generators;

package Backend.BE_CORBA_Ada is

   procedure Generate (E : Node_Id);
   --  Creates the Ada tree, then depending on the user options
   --  generate the Ada code, dumps the tree...

   --  The Generate procedure uses Visitor Functions. Visitor_XXX
   --  stands for visit IDL node XXX. The returned value of this
   --  function is either a Node_Id or a List_Id, it's related with
   --  the context of each IDL structure in the IDL tree.

   --  The source code generation is realized by calling the
   --  Backend.BE_CORBA_Ada.Generator.Generate (N); (N : the root
   --  IDL_Unit node as defined in
   --  Backend.BE_CORBA_Ada.IDL_To_Ada). This procedure uses
   --  Generate_XXX (stands for Generate the corresponding XXX node
   --  source).

   procedure Usage (Indent : Natural);
   --  Displays a help message that describes the command line options
   --  of IAC.

   -----------------------
   -- General use flags --
   -----------------------

   Impl_Packages_Gen       : Boolean := False;
   --  True when we generate implementation templates

   IR_Info_Packages_Gen    : Boolean := False;
   --  True when we generate interface repository information packages

   Disable_Pkg_Body_Gen    : Boolean := False;
   Disable_Pkg_Spec_Gen    : Boolean := False;
   --  We can generate only spec or only bodies

   Generate_Imported       : Boolean := False;
   --  Generate code for the imported IDL units

   Disable_Client_Code_Gen : Boolean := False;
   --  Control the client side code generation

   Disable_Server_Code_Gen : Boolean := False;
   --  Control the server side code generation

   ---------------------
   -- Debugging flags --
   ---------------------

   Print_Ada_Tree       : Boolean := False;
   --  Controls the dumping of the Ada tree

   Output_Unit_Withing  : Boolean := False;
   --  Outputs the "Withed" units

   Output_Tree_Warnings : Boolean := False;
   --  Outputs the warnings encountered while building the Ada tree

   -----------------------------
   -- Code optimization flags --
   -----------------------------

   --  Skeleton optimization using minimal perfect hash functions
   --  instead of the big "if .. elsif .. elsif ...". The cascading 'if'
   --  statements are no longer used. There is no command-line switch to revert
   --  to that behavior. However, we are keeping the code "just in case", and
   --  it can be invoked by setting Use_Minimal_Hash_Function to False.

   Use_Minimal_Hash_Function : constant Boolean := True;
   Optimization_Mode         : GNAT.Perfect_Hash_Generators.Optimization :=
                                 GNAT.Perfect_Hash_Generators.Memory_Space;

   Use_SII : Boolean := False;
   --  The request handling method (Static Implementation Interface or Dynamic
   --  Implementation Interface). Default is DII.

   Use_Optimized_Buffers_Allocation : Boolean := False;
   --  Marshaller optimization using a one time allocation by calculating the
   --  message body size of a GIOP request (used with SII handling).

   Use_Compiler_Alignment : Boolean := False;
   --  Marshalling optimization using Ada representation clauses to create
   --  the padding between parameters (used with SII handling).

   --  In some particular cases, some parts of the IDL tree must not be
   --  generated. The entities below achieve this goal.

   type Package_Type is
     (PK_CDR_Spec,
      PK_CDR_Body,
      PK_Buffers_Spec,
      PK_Buffers_Body,
      PK_Aligned_Spec,
      PK_Helper_Spec,
      PK_Helper_Body,
      PK_Helper_Internals_Spec,
      PK_Helper_Internals_Body,
      PK_Impl_Spec,
      PK_Impl_Body,
      PK_IR_Info_Spec,
      PK_IR_Info_Body,
      PK_Skel_Spec,
      PK_Skel_Body,
      PK_Stub_Spec,
      PK_Stub_Body);

   function Map_Particular_CORBA_Parts
     (E  : Node_Id;
      PK : Package_Type) return Boolean;
   --  The mapping for some predefined CORBA IDL entities (the CORBA module)
   --  is slightly different from the mapping of standard IDL entities. This
   --  function maps these entities and return True if the E parameter falls
   --  into the special cases.

private

   procedure Kill_Warnings_And_Checks (L : List_Id; N : Node_Id);
   --  Append to L a pragma Warnings (Off) and a pragma Suppress
   --  (Validity_Check) for N.

end Backend.BE_CORBA_Ada;
