------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--       R T C O R B A . P R I O R I T Y M A P P I N G . L I N E A R        --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2004-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This specification is derived from the CORBA Specification, and adapted  --
-- for use with PolyORB. The copyright notice above, and the license        --
-- provisions that follow apply solely to the contents neither explicitly   --
-- nor implicitly specified by the CORBA Specification defined by the OMG.  --
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

--  Linear priority mapping between CORBA and Native priority

package RTCORBA.PriorityMapping.Linear is

   type Object is new RTCORBA.PriorityMapping.Object with private;

   procedure To_Native
     (Self            : Object;
      CORBA_Priority  : RTCORBA.Priority;
      Native_Priority :    out RTCORBA.NativePriority;
      Returns         :    out CORBA.Boolean);

   procedure To_CORBA
     (Self            : Object;
      Native_Priority : RTCORBA.NativePriority;
      CORBA_Priority  :    out RTCORBA.Priority;
      Returns         :    out CORBA.Boolean);

private

   type Object is new RTCORBA.PriorityMapping.Object with null record;

end RTCORBA.PriorityMapping.Linear;
