------------------------------------------------------------------------------
--                                                                          --
--                           ADABROKER SERVICES                             --
--                                                                          --
-- C O S E V E N T C H A N N E L A D M I N.E V E N T C H A N N E L.I M P L  --
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
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--             AdaBroker is maintained by ENST Paris University.            --
--                     (email: broker@inf.enst.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with CosEventChannelAdmin.SupplierAdmin;
with CosEventChannelAdmin.SupplierAdmin.Impl;

with CosEventChannelAdmin.ConsumerAdmin;
with CosEventChannelAdmin.ConsumerAdmin.Impl;

with CosEventChannelAdmin.EventChannel;

with CosEventChannelAdmin.EventChannel.Helper;
pragma Elaborate (CosEventChannelAdmin.EventChannel.Helper);
pragma Warnings (Off, CosEventChannelAdmin.EventChannel.Helper);

with CosEventChannelAdmin.EventChannel.Skel;
pragma Elaborate (CosEventChannelAdmin.EventChannel.Skel);
pragma Warnings (Off, CosEventChannelAdmin.EventChannel.Skel);

with PolyORB.CORBA_P.Server_Tools;

with PortableServer; use PortableServer;

with CORBA.Impl;
pragma Warnings (Off, CORBA.Impl);

with PolyORB.Tasking.Soft_Links; use PolyORB.Tasking.Soft_Links;

with PolyORB.Log;
with Priority_Queue;

package body CosEventChannelAdmin.EventChannel.Impl is

   use  PolyORB.CORBA_P.Server_Tools;

   --------------------------------
   --    Priority_Queue_Engine   --
   --------------------------------

   task type Priority_Queue_Engine is
      entry Connect (Channel : in Object_Ptr);
   end Priority_Queue_Engine;

   type Priority_Queue_Engine_Access is access Priority_Queue_Engine;

   -----------
   -- Debug --
   -----------

   use  PolyORB.Log;

   package L is new PolyORB.Log.Facility_Log ("eventchannel");
   procedure O (Message : in Standard.String; Level : Log_Level := Debug)
     renames L.Output;

   -------------
   -- Channel --
   -------------

   type Event_Channel_Record is
      record
         This     : Object_Ptr;
         Consumer : ConsumerAdmin.Impl.Object_Ptr;
         Supplier : SupplierAdmin.Impl.Object_Ptr;
         Queue    : Priority_Queue.Priority_Queue_Access;
         Engine   : Priority_Queue_Engine_Access;
      end record;

   --------------------------------
   --    Priority_Queue_Engine   --
   --------------------------------

   task body Priority_Queue_Engine is
      Data  : CORBA.Any;
      This  : Object_Ptr;
      Queue : Priority_Queue.Priority_Queue_Access;
   begin
      loop
         select
            accept Connect (Channel : in Object_Ptr)
            do
               This := Channel;
            end Connect;
         or
            terminate;
         end select;
         loop
            Enter_Critical_Section;
            Queue := This.X.Queue;
            Leave_Critical_Section;
            begin
               Priority_Queue.Pop (Queue, Data);
            exception when others =>
               exit;
            end;
            ConsumerAdmin.Impl.Post (This.X.Consumer, Data);
         end loop;
      end loop;
   end Priority_Queue_Engine;

   ------------
   -- Create --
   ------------

   function Create return Object_Ptr
   is
      Channel : Object_Ptr;
      My_Ref  : EventChannel.Ref;

   begin
      pragma Debug (O ("create channel"));

      Channel            := new Object;
      Channel.X          := new Event_Channel_Record;
      Channel.X.This     := Channel;
      Channel.X.Consumer := ConsumerAdmin.Impl.Create (Channel);
      Channel.X.Supplier := SupplierAdmin.Impl.Create (Channel);
      Priority_Queue.Create (Channel.X.Queue, 0);
      Initiate_Servant (Servant (Channel), My_Ref);
      return Channel;
   end Create;

   -------------
   -- Destroy --
   -------------

   procedure Destroy
     (Self : access Object)
   is
      pragma Warnings (Off); --  WAG:3.14
      pragma Unreferenced (Self);
      pragma Warnings (On);  --  WAG:3.14
   begin
      null;
   end Destroy;

   -------------------
   -- For_Consumers --
   -------------------

   function For_Consumers
     (Self : access Object)
     return ConsumerAdmin.Ref
   is
      R : ConsumerAdmin.Ref;

   begin
      pragma Debug (O ("create consumer admin for channel"));

      Servant_To_Reference (Servant (Self.X.Consumer), R);
      if Self.X.Engine = null then
         Self.X.Engine := new Priority_Queue_Engine;
            Self.X.Engine.Connect (Self.X.This);
      end if;

      return R;
   end For_Consumers;

   -------------------
   -- For_Suppliers --
   -------------------

   function For_Suppliers
     (Self : access Object)
     return CosEventChannelAdmin.SupplierAdmin.Ref
   is
      R : SupplierAdmin.Ref;

   begin
      pragma Debug (O ("create supplier for channel"));

      Servant_To_Reference (Servant (Self.X.Supplier), R);
      return R;
   end For_Suppliers;

   ----------
   -- Post --
   ----------

   procedure Post
     (Self : access Object;
      Data : in CORBA.Any) is
   begin
      --  ConsumerAdmin.Impl.Post (Self.X.Consumer, Data);
      Priority_Queue.Insert (Self.X.Queue, Data, 0);
   end Post;

end CosEventChannelAdmin.EventChannel.Impl;
