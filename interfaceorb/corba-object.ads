with Ada.Finalization;
with Ada.Unchecked_Deallocation;

with AdaBroker; use AdaBroker;
with AdaBroker.OmniObject;
with AdaBroker.NetBufferedStream;
with AdaBroker.MemBufferedStream;

package CORBA.Object is

   type Ref is tagged private;

   function Is_Nil  (Self : in Ref) return CORBA.Boolean;
   function Is_Null (Self : in Ref) return CORBA.Boolean renames Is_Nil;

   procedure Release (Self : in out Ref);

   function Is_A
     (Self            : in Ref;
      Logical_Type_Id : in CORBA.String)
      return CORBA.Boolean;
   --  Returns True if this object is of this Logical_Type_Id (here
   --  Logical_Type_Id is a Repository_Id) or one of its descendants

   function Non_Existent
     (Self : in Ref)
      return CORBA.Boolean;
   --  Returns True if the ORB knows that the implementation referenced by
   --  this proxy object does not exist

   function Is_Equivalent
     (Self  : in Ref;
      Other : in Ref)
      return CORBA.Boolean;
   --  Returns True if both objects point to the same distant
   --  implementation

   function Hash
     (Self    : in Ref;
      Maximum : in CORBA.Unsigned_Long)
      return CORBA.Unsigned_Long;
   --  Return a hash value for object not implemented yet, it returns 0

   ---------------
   -- AdaBroker --
   ---------------

   function Is_A
     (Logical_Type_Id : in CORBA.String)
      return CORBA.Boolean;
   --  Same, but non dispatching, must be called CORBA.Object.Is_A (...)

   Repository_Id : CORBA.String
     := CORBA.To_CORBA_String ("IDL:omg.org/CORBA/Object:1.0");
   --  Repository Id for CORBA.Object.Ref

   function Get_Repository_Id (Self : in Ref) return CORBA.String;
   --  Returns the Repository Id of the ADA type of Self it must be
   --  overloaded for all the descendants of Ref. BEWARE : the repository
   --  ID of the ADA type of Self may not be the same as its dynamic
   --  repository ID. For example : if a descendant Myref has been cast
   --  into Ref using To_Ref, Get_Repository_Id will return the repository
   --  ID of CORBA.Object.Ref

   function Get_OmniObject_Ptr
     (Self : in Ref'Class)
      return OmniObject.Object_Ptr;
   --  Returns the underlying OmniObject.Object used in
   --  omniproxycallwrapper

   type Ref_Ptr is access all Ref;
   type Constant_Ref_Ptr is access constant CORBA.Object.Ref'Class;
   procedure Free (Self : in out Ref_Ptr);

   procedure Internal_Copy
     (From : in Ref'Class;
      To   : in out Ref'Class);
   --  This is a workaround for a bug in gnat 3.11p it simply copies the
   --  two fields of From into To. It also finalizes and adjusts whrn
   --  needed

   procedure Internal_Copy
     (From     : in OmniObject.Implemented_Object'Class;
      Dyn_Type : in Constant_Ref_Ptr;
      To       : in out Ref'Class);
   --  This function is used to create a proxy object (Ref) pointing on a
   --  local object

   ---------------------------------------------
   -- registering new interfaces into the ORB --
   ---------------------------------------------

   procedure Create_Proxy_Object_Factory (Repository : in CORBA.String);
   --  The ORB has to know how to create new proxy objects when we ask him
   --  to (out of an IOR for example.  To do that, it keeps a global
   --  variable which is a list of proxyObjectFactories.  They all have a
   --  method newProxyObject which construct a proxy object of the desired
   --  type
   --
   --  From the ORB's point of view, all Ada objects are of the same type,
   --  all we have to do is register the Repositoty ID of the new
   --  interface, this is done in this function, which has to be called in
   --  the elaboration of all the packages that contain a descendant of
   --  CORBA.Object.Ref


   --  Dynamic Typing Of Objects
   --
   --  An omniobject.Object carries information about its most derived type
   --  in its reposituryID In CORBA.Object.Ref, the information of the most
   --  derived type is stored as a pointer to a static variable of the most
   --  derived clas of the object. (Nil_Ref is used)
   --
   --  Ada typing cannot be used, because the Ada dynamic type does not
   --  correspond to the IDL dynamic type when To_Ref is used.
   --
   --  It is easy to retrieve the repositoryID out of a static object via
   --  the dispatching method Get_Repository_Id, and this package provides
   --  a function Get_Dynamic_Type_From_Repository_Id to do the conversion
   --  the other way round.
   --
   --  As for now, this package is implemented using a list. It would
   --  probably be more efficient with a hashtable.
   --
   --  THE FUNCTIONS ARE NOT THREAD-SAFE


   procedure Register
     (Repository : in CORBA.String;
      Dyn_Type   : in CORBA.Object.Constant_Ref_Ptr);
   --  This procedure registers a new static object in the list


   function Get_Dynamic_Type (Self : in Ref) return Ref'Class;
   --  Returns a Ref_Ptr which is of the same class as the most derived
   --  repository id of this Ref'Class


   ---------------------------
   -- Marshalling operators --
   ---------------------------

   function Align_Size
     (Obj            : in Ref'Class;
      Initial_Offset : in CORBA.Unsigned_Long)
      return CORBA.Unsigned_Long;
   --  This function computes the size needed to marshall the object obj

   procedure Marshall
     (Obj : in Ref'Class;
      S   : in out NetBufferedStream.Object'Class);
   --  This procedure marshalls the object Obj into the stream S

   procedure Marshall
     (Obj : in Ref'Class;
      S   : in out MemBufferedStream.Object'Class);
   --  This procedure marshalls the object Obj into the stream S

   procedure Unmarshall
     (Obj : out Ref'Class;
      S   : in out NetBufferedStream.Object'Class);
   --  This procedure marshalls the object Obj into the stream S

   procedure Unmarshall
     (Obj : out Ref'Class;
      S   : in out MemBufferedStream.Object'Class);
   --  This procedure marshalls the object Obj into the stream S

   Nil_Ref : aliased constant Ref;

private

   type Ref is new Ada.Finalization.Controlled with record
      OmniObj      : OmniObject.Object_Ptr := null;
      Dynamic_Type : Constant_Ref_Ptr      := null;
   end record;

   ---------------------------
   -- controlling functions --
   ---------------------------

   procedure Initialize (Self : in out Ref);
   --  Sets OmniObj and Dynamic_Type to null;

   procedure Adjust (Self : in out Ref);
   --  Duplicate the underlying omniobject


   procedure Finalize (Self : in out Ref);
   --  Release the underlying omniobject

   procedure Private_Free is
     new Ada.Unchecked_Deallocation (Ref, Ref_Ptr);


   function Get_Dynamic_Type_From_Repository_Id
     (Repository : in CORBA.String)
      return CORBA.Object.Constant_Ref_Ptr;

   Nil_Ref : aliased constant Ref
     := (Ada.Finalization.Controlled with OmniObj => null,
         Dynamic_Type                             => null);

end CORBA.Object;
