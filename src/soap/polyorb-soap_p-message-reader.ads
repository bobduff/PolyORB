------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--        P O L Y O R B . S O A P _ P . M E S S A G E . R E A D E R         --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2000-2012, Free Software Foundation, Inc.          --
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

pragma Ada_2005;

--  This package is based on Tree_Reader from the XMLada package. It is used
--  to create a DOM object using the SAX parser.

with Sax.Readers;          use Sax.Readers;
with Sax.Attributes;
with Unicode.CES;
with DOM.Core;             use DOM.Core;

private package PolyORB.SOAP_P.Message.Reader is

   type Tree_Reader is new Sax.Readers.Reader with private;
   --  Tree_Reader create a DOM tree using the SAX parser.

   function Get_Tree (Read : Tree_Reader) return Document;

private

   type Tree_Reader is new Sax.Readers.Reader with record
      Tree              : Document;
      Current_Node      : Node;
      Internal_Encoding : Unicode.CES.Encoding_Scheme;
   end record;

   overriding procedure Start_Document
     (Handler : in out Tree_Reader);

   overriding procedure Start_Element
     (Handler       : in out Tree_Reader;
      Namespace_URI : Unicode.CES.Byte_Sequence       := "";
      Local_Name    : Unicode.CES.Byte_Sequence       := "";
      Qname         : Unicode.CES.Byte_Sequence       := "";
      Atts          : Sax.Attributes.Attributes'Class);

   overriding procedure End_Element
     (Handler       : in out Tree_Reader;
      Namespace_URI : Unicode.CES.Byte_Sequence := "";
      Local_Name    : Unicode.CES.Byte_Sequence := "";
      Qname         : Unicode.CES.Byte_Sequence := "");

   overriding procedure Characters
     (Handler : in out Tree_Reader;
      Ch      : Unicode.CES.Byte_Sequence);

   overriding procedure Ignorable_Whitespace
     (Handler : in out Tree_Reader;
      Ch      : Unicode.CES.Byte_Sequence);

end PolyORB.SOAP_P.Message.Reader;
