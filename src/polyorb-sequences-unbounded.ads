------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--          P O L Y O R B . S E Q U E N C E S . U N B O U N D E D           --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2002-2003 Free Software Foundation, Inc.           --
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

--  This package provides the definitions required by the IDL-to-Ada
--  mapping specification for unbounded sequences. This package is
--  instantiated for each IDL unbounded sequence type. This package
--  defines the sequence type and the operations upon it. This package
--  is modelled after Ada.Strings.Unbounded and is compliant with the
--  specifications of CORBA.Sequences.Unounded defined in the CORBA
--  Ada Mapping.
--
--  Most query operations are not usable until the sequence object has been
--  initialized through an assignment.
--
--  Value semantics apply to assignment, that is, assignment of a sequence
--  value to a sequence object yields a copy of the value.
--
--  The user should not assume safety under tasking, i.e. the
--  implementation only support sequential semantics.
--
--  Indices of elements of sequences are from 1 .. n, i.e.  they follow the
--  normal Ada convention.
--
--  The exception INDEX_ERROR is raised when indexes are not in the range
--  of the object being manipulated.
--
--  Sequences are automatically initialized to zero length, so users should
--  not see Constraint_Error raised.

with Ada.Finalization;

generic

    type Element is private;

package PolyORB.Sequences.Unbounded is

   pragma Preelaborate;

   type Element_Array is array (Integer range <>) of Element;

   type Sequence is private;

   function Null_Sequence return Sequence;

   function Length (Source : in Sequence) return Natural;

   type Element_Array_Access is access all Element_Array;

   procedure Free (X : in out Element_Array_Access);

   --------------------------------------------------------
   -- Conversion, Concatenation, and Selection functions --
   --------------------------------------------------------

   function To_Sequence
     (Source : in Element_Array)
     return Sequence;

   procedure Set
     (Item   : in out Sequence;
      Source : in     Element_Array);

   function To_Sequence
     (Length : in Natural)
     return Sequence;

   function To_Element_Array
     (Source : in Sequence)
     return Element_Array;

   procedure Append
     (Source   : in out Sequence;
      New_Item : in     Sequence);

   procedure Append
     (Source   : in out Sequence;
      New_Item : in     Element_Array);

   procedure Append
     (Source   : in out Sequence;
      New_Item : in     Element);

   function "&"
     (Left, Right : in Sequence)
     return Sequence;

   function "&"
     (Left  : in Sequence;
      Right : in Element_Array)
     return Sequence;

   function "&"
     (Left  : in Element_Array;
      Right : in Sequence)
     return Sequence;

   function "&"
     (Left  : in Sequence;
      Right : in Element)
     return Sequence;

   function "&"
     (Left  : in Element;
      Right : in Sequence)
     return Sequence;

   function Element_Of
     (Source : in Sequence;
      Index  : in Positive)
     return Element;

   function Get_Element
     (Source : in Sequence;
      Index  : in Positive)
     return Element
     renames Element_Of;
   --  For compliance with CORBA specifications.

   procedure Replace_Element
     (Source : in out Sequence;
      Index  : in     Positive;
      By     : in     Element);

   function Slice
     (Source : in Sequence;
      Low    : in Positive;
      High   : in Natural)
      return Element_Array;

   function "="
     (Left, Right : in Sequence)
     return Boolean;

   function "="
     (Left  : in Element_Array;
      Right : in Sequence)
     return Boolean;

   function "="
     (Left  : in Sequence;
      Right : in Element_Array)
     return Boolean;

   function Is_Null
     (Source : in Sequence)
     return Boolean;
   --  Equivalent to (Source = Null_Sequence).

   ----------------------
   -- Search functions --
   ----------------------

   function Index
     (Source  : in Sequence;
      Pattern : in Element_Array;
      Going   : in Direction := Forward)
      return Natural;

   function Count
     (Source  : in Sequence;
      Pattern : in Element_Array)
      return Natural;

   -----------------------------------------
   -- Sequence transformation subprograms --
   -----------------------------------------

   function Replace_Slice
     (Source : in Sequence;
      Low    : in Positive;
      High   : in Natural;
      By     : in Element_Array)
      return Sequence;

   procedure Replace_Slice
     (Source : in out Sequence;
      Low    : in     Positive;
      High   : in     Natural;
      By     : in     Element_Array);

   function Insert
     (Source   : in Sequence;
      Before   : in Positive;
      New_Item : in Element_Array)
      return Sequence;

   procedure Insert
     (Source   : in out Sequence;
      Before   : in     Positive;
      New_Item : in     Element_Array);

   function Overwrite
     (Source   : in Sequence;
      Position : in Positive;
      New_Item : in Element_Array)
      return Sequence;

   procedure Overwrite
     (Source   : in out Sequence;
      Position : in     Positive;
      New_Item : in     Element_Array);

   function Delete
     (Source  : in Sequence;
      From    : in Positive;
      Through : in Natural)
      return Sequence;

   procedure Delete
     (Source  : in out Sequence;
      From    : in     Positive;
      Through : in     Natural);

   -----------------------------------
   -- Sequence selector subprograms --
   -----------------------------------

   function Head
     (Source : in Sequence;
      Count  : in Natural;
      Pad    : in Element)
      return Sequence;

   procedure Head
     (Source : in out Sequence;
      Count  : in     Natural;
      Pad    : in     Element);

   function Tail
     (Source : in Sequence;
      Count  : in Natural;
      Pad    : in Element)
      return Sequence;

   procedure Tail
     (Source : in out Sequence;
      Count  : in     Natural;
      Pad    : in     Element);

   --------------------------------------
   -- Sequence constructor subprograms --
   --------------------------------------

   function "*"
     (Left  : in Natural;
      Right : in Element)
     return Sequence;

   function "*"
     (Left  : in Natural;
      Right : in Element_Array)
     return Sequence;

   function "*"
     (Left  : in Natural;
      Right : in Sequence)
     return Sequence;

private

   pragma Inline (Null_Sequence);

   Prealloc_Length : constant := 5;

   type Sequence is new Ada.Finalization.Controlled with
      record
         Length  : Natural;
         Content : Element_Array_Access;
      end record;

   procedure Initialize (Object : in out Sequence);
   procedure Adjust (Object : in out Sequence);
   procedure Finalize (Object : in out Sequence);

   procedure Allocate
     (Source : in out Sequence;
      Length : in Natural);
   --  Allocate Source.Content and set Source.Length to Length. Do not
   --  release previous Source.Content.

end PolyORB.Sequences.Unbounded;
