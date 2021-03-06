------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--            PORTABLEINTERCEPTOR.CLIENTREQUESTINTERCEPTOR.IMPL             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2004-2012, Free Software Foundation, Inc.          --
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

with CORBA;
with PortableInterceptor.Interceptor;

package body PortableInterceptor.ClientRequestInterceptor.Impl is

   ----------
   -- Is_A --
   ----------

   function Is_A
     (Self            : not null access Object;
      Logical_Type_Id : String) return Boolean
   is
      pragma Unreferenced (Self);
   begin
      return
        CORBA.Is_Equivalent
          (Logical_Type_Id,
           PortableInterceptor.ClientRequestInterceptor.Repository_Id)
        or else CORBA.Is_Equivalent
           (Logical_Type_Id, PortableInterceptor.Interceptor.Repository_Id)
        or else CORBA.Is_Equivalent
          (Logical_Type_Id, "IDL:omg.org/CORBA/Object:1.0");
   end Is_A;

   -----------------------
   -- Receive_Exception --
   -----------------------

   procedure Receive_Exception
     (Self : access Object;
      RI   : PortableInterceptor.ClientRequestInfo.Local_Ref)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (RI);
   begin
      null;
   end Receive_Exception;

   -------------------
   -- Receive_Other --
   -------------------

   procedure Receive_Other
     (Self : access Object;
      RI   : PortableInterceptor.ClientRequestInfo.Local_Ref)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (RI);
   begin
      null;
   end Receive_Other;

   -------------------
   -- Receive_Reply --
   -------------------

   procedure Receive_Reply
     (Self : access Object;
      RI   : PortableInterceptor.ClientRequestInfo.Local_Ref)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (RI);
   begin
      null;
   end Receive_Reply;

   ---------------
   -- Send_Poll --
   ---------------

   procedure Send_Poll
     (Self : access Object;
      RI   : PortableInterceptor.ClientRequestInfo.Local_Ref)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (RI);
   begin
      null;
   end Send_Poll;

   ------------------
   -- Send_Request --
   ------------------

   procedure Send_Request
     (Self : access Object;
      RI   : PortableInterceptor.ClientRequestInfo.Local_Ref)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (RI);
   begin
      null;
   end Send_Request;

end PortableInterceptor.ClientRequestInterceptor.Impl;
