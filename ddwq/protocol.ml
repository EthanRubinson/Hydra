open Async.Std

(************************************)
(** { Marshaling and unmarshaling } *)
(************************************)

module type Marshalable = sig
  type t
  val receive : Reader.t -> t Reader.Read_result.t Deferred.t
  val send    : Writer.t -> t -> unit
end

(** Utility class for implementing the Marshalable interface *)
module Marshaller = struct
  let receive r = Reader.read_marshal r
  let send w v  = Writer.write_marshal w [] v
end

(*************************)
(** { Protocol messages} *)
(*************************)



module MasterMonitorComm = struct
  type t =  | ImAlive 
            | YouAreNewHead | YouAreNewTail 
            | YouHaveNewPrevNode of ((string * int) * int) | YouHaveNewNextNode of (string * int)
            | OnSeqNumber of int

  include Marshaller
end

module MasterServiceAck = struct
  type t = FirstChainMemberAck | NewTailAck

  include Marshaller
end

module MasterServiceRequest = struct
  type t = InitRequest of (string * int)  (*hostname * listening port *)

  include Marshaller
end

module MasterServiceResponse = struct
  type t = FirstChainMember | NewTail | PrepareNewTail of (string * int) | InitDone | InitFailed

  include Marshaller
end


module SlaveRequest (Work : Ddwq.WorkType) = struct
  type t = DoWorkRequest of Work.input

  include Marshaller
end

module SlaveResponse (Work : Ddwq.WorkType) = struct
  type t =
    | DoWorkFailed of string
    | DoWorkResult of Work.output

  include Marshaller
end
