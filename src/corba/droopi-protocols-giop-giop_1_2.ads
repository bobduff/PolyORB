------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--                       D R O O P I . G I O P. GIOP 1.2                    --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                                                                          --
--                                                                          --
------------------------------------------------------------------------------

--  $Id$

with Ada.Streams; use Ada.Streams;

with CORBA;

with Droopi.Buffers;
with Droopi.References;
with Droopi.References.IOR;
with Droopi.Types;

package Droopi.Protocols.GIOP.GIOP_1_2 is

   pragma Elaborate_Body;

   type Service_Id_Array is array (Integer range <>) of ServiceId;
   Service_Context_List_1_2 : constant Service_Id_Array;



   procedure Marshall_GIOP_Header
     (Buffer       : access Buffers.Buffer_Type;
      Message_Type : in Msg_Type;
      Message_Size : in Stream_Element_Offset;
      --  Total message size (including GIOP header).
      Fragment_Next : in Boolean);

   procedure Marshall_Request_Message
     (Buffer             : access Buffers.Buffer_Type;
      Request_Id         : in Types.Unsigned_Long;
      Target_Ref         : in Target_Address;
      Sync_Type          : in Sync_Scope;
      Operation          : in Requests.Operation_Id);


   procedure Marshall_No_Exception
    (Buffer      : access Buffers.Buffer_Type;
     Request_Id  : in Types.Unsigned_Long);


   procedure Marshall_Exception
    (Buffer      : access Buffers.Buffer_Type;
     Request_Id  : Types.Unsigned_Long;
     Reply_Type  : in Reply_Status_Type;
     Occurence   : in CORBA.Exception_Occurrence);


   procedure Marshall_Location_Forward
    (Buffer        : access Buffers.Buffer_Type;
     Request_Id    : Types.Unsigned_Long;
     Reply_Type    : in Reply_Status_Type;
     Target_Ref    : in  Droopi.References.IOR.IOR_Type);

   procedure Marshall_Needs_Addressing_Mode
    (Buffer              : access Buffers.Buffer_Type;
     Request_Id          : in Types.Unsigned_Long;
     Address_Type        : in Addressing_Disposition);


   procedure Marshall_Locate_Request
    (Buffer            : access Buffers.Buffer_Type;
     Request_Id        : in Types.Unsigned_Long;
     Target_Ref        : in Target_Address);


   procedure Marshall_Fragment
    (Buffer   : access Buffers.Buffer_Type;
     Request_Id   : in Types.Unsigned_Long);

   -------------------------------------
   --  Unmarshall procedures
   --------------------------------------

   procedure Unmarshall_Request_Message
     (Buffer            : access Buffers.Buffer_Type;
      Request_Id        : out Types.Unsigned_Long;
      Response_Expected : out Boolean;
      Target_Ref        : out Target_Address_Access;
      Operation         : out Types.String);

   procedure Unmarshall_Reply_Message
      (Buffer       : access Buffers.Buffer_Type;
       Request_Id   : out Types.Unsigned_Long;
       Reply_Status : out Reply_Status_Type);

   procedure Unmarshall_Locate_Request
     (Buffer        : access Buffers.Buffer_Type;
      Request_Id    : out Types.Unsigned_Long;
      Target_Ref    : out Target_Address);

   ---------------------------------
   --    Utilities Marshalling procedures
   ---------------------------------

   procedure Marshall
     (Buffer  : access Buffers.Buffer_Type;
      Addr    : Addressing_Disposition);

   function Unmarshall
     (Buffer  : access Buffers.Buffer_Type)
     return Addressing_Disposition;

private

   --  Explicit bounds are required in the nominal subtype
   --  in order to comply with Ravenscar restriction
   --  No_Implicit_Heap_Allocation.

   Service_Context_List_1_2 : constant Service_Id_Array (0 .. 9)
     := (0 => Transaction_Service,
         1 => Code_Sets,
         2 => Chain_By_Pass_Check,
         3 => Chain_By_Pass_Info,
         4 => Logical_Thread_Id,
         5 => Bi_Dir_IIOP,
         6 => Sending_Context_Run_Time,
         7 => Invocation_Policies,
         8 => Forwarded_Identity,
         9 => Unknown_Exception_Info);

   Major_Version : constant Types.Octet
     := 1;
   Minor_Version : constant Types.Octet
     := 2;

end Droopi.Protocols.GIOP.GIOP_1_2;
