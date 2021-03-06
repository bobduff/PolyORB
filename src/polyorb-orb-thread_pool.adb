------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--              P O L Y O R B . O R B . T H R E A D _ P O O L               --
--                                                                          --
--                                 B o d y                                  --
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

pragma Ada_2012;

with PolyORB.Components;
with PolyORB.Filters.Iface;
with PolyORB.Initialization;

with PolyORB.Log;
with PolyORB.ORB_Controller;
with PolyORB.Parameters;
with PolyORB.Setup;
with PolyORB.Task_Info;
with PolyORB.Tasking.Condition_Variables;
with PolyORB.Tasking.Threads;
with PolyORB.Utils.Strings;

package body PolyORB.ORB.Thread_Pool is

   use PolyORB.Filters.Iface;
   use PolyORB.Log;
   use PolyORB.ORB_Controller;
   use PolyORB.Parameters;
   use PolyORB.Task_Info;
   use PolyORB.Tasking.Threads;

   package L is new PolyORB.Log.Facility_Log ("polyorb.orb.thread_pool");
   procedure O (Message : String; Level : Log_Level := Debug)
     renames L.Output;
   function C (Level : Log_Level := Debug) return Boolean
     renames L.Enabled;

   ----------------------------
   -- Operational parameters --
   ----------------------------

   Start_Threads         : Natural;
   --  Threads craeted initially

   Minimum_Spare_Threads : Natural;
   --  Minimal number of idle threads to maintain continuously

   Maximum_Spare_Threads : Natural;
   --  Maximum number of idel threads

   Maximum_Threads       : Natural;
   --  Maximum number of threads

   Default_Start_Threads         : constant := 4;
   Default_Minimum_Spare_Threads : constant := 2;
   Default_Maximum_Spare_Threads : constant := 4;
   Default_Maximum_Threads       : constant := 10;

   procedure Thread_Pool_Main_Loop;
   --  Main loop for threads in the pool

   procedure Check_Spares (ORB : ORB_Access);
   --  Check the current count of spare (idle) tasks, and create a new one
   --  if necessary. This must be called within the ORB critical section.

   ---------------------------
   -- Thread_Pool_Main_Loop --
   ---------------------------

   procedure Thread_Pool_Main_Loop is
   begin
      pragma Debug (C, O ("Thread_Pool_Main_Loop: enter "
                       & Image (Current_Task)));

      PolyORB.ORB.Run (Setup.The_ORB, May_Exit => True);

      pragma Debug (C, O ("Thread_Pool_Main_Loop: leave "
                       & Image (Current_Task)));
   end Thread_Pool_Main_Loop;

   -----------------------------
   -- Handle_Close_Connection --
   -----------------------------

   overriding procedure Handle_Close_Connection
     (P   : access Thread_Pool_Policy;
      TE  : Transport_Endpoint_Access)
   is
      pragma Warnings (Off);
      pragma Unreferenced (P);
      pragma Unreferenced (TE);
      pragma Warnings (On);

   begin
      null;
   end Handle_Close_Connection;

   ----------------------------------
   -- Handle_New_Server_Connection --
   ----------------------------------

   overriding procedure Handle_New_Server_Connection
     (P   : access Thread_Pool_Policy;
      ORB : ORB_Access;
      AC  : Active_Connection)
   is
      pragma Warnings (Off);
      pragma Unreferenced (P, ORB);
      pragma Warnings (On);

   begin
      pragma Debug (C, O ("New server connection"));

      Components.Emit_No_Reply (Component_Access (AC.TE),
         Connect_Indication'(null record));

      --  The newly-created channel will be monitored by general purpose ORB
      --  tasks when the binding object sends a Data_Expected message to the
      --  endpoint (which will in turn send Monitor_Endpoint to the ORB).
   end Handle_New_Server_Connection;

   ----------------------------------
   -- Handle_New_Client_Connection --
   ----------------------------------

   overriding procedure Handle_New_Client_Connection
     (P   : access Thread_Pool_Policy;
      ORB :        ORB_Access;
      AC  :        Active_Connection)
   is
      pragma Warnings (Off);
      pragma Unreferenced (P, ORB);
      pragma Warnings (On);

   begin
      pragma Debug (C, O ("New client connection"));

      Components.Emit_No_Reply (Component_Access (AC.TE),
         Connect_Confirmation'(null record));

      --  Same comment as Handle_New_Server_Connection.
   end Handle_New_Client_Connection;

   ------------------
   -- Check_Spares --
   ------------------

   procedure Check_Spares (ORB : ORB_Access) is
      OC : ORB_Controller.ORB_Controller'Class renames ORB.ORB_Controller.all;
      Current_Spares : Natural;
      Max_New_Spares : Integer;
      New_Spares     : Integer;
   begin
      Current_Spares := Get_Tasks_Count (OC, Kind => Permanent, State => Idle);
      New_Spares := 0;

      if Current_Spares < Minimum_Spare_Threads
        and then not Shutting_Down (OC)
      then
         --  Note that Max_New_Spares is declared as an Integer, not a Natural,
         --  because Get_Tasks_Count (OC, Kind => Permanent) may exceed
         --  Maximum_Threads, for example if the pool when initialized already
         --  has reached Maximum_Threads, and the user provides an extra
         --  permanent task with an explicit call to the ORB main loop. If
         --  Max_New_Spares happens to be negative, no new spares are created.

         Max_New_Spares := Integer'Min
           (Maximum_Threads - Get_Tasks_Count (OC, Kind => Permanent),
            Maximum_Spare_Threads - Current_Spares);
         New_Spares := Integer'Min
           (Minimum_Spare_Threads - Current_Spares, Max_New_Spares);
      end if;
      pragma Debug (C, O ("Check_Spares: " & Image (Current_Task)
                          & ": Cur =" & Current_Spares'Img
                          & " Max_New =" & Max_New_Spares'Img
                          & " New =" & New_Spares'Img));

      for J in 1 .. New_Spares loop
         pragma Debug
           (C, O (Image (Current_Task) & " creating new spare task"));
         begin
            Create_Task (Thread_Pool_Main_Loop'Access, "Pool");
         exception
            when Tasking_Error =>
               pragma Debug
                 (C, O (Image (Current_Task)
                        & " new spare task creation failed (TASKING_ERROR)"
                        & " (Shutdown = " & Boolean'Image (Shutting_Down (OC))
                        & ")"));
               null;
         end;
      end loop;
   end Check_Spares;

   ------------------------------
   -- Handle_Request_Execution --
   ------------------------------

   overriding procedure Handle_Request_Execution
     (P   : access Thread_Pool_Policy;
      ORB : ORB_Access;
      RJ  : access Request_Job'Class)
   is
      pragma Unreferenced (P);
   begin
      --  Queue Request_Job to general ORB controller job queue

      Enter_ORB_Critical_Section (ORB.ORB_Controller);
      Notify_Event (ORB.ORB_Controller,
                    Event'(Kind        => Queue_Request_Job,
                           Request_Job => Job_Access (RJ),
                           Target      => RJ.Request.Target));
      Leave_ORB_Critical_Section (ORB.ORB_Controller);
   end Handle_Request_Execution;

   ----------
   -- Idle --
   ----------

   overriding procedure Idle
     (P         : access Thread_Pool_Policy;
      This_Task : PTI.Task_Info_Access;
      ORB       : ORB_Access)
   is
      pragma Unreferenced (P);
      package PTCV renames PolyORB.Tasking.Condition_Variables;
   begin
      --  We are currently in the ORB critical section

      --  Terminate permanent task if there are too many idle tasks.
      --  Note that in the presence of user permanent tasks (for which
      --  May_Exit is False) we may not always be able to maintain
      --  the invariant, since we can't decide to remove these tasks
      --  from the pool.

      if This_Task.Kind = Permanent
           and then
         May_Exit (This_Task.all)
           and then
         Get_Tasks_Count
           (ORB.ORB_Controller.all, Kind => Permanent, State => Idle)
              > Maximum_Spare_Threads
      then
         Terminate_Task (ORB.ORB_Controller, This_Task);
         return;
      end if;

      pragma Debug (C, O ("Thread "
                       & Image (PTI.Id (This_Task.all)) & " going idle"));

      PTCV.Wait (PTI.Condition (This_Task.all), PTI.Mutex (This_Task.all));

      --  This task is about to leave Idle state: check whether new spares
      --  need to be created.

      Check_Spares (ORB);

      pragma Debug
        (C, O ("Thread " & Image (PTI.Id (This_Task.all)) & " leaving idle"));
   end Idle;

   -------------------------
   -- Get_Maximum_Threads --
   -------------------------

   function Get_Maximum_Threads return Natural is
   begin
      return Maximum_Threads;
   end Get_Maximum_Threads;

   -------------------------------
   -- Get_Maximum_Spare_Threads --
   -------------------------------

   function Get_Maximum_Spare_Threads return Natural is
   begin
      return Maximum_Spare_Threads;
   end Get_Maximum_Spare_Threads;

   -------------------------------
   -- Get_Minimum_Spare_Threads --
   -------------------------------

   function Get_Minimum_Spare_Threads return Natural is
   begin
      return Minimum_Spare_Threads;
   end Get_Minimum_Spare_Threads;

   --------------------------------------
   -- Initialize_Tasking_Policy_Access --
   --------------------------------------

   procedure Initialize_Tasking_Policy_Access;

   procedure Initialize_Tasking_Policy_Access is
   begin
      Setup.The_Tasking_Policy := new Thread_Pool_Policy;

      --  Set Maximum_Threads, Start_Threads, Maximum_Spare_Threads and
      --  Minimum_Spare_Threads from configuration and defaults.

      --  Note that the order in which these values are computed is
      --  significant, because computed values are used to provide
      --  consistent defaults: if not all four variables are specified by
      --  the user, and the values specified explicitly are consistent, then
      --  we want to set the remaining variables to consistent values.

      --  For example, the default value of Start_Threads is 4, but if the
      --  user sets Maximum_Threads to 2 and leaves Start_Threads unspecified,
      --  we want to change the default Start_Threads value to 2, rather than
      --  to report an inconsistency.

      Maximum_Threads :=
        Get_Conf ("tasking", "max_threads", Default_Maximum_Threads);

      Start_Threads :=
        Get_Conf ("tasking", "start_threads",
                   Natural'Min (Maximum_Threads, Default_Start_Threads));

      Maximum_Spare_Threads :=
        Get_Conf ("tasking", "max_spare_threads",
                  Natural'Min (Maximum_Threads,
                               Default_Maximum_Spare_Threads));

      Minimum_Spare_Threads :=
        Get_Conf ("tasking", "min_spare_threads",
                  Natural'Min (Maximum_Spare_Threads,
                               Default_Minimum_Spare_Threads));

      --  Check consistency of configured values

      if not (Maximum_Threads >= Maximum_Spare_Threads
              and then Maximum_Threads >= Start_Threads
              and then Maximum_Spare_Threads >= Minimum_Spare_Threads)
      then
         raise Constraint_Error;
      end if;

      if Start_Threads < Minimum_Spare_Threads then
         Start_Threads := Minimum_Spare_Threads;
      end if;
   end Initialize_Tasking_Policy_Access;

   procedure Create_Threads;
   --  Initial creation of threads for the pool

   --------------------
   -- Create_Threads --
   --------------------

   procedure Create_Threads is
   begin
      pragma Debug (C, O ("Create_Threads: enter"));
      pragma Debug (C, O ("Creating" & Start_Threads'Img & " threads"));

      for J in 1 .. Start_Threads loop
         Create_Task (Thread_Pool_Main_Loop'Access, "Pool");
      end loop;

      pragma Debug (C, O ("Create_Threads: leave"));
   end Create_Threads;

   use PolyORB.Initialization;
   use PolyORB.Initialization.String_Lists;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name      => +"orb.thread_pool",
       Conflicts => +"no_tasking",
       Depends   => +"tasking.threads",
       Provides  => +"orb.tasking_policy!",
       Implicit  => False,
       Init      => Initialize_Tasking_Policy_Access'Access,
       Shutdown  => null));

   Register_Module
     (Module_Info'
      (Name      => +"orb.threads_init",
       Conflicts => +"no_tasking",
       Depends   => +"orb" & "orb_controller",
       Provides  => +"orb.tasking_policy_init",
       Implicit  => False,
       Init      => Create_Threads'Access,
       Shutdown  => null));

   --  Two Register_Module are needed because, on one hand, the
   --  variable Setup.The_Tasking_Policy must be initialized before
   --  ORB creation and on the other hand, the variable Setup.The_ORB
   --  must be initialized in order to run threads from the
   --  thread_pool. This breaks the circular dependency at
   --  initialisation.

end PolyORB.ORB.Thread_Pool;
