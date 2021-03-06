------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                             X E _ F R O N T                              --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 1995-2013, Free Software Foundation, Inc.          --
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

--  This package contains all the data structures needed to represent
--  the configuration of the distributed system. As a result of the
--  frontend, these structures will provide info required to produce
--  stubs, skels and other packages.

with XE;       use XE;
with XE_Types; use XE_Types;
with XE_Units; use XE_Units;

package XE_Front is

   --------------
   -- Defaults --
   --------------

   Default_Partition_Id : Partition_Id;
   Default_Channel_Id   : Channel_Id;
   --  Default channel and partition. The properties of these objects serve as
   --  templates for all other channels and partitions.

   Default_Registration_Filter : Filter_Name_Type        := No_Filter_Name;
   Default_First_Boot_Location : Location_Id             := No_Location_Id;
   Default_Last_Boot_Location  : Location_Id             := No_Location_Id;
   Default_Data_Location       : Location_Id             := No_Location_Id;
   Default_Starter             : Import_Method_Type      := Ada_Import;
   Default_Name_Server         : Name_Server_Type        := Standalone_NS;
   Default_Version_Check       : Boolean                 := True;
   Default_Rsh_Command         : Name_Id                 := No_Name;
   Default_Rsh_Options         : Name_Id                 := No_Name;
   Default_Priority_Policy     : Priority_Policy_Type    := No_Priority_Policy;
   Default_ORB_Tasking_Policy  : ORB_Tasking_Policy_Type := Thread_Pool;

   Configuration : Unit_Name_Type := No_Unit_Name;
   --  Name of the configuration

   Main_Partition : Partition_Id := No_Partition_Id;
   --  Partition where the main procedure has been assigned

   Main_Subprogram : Unit_Name_Type := No_Unit_Name;
   --  Several variables related to the main procedure

   procedure Frontend;

   procedure Add_Conf_Unit (U : Unit_Name_Type; P : Partition_Id);
   --  Assign a unit to a partition. This unit is declared in the
   --  configuration file (it is not yet mapped to an ada unit).

   procedure Add_Location
     (First : in out Location_Id;
      Last  : in out Location_Id;
      Major : Name_Id;
      Minor : Name_Id);
   --  Read major and minor from variable and add this pair to
   --  partition location list.

   procedure Add_Required_Storage
     (First    : in out Required_Storage_Id;
      Last     : in out Required_Storage_Id;
      Location : Location_Id;
      Unit     : Unit_Id;
      Owner    : Boolean);
   --  Add a node in the required storages chained list of a partition

   procedure Add_Environment_Variable
     (First : in out Env_Var_Id;
      Last  : in out Env_Var_Id;
      Name  : Name_Id);
   --  Add new environment variable to partition's list

   procedure Create_Channel
     (Name : Channel_Name_Type;
      Node : Node_Id;
      CID  : out Channel_Id);
   --  Create a new channel and store its CID in its name key.

   procedure Create_Host
     (Name : Host_Name_Type;
      Node : Node_Id;
      HID  : out Host_Id);
   --  Create a new host and store its HID in its name key.

   procedure Create_Partition
     (Name : Partition_Name_Type;
      Node : Node_Id;
      PID  : out Partition_Id);
   --  Create a new partition and store its PID in its name key.

   function Get_ALI_Id       (N : Name_Id) return ALI_Id;
   function Get_Channel_Id   (N : Name_Id) return Channel_Id;
   function Get_Conf_Unit_Id (N : Name_Id) return Conf_Unit_Id;
   function Get_Host_Id      (N : Name_Id) return Host_Id;
   function Get_Partition_Id (N : Name_Id) return Partition_Id;
   function Get_Unit_Id      (N : Name_Id) return Unit_Id;

   procedure Set_ALI_Id       (N : Name_Id; A : ALI_Id);
   procedure Set_Channel_Id   (N : Name_Id; C : Channel_Id);
   procedure Set_Conf_Unit_Id (N : Name_Id; U : Conf_Unit_Id);
   procedure Set_Host_Id      (N : Name_Id; H : Host_Id);
   procedure Set_Partition_Id (N : Name_Id; P : Partition_Id);
   procedure Set_Unit_Id      (N : Name_Id; U : Unit_Id);

   function  Get_Tasking (A : ALI_Id) return Tasking_Type;
   procedure Set_Tasking (A : ALI_Id; T : Tasking_Type);

   function Get_Rsh_Command return Name_Id;
   function Get_Rsh_Options return Name_Id;

   procedure Initialize;
   --  Initialize the first item of each table to use them as default.

   procedure Update_Most_Recent_Stamp (P : Partition_Id; F : File_Name_Type);
   --  The more recent stamp of files needed to build a partition is
   --  updated.

   procedure Show_Configuration;
   --  Report the current configuration

   function To_Build (U : Conf_Unit_Id) return Boolean;
   --  Is this unit mapped on a partition to build

end XE_Front;
