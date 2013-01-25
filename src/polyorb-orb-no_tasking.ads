------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--               P O L Y O R B . O R B . N O _ T A S K I N G                --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2001-2012, Free Software Foundation, Inc.          --
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

--  Tasking policy for the ORB core: 'No_Tasking'.

package PolyORB.ORB.No_Tasking is

   pragma Elaborate_Body;

   use PolyORB.Components;
   use PolyORB.Jobs;
   use PolyORB.Transport;

   ---------------------------------------------------------
   -- Simple policy for configuration without any tasking --
   ---------------------------------------------------------

   --  This policy may be used for the creation of a low-profile
   --  ORB that does not depend on the Ada tasking runtime library.
   --  It is suitable for use in a node that contains only an
   --  environment task.

   type No_Tasking is new Tasking_Policy_Type with private;

   overriding procedure Handle_New_Server_Connection
     (P   : access No_Tasking;
      ORB :        ORB_Access;
      AC  :        Active_Connection);

   overriding procedure Handle_Close_Connection
     (P   : access No_Tasking;
      TE  :        Transport_Endpoint_Access);

   overriding procedure Handle_New_Client_Connection
     (P   : access No_Tasking;
      ORB :        ORB_Access;
      AC  :        Active_Connection);

   overriding procedure Handle_Request_Execution
     (P   : access No_Tasking;
      ORB :        ORB_Access;
      RJ  : access Request_Job'Class);

   overriding procedure Idle
     (P         : access No_Tasking;
      This_Task : PTI.Task_Info_Access;
      ORB       : ORB_Access);

private

   type No_Tasking is new Tasking_Policy_Type with null record;

end PolyORB.ORB.No_Tasking;
