------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--      P O L Y O R B . G I O P _ P . S E R V I C E _ C O N T E X T S       --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2004 Free Software Foundation, Inc.             --
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

with PolyORB.Log;
with PolyORB.Representations.CDR;
with PolyORB.Tasking.Priorities;

package body PolyORB.GIOP_P.Service_Contexts is

   use PolyORB.Buffers;
   use PolyORB.Log;
   use PolyORB.Representations.CDR;
   use PolyORB.Types;

   package L is
      new PolyORB.Log.Facility_Log ("polyorb.giop_p.service_contexts");
   procedure O (Message : in String; Level : Log_Level := Debug)
     renames L.Output;

   -----------------------------------
   -- Marshall_Service_Context_List --
   -----------------------------------

   procedure Marshall_Service_Context_List
     (Buffer : access Buffers.Buffer_Type;
      QoS    : in     PolyORB.Request_QoS.QoS_Parameter_Lists.List)
   is
      use PolyORB.Request_QoS;
      use PolyORB.Request_QoS.QoS_Parameter_Lists;

      It : Iterator := First (QoS);

   begin
      pragma Debug (O ("Marshall_Service_Context_List: enter, length="
                       & Integer'Image (Length (QoS))));

      Marshall (Buffer, Types.Unsigned_Long (Length (QoS)));

      while not Last (It) loop
         declare
            Temp_Buf : Buffer_Access := new Buffer_Type;
         begin
            case Value (It).all.Kind is
               when Static_Priority =>
                  --  Marshalling a RTCorbaPriority service context

                  Marshall (Buffer, RTCorbaPriority);

                  pragma Debug
                    (O ("Processing RTCorbaPriority service context"));

                  pragma Debug
                    (O ("Priority:"
                        & PolyORB.Tasking.Priorities.External_Priority'Image
                        (Value (It).all.EP)));

                  Start_Encapsulation (Temp_Buf);
                  if Value (It).all.Kind = Static_Priority then
                     Marshall (Temp_Buf,
                               PolyORB.Types.Short (Value (It).all.EP));
                  end if;

                  Marshall (Buffer, Encapsulate (Temp_Buf));
                  Release_Contents (Temp_Buf.all);
                  Release (Temp_Buf);

               when others =>
                  null;
            end case;
         end;

         Next (It);
      end loop;

      pragma Debug (O ("Marshall_Service_Context_List: leave"));
   end Marshall_Service_Context_List;

   -------------------------------------
   -- Unmarshall_Service_Context_List --
   -------------------------------------

   procedure Unmarshall_Service_Context_List
     (Buffer : access Buffers.Buffer_Type;
      QoS    :    out PolyORB.Request_QoS.QoS_Parameter_Lists.List)
   is
      use PolyORB.Request_QoS;
      use PolyORB.Request_QoS.QoS_Parameter_Lists;

      Length : constant PolyORB.Types.Unsigned_Long := Unmarshall (Buffer);

   begin
      pragma Debug (O ("Unmarshall_Service_Context_List: enter, length ="
                       & PolyORB.Types.Unsigned_Long'Image (Length)));

      for J in 1 .. Length loop
         declare
            Context_Id   : constant Types.Unsigned_Long := Unmarshall (Buffer);

            Context_Data : aliased Encapsulation := Unmarshall (Buffer);
            Context_Buffer : aliased Buffer_Type;

            EP : PolyORB.Types.Short;

            OP : PTP.ORB_Priority;
            Ok : Boolean;

         begin
            pragma Debug
              (O ("Got context id #"
                  & PolyORB.Types.Unsigned_Long'Image (Context_Id)));

            if Context_Id = RTCorbaPriority then
               --  Unmarshalling a RTCorbaPriority service context

               Decapsulate (Context_Data'Access, Context_Buffer'Access);

               EP := Unmarshall (Context_Buffer'Access);

               PolyORB.Tasking.Priorities.To_ORB_Priority
                 (PolyORB.Tasking.Priorities.External_Priority (EP),
                  OP,
                  Ok);

               pragma Debug (O ("Processing RTCorbaPriority service context"));
               pragma Debug (O ("Priority:" & PolyORB.Types.Short'Image (EP)));

               Append (QoS,
                       new QoS_Parameter'
                       (Static_Priority,
                        OP => OP,
                        EP => PolyORB.Tasking.Priorities.External_Priority
                        (EP)));
            end if;
         end;
      end loop;

      pragma Debug (O ("Unmarshall_Service_Context_List: leave"));
   end Unmarshall_Service_Context_List;

end PolyORB.GIOP_P.Service_Contexts;