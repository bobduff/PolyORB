------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--               P O L Y O R B . O R B _ C O N T R O L L E R                --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2003-2004 Free Software Foundation, Inc.           --
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

--  ORB Controller for PolyORB ORB main loop

--  $Id$

with PolyORB.Asynch_Ev;
with PolyORB.Jobs;
with PolyORB.References;
with PolyORB.Request_Scheduler;
with PolyORB.Task_Info;
with PolyORB.Tasking.Threads;

package PolyORB.ORB_Controller is

   --  An ORB Control Policy is responsible for the management of the
   --  global state of the ORB (running tasks, job processing,
   --  etc). It grants access to ORB internals and affects action to
   --  all registered tasks.

   --  It is the ORB Control Policy responsability to ensure that all
   --  tasks may work concurrently and access safely the ORB internals.

   --  An ORB Controller is an instance of an ORB Control Policy,
   --  attached to an ORB instance. It is a passive object, triggered
   --  by the occurence of some specific events within the ORB.

   package PAE renames PolyORB.Asynch_Ev;
   package PJ  renames PolyORB.Jobs;
   package PR  renames PolyORB.References;
   package PRS renames PolyORB.Request_Scheduler;
   package PTI renames PolyORB.Task_Info;
   package PT  renames PolyORB.Tasking.Threads;

   -----------
   -- Event --
   -----------

   --  Events handled by ORB Controllers. Specific events trigger the
   --  ORB Controller, which then modify ORB global state.

   type Event_Kind is
     (End_Of_Check_Sources,
      --  A task completed Check_Sources on a monitor

      Event_Sources_Added,
      --  An AES has been added to monitored AES list

      Event_Sources_Deleted,
      --  An AES has been deleted from monitored AES list

      Job_Completed,
      --  A job has been completed

      ORB_Shutdown,
      --  ORB shutdown has been requested

      Queue_Event_Job,
      --  Queue an event job

      Queue_Request_Job,
      --  Queue a request job

      Request_Result_Ready
      --  A Request has been completed

      );

   --  Event type

   type Event (Kind : Event_Kind) is record
      case Kind is
         when Event_Sources_Added =>
            Add_In_Monitor : PAE.Asynch_Ev_Monitor_Access;
            --  Non null iff we add a source to a new monitor

         when Queue_Event_Job =>
            Event_Job : PJ.Job_Access;
            By_Task   : PT.Thread_Id;

         when Queue_Request_Job =>
            Request_Job : PJ.Job_Access;
            Target      : PR.Ref;

         when Request_Result_Ready =>
            Requesting_Task : PTI.Task_Info_Access;

         when others =>
            null;
      end case;
   end record;

   --  Some events have no attached data, we declare constant
   --  shortcuts to manipulate them.

   End_Of_Check_Sources_E  : constant Event (End_Of_Check_Sources);
   Event_Sources_Deleted_E : constant Event (Event_Sources_Deleted);
   Job_Completed_E         : constant Event (Job_Completed);
   ORB_Shutdown_E          : constant Event (ORB_Shutdown);

   --------------------
   -- ORB_Controller --
   --------------------

   type ORB_Controller (RS : PRS.Request_Scheduler_Access) is
     abstract tagged limited private;

   type ORB_Controller_Access is access all ORB_Controller'Class;

   procedure Register_Task
     (O  : access ORB_Controller;
      TI :        PTI.Task_Info_Access)
      is abstract;
   --  Register TI to scheduler S. TI may now be used by the ORB
   --  Controller to process ORB actions.

   procedure Unregister_Task
     (O  : access ORB_Controller;
      TI :        PTI.Task_Info_Access)
      is abstract;
   --  Unregister TI from Scheduler

   procedure Notify_Event
     (O : access ORB_Controller;
      E :        Event)
      is abstract;
   --  Notify ORB Controller O of the occurence of event E.
   --  This procedure may change status of idle or blocked tasks.

   procedure Schedule_Task
     (O  : access ORB_Controller;
      TI :        PTI.Task_Info_Access)
      is abstract;
   --  Return the next action to be executed.

   procedure Disable_Polling (O : access ORB_Controller) is abstract;
   --  Disable polling on ORB's AES, abort polling task and waits for
   --  its completion, if required. ORB Lock (see Initialize above)
   --  is released when waiting for polling task completion: several
   --  tasks may enter this procedure. ORB Lock ensures they will
   --  leave it sequentially.

   procedure Enable_Polling (O : access ORB_Controller) is abstract;
   --  Enable polling on AES. If Disable_Polling has been called N
   --  times, Enable_Polling must be called N times to actually enable
   --  polling. It is the user responsability to ensure that
   --  Enable_Polling actually enables polling in bounded time.

   procedure Enter_ORB_Critical_Section
     (O : access ORB_Controller)
      is abstract;
   --  Enter ORB critical section

   procedure Leave_ORB_Critical_Section
     (O : access ORB_Controller)
      is abstract;
   --  Leave ORB critical section

   function Is_A_Job_Pending
     (O : access ORB_Controller)
     return Boolean
      is abstract;
   --  Return true iff a job is pending

   function Get_Pending_Job
     (O : access ORB_Controller)
     return PJ.Job_Access
      is abstract;
   --  Return a pending job, null if there is not pending job

   type Monitor_Array is array (Natural range <>)
     of PAE.Asynch_Ev_Monitor_Access;

   function Get_Monitors
     (O : access ORB_Controller)
     return Monitor_Array
      is abstract;
   --  Return monitors handled by the ORB

   ----------------------------
   -- ORB_Controller_Factory --
   ----------------------------

   type ORB_Controller_Factory is abstract tagged limited null record;

   type ORB_Controller_Factory_Access is
     access all ORB_Controller_Factory'Class;

   function Create
     (OCF : access ORB_Controller_Factory)
     return ORB_Controller_Access
      is abstract;
   --  Use factory to create a new ORB_Controller

   procedure Register_ORB_Controller_Factory
     (OCF : ORB_Controller_Factory_Access);
   --  Register an ORB_Controller factory

   procedure Create (O : out ORB_Controller_Access);
   --  Initialize an ORB_Controller

private

   function Status (O : access ORB_Controller) return String;
   --  Output status of task running Broker, for debugging purpose.

   type ORB_Controller (RS : PRS.Request_Scheduler_Access)
     is abstract tagged limited record

         -----------------------------
         -- Controller global state --
         -----------------------------

         --  These parameters provide information on ORB Controller
         --  current state.

         Registered_Tasks : Natural := 0;
         --  Number of task registered by the ORB Controller

         Unscheduled_Tasks : Natural := 0;
         --  Number of unscheduled tasks

         Idle_Tasks : Natural := 0;
         --  Number of idle tasks

         Running_Tasks : Natural := 0;
         --  Number of tasks processing a job

         Blocked_Tasks : Natural := 0;
         --  Number of task blocking on AES

         Number_Of_Pending_Jobs : Natural := 0;
         --  Number of pending jobs

         Number_Of_AES : Natural := 0;
         --  Number of asynchronous event sources

         Shutdown : Boolean := False;
         --  True iff ORB is to be shutdown

     end record;

   End_Of_Check_Sources_E : constant Event (End_Of_Check_Sources)
     := Event'(Kind => End_Of_Check_Sources);

   Event_Sources_Deleted_E : constant Event (Event_Sources_Deleted)
     := Event'(Kind => Event_Sources_Deleted);

   Job_Completed_E : constant Event (Job_Completed)
     := Event'(Kind => Job_Completed);

   ORB_Shutdown_E : constant Event (ORB_Shutdown)
     := Event'(Kind => ORB_Shutdown);

end PolyORB.ORB_Controller;
