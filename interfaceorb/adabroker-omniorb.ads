--  This package is wrapped around a C++ class whose name is
--  Ada_OmniObject.  It provides two types of methods : the C functions of
--  the Ada_OmniObject class and their equivalent in Ada. (he first ones
--  have a C_ prefix.)  In addition, there is a raise_ada_exception
--  function that allows C functions to raise the ada No_Initialisation
--  exception.

with Ada.Unchecked_Conversion;
with Ada.Finalization;

with Interfaces.CPP;
with Interfaces.C.Strings;

with System;
with System.Address_To_Access_Conversions;

with CORBA;

with AdaBroker; use AdaBroker;

with AdaBroker.GIOP_S;
with AdaBroker.Sysdep;
with AdaBroker.IOP;
with AdaBroker.OmniRopeAndKey;
with AdaBroker.NetBufferedStream;
with AdaBroker.MemBufferedStream;

package AdaBroker.OmniORB is

   --  ImplObject is the type of local implementations of objects.

   type ImplObject is abstract tagged limited private;

   type ImplObject_Ptr is access all ImplObject'Class;


   ----------------------------
   -- Controlling Operations --
   ----------------------------

   procedure Initialize (Self : in out ImplObject);
   --  Create the underlying OmniObject both objects point on one another

   procedure Adjust (Self : in out ImplObject);
   --  Create the underlying OmniObject both objects point on one another
   --  sets the repository ID

   procedure Finalize (Self : in out ImplObject);
   --  Release the underlying omniobject


   ------------------------------
   -- Miscellaneous Operations --
   ------------------------------

   function Is_Nil  (Self : in ImplObject) return CORBA.Boolean;
   function Is_Null (Self : in ImplObject) return CORBA.Boolean
     renames Is_Nil;
   --  Returns True if this is a nil object

   function Hash
     (Self    : in ImplObject;
      Maximum : in CORBA.Unsigned_Long)
      return CORBA.Unsigned_Long;
   --  Returns a hash value for this object

   procedure Object_Is_Ready (Self : in ImplObject'Class);
   --  Tell ORB that this object is ready to accept connections. It
   --  has to be done only once for each local object. This function
   --  *must not* be called directly by the user. Invoke
   --  BOA.Object_Is_Ready instead. There is no difference in this
   --  version of AdaBroker since there is only one BOA, but there may
   --  be in the future.

   procedure Dispose_Object (Self : in ImplObject'Class);
   --  Release all the ressources associated to a local object. It is
   --  done automatically at the end of the scope, but can be done
   --  prematuraly by the invokation of this procedure. Once this
   --  procedure called, the object becomes a null object.

   function Object_To_String
     (Self : in ImplObject'Class)
      return CORBA.String;
   --  Return the IOR corresponding to this object


   -------------------------------------------
   -- Marshalling Operations For ImplObject --
   -------------------------------------------

   function Align_Size
     (Obj            : in ImplObject_Ptr;
      Initial_Offset : in CORBA.Unsigned_Long)
      return CORBA.Unsigned_Long;
   --  This function computes the size needed to marshall the object obj

   procedure Marshall
     (Obj : in ImplObject_Ptr;
      S   : in out NetBufferedStream.Object'class);
   --  This procedure marshalls the object Obj into the stream S

   procedure Marshall
     (Obj : in ImplObject_Ptr;
      S : in out MemBufferedStream.Object'class);
   --  This procedure marshalls the object Obj into the stream S


   type Dispatch_Procedure is access
     procedure (Self                  : ImplObject_Ptr;
                Orls                  : in out GIOP_S.Object;
                Orl_Op                : in Standard.String;
                Orl_Response_Expected : in CORBA.Boolean;
                Success               : out CORBA.Boolean);
   --  This type is used to make the dispatching call.  this type is made
   --  to handle dispatching calls from the ORB. This procedure cannot be
   --  made a primitive of ImplObject. Otherwise it would have to
   --  for each descendant in the user's code.

   procedure Initialize_Local_Object
     (Self     : in out ImplObject;
      RepoID   : in CORBA.String;
      Dispatch : in Dispatch_Procedure);
   --  Call C++ Init operation to set the Init_OK boolean to true and
   --  to set repoID and Dispatch of this object.


   -------------------------------
   -- C++ omniObject Equivalent --
   -------------------------------

   type OmniObject is tagged limited record
      ImplObj    : ImplObject_Ptr := null;
      Interface  : Interfaces.C.int;
      CPP_Object : System.Address;
      Init_OK    : Sysdep.Bool;
      Table      : Interfaces.CPP.Vtable_Ptr;
   end record;
   --  Implobj    (Ada) : the pointer implobj is null for proxy object
   --  Interface  (Ada) : index to retrieve interface ref and rep
   --  CPP_Object (C)   : pointer to underlying omniObject_C2Ada object
   --  Init_OK    (C)   : state of the object (initialized or not)
   --  Table      (C)   : needed to interface C++ and Ada

   pragma Cpp_Class (OmniObject);
   pragma Cpp_Vtable (OmniObject, Table, 2);
   --  This type is both a C and an Ada class it is is wrapped around
   --  Ada_OmniObject (see Ada_OmniObject.hh)

   type OmniObject_Ptr is access all OmniObject'Class;


   function Get_OmniObject_Ptr
     (Self : in ImplObject)
      return OmniObject_Ptr;
   --  Return underlying OmniObject


   ----------------------------
   -- Marshalling Operations --
   ----------------------------

   function Align_Size
     (Obj            : in OmniObject_Ptr;
      Initial_Offset : in CORBA.Unsigned_Long)
      return CORBA.Unsigned_Long;
   --  This function computes the size needed to marshall the object obj

   procedure Marshall
     (Obj : in OmniObject_Ptr;
      S : in out NetBufferedStream.Object'Class);
   --  This procedure marshalls the object Obj into the stream S

   procedure Marshall
     (Obj : in OmniObject_Ptr;
      S   : in out MemBufferedStream.Object'Class);
   --  This procedure marshalls the object Obj into the stream S


   ----------------------------
   -- Controlling Operations --
   ----------------------------

   function Create_OmniObject
     (RepoID   : in CORBA.String;
      Profiles : in IOP.Tagged_Profile_List)
      return OmniObject_Ptr;
   --  This function is called by corba.object.create_ref, which is called
   --  by corba.object.unmarshall We use this when we want to unmarshall an
   --  object out of a bufferedstream, and to create a
   --  CORBA.object.ref'class.

   function Duplicate_OmniObject (Self : in OmniObject_Ptr)
     return OmniObject_Ptr;
   --  Create a new Object referencing the same omniObject_C2Ada see
   --  Ada_OmniObject.hh

   procedure Destruct_OmniObject (Self : in OmniObject_Ptr);
   --  C++ destructor of Ada_omniObject calls omni::objectRelease on the
   --  omniObject_C2Ada and destroys the Ada_omniObject

   procedure Dispose_OmniObject (Self : in OmniObject_Ptr);
   --  Tell the BOA this local object does not accept connexions any
   --  longer only called by Dispose_Object(ImplObject)


   -------------------------------------
   -- OmniObject Miscellaneous Operations --
   -------------------------------------

   function String_To_Object
     (From : in CORBA.String)
      return OmniObject_Ptr;
   --  This function trys to create the Object corresponding to this
   --  resitory_id, returns null on failure

   function Object_To_String
     (Obj : in OmniObject_Ptr)
     return CORBA.String;
   --  Returns the IOR for this object Obj can be null

   function Is_Proxy
     (Self : in OmniObject'Class)
      return Boolean;
   --  Returns true if this is a proxy object by calling the C++ function
   --  on the omniobject

   function Non_Existent
     (Self : in OmniObject'Class)
      return CORBA.Boolean;
   --  Returns true if the ORB is sure that this object does not exist

   function Hash
     (Self    : in OmniObject'Class;
      Maximum : in CORBA.Unsigned_Long)
      return CORBA.Unsigned_Long;
   --  Returns a hash value for this object

   procedure Assert_Object_Existent (Self : in OmniObject'Class);
   pragma Import
     (CPP, Assert_Object_Existent, "assertObjectExistent__14Ada_OmniObject");
   --  Checks that this object really exists

   procedure Get_Rope_And_Key
     (Self    : in OmniObject'Class;
      L       : in out OmniRopeAndKey.Object;
      Success : out Boolean);
   --  Returns the rope and key for this omniobject if it is a proxy object

   procedure Set_Rope_And_Key
     (Self    : in out OmniObject'Class;
      L       : in out OmniRopeAndKey.Object;
      KeepIOP : in Boolean := True);
   --  Sets the rope and key for this object

   procedure Reset_Rope_And_Key (Self : in OmniObject'Class);
   pragma Import
     (CPP, Reset_Rope_And_Key, "resetRopeAndKey__14Ada_OmniObject");
   --  Re-sets the rope and key for this object

   function Get_Rep_From_ORB
     (Self : in OmniObject'class)
      return CORBA.String;
   --  Return the repository id of this object. Ask directly ORB for this.

   function Get_Profile_List
     (Self : in OmniObject'Class)
      return IOP.Tagged_Profile_List;
   --  Returns the Profile list of an object

   procedure Set_Interface_Rep
     (Self : in out OmniObject'Class;
      Rep  : in CORBA.String);

   --  function Resolve_Initial_References
   --    (Identifier : in CORBA.String)
   --    return OmniObject_Ptr;

private

   --  ImplOmniObject this is the type of local implementations of
   --  objects it is the root of all XXX.Impl.OmniObject

   type ImplObject is
     abstract new Ada.Finalization.Limited_Controlled with record
        OmniObj  : OmniObject_Ptr;
        Dispatch : Dispatch_Procedure;
     end record;

   --  OmniObject this type is imported from C++ it is the equivalent of
   --  omniObject

   package Address_To_OmniObject is
     new System.Address_To_Access_Conversions (OmniObject);

   function To_OmniObject_Ptr is
     new Ada.Unchecked_Conversion
     (Address_To_OmniObject.Object_Pointer, OmniObject_Ptr);

   function From_OmniObject_Ptr is
     new Ada.Unchecked_Conversion
     (OmniObject_Ptr, Address_To_OmniObject.Object_Pointer);

   procedure OmniObject_Is_Ready (Self : in OmniObject_Ptr);
   --  Registers a local object into the ORB only called by
   --  Object_Is_Ready(ImplObject)

   procedure C_Dispatch
     (Self                  : in OmniObject'Class;
      Orls                  : in out GIOP_S.Object;
      Orl_Op                : in Interfaces.C.Strings.chars_ptr;
      Orl_Response_Expected : in Sysdep.Bool;
      Success               : out Sysdep.Bool);

   pragma Export
     (CPP, C_Dispatch, "dispatch__14Ada_OmniObjectR10Ada_Giop_sPCcbRb");
   --  Wrapper around Ada_OmniObject function dispatch (see
   --  Ada_OmniObject.hh) This function is implemented in Ada and exported
   --  to C it calls th Ada function Dispatch

   function  C_Is_A
     (Self   : in OmniObject'Class;
      Repoid : in Interfaces.C.Strings.chars_ptr)
      return  Sysdep.Bool;

   pragma Export (CPP, C_Is_A, "Ada_Is_A__14Ada_OmniObjectPCc");
   --  Returns true if self is in repoID, or one of its descendant

   ---------------------
   -- memory handling --
   ---------------------

   function Constructor return OmniObject'Class;
   pragma Import (CPP, Constructor, "__14Ada_OmniObject");
   pragma Cpp_Constructor (Constructor);
   --  Wrapped around the C constructor of Ada_OmniObject

   function OmniObject_Ptr_Constructor return OmniObject_Ptr;
   --  This is a workaround for gnat 3.11p we cannot write toto :
   --  Object_Ptr := new Object we have to call the C++ constructor to
   --  create objects

end AdaBroker.OmniORB;
