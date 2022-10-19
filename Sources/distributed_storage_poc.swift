import Distributed

public struct InvocationMessage: Sendable, Codable, CustomStringConvertible {
    let text: String

    var target: RemoteCallTarget {
        RemoteCallTarget(text)
    }

    public var description: String {
        "InvocationMessage(text: \(text))"
    }
}

public struct StorageInvocationEncoder: DistributedTargetInvocationEncoder {
    public typealias SerializationRequirement = any Codable

    public mutating func recordGenericSubstitution<T>(_ type: T.Type) throws {
        fatalError()
    }

    public mutating func recordArgument<Value: Codable>(_ argument: RemoteCallArgument<Value>) throws {
        fatalError()
    }
    public mutating func recordReturnType<Success: Codable>(_ returnType: Success.Type) throws {}
    public mutating func recordErrorType<E: Error>(_ type: E.Type) throws {}
    public mutating func doneRecording() throws {}
}


public struct StorageInvocationDecoder: DistributedTargetInvocationDecoder {
    public typealias SerializationRequirement = any Codable

    public mutating func decodeGenericSubstitutions() throws -> [Any.Type] {
        fatalError()
    }

    public mutating func decodeNextArgument<Argument: Codable>() throws -> Argument {
        fatalError()
    }

    public mutating func decodeErrorType() throws -> Any.Type? {
        fatalError()
    }

    public mutating func decodeReturnType() throws -> Any.Type? {
        fatalError()
    }
}

public struct StorageInvocationResultHandler: DistributedTargetInvocationResultHandler {
    public typealias SerializationRequirement = any Codable

    public func onReturn<Success: Codable>(value: Success) async throws {
        fatalError()
    }

    public func onReturnVoid() async throws {
        fatalError()
    }

    public func onThrow<Err: Error>(error: Err) async throws {
        fatalError()
    }
}

/// A unique identifier of the state for the ``StorageSystem``
public enum StorageKey: Hashable {
    case atom(ObjectIdentifier)
    case group(ObjectIdentifier, AnyHashable)
    case computation(ObjectIdentifier)
    case groupComputation(ObjectIdentifier, AnyHashable)
}

public final class StorageActorSystem: DistributedActorSystem {
    public typealias ActorID = String
    public typealias InvocationEncoder = StorageInvocationEncoder
    public typealias InvocationDecoder = StorageInvocationDecoder
    public typealias ResultHandler = StorageInvocationResultHandler
    public typealias SerializationRequirement = any Codable

    // ==== ----------------------------------------------------------------------------------------------------------------
    // MARK: Generic requirement
    func getValue<V>(for key: StorageKey, onBehalf ownerKey: StorageKey?, defaultValue: () -> V) -> V {
        fatalError()
    }

    func setValue<V>(_ value: V, for key: StorageKey, onBehalf ownerKey: StorageKey?) {
        fatalError()
    }

    // ==== ----------------------------------------------------------------------------------------------------------------


    public func resolve<Act>(id: String, as actorType: Act.Type) throws -> Act? where Act : DistributedActor, String == Act.ID {
        fatalError()
    }

    public func assignID<Act>(_ actorType: Act.Type) -> String where Act : DistributedActor, String == Act.ID {
        fatalError()
    }

    public func actorReady<Act>(_ actor: Act) where Act : DistributedActor, String == Act.ID {
        fatalError()
    }

    public func resignID(_ id: String) {
        fatalError()
    }

    public func makeInvocationEncoder() -> StorageInvocationEncoder {
        fatalError()
    }
}

extension StorageActorSystem {
//    public func makeInvocationEncoder() -> InvocationEncoder {
//        InvocationEncoder(system: self)
//    }

    public func remoteCall<Act, Err, Res>(
        on actor: Act,
        target: RemoteCallTarget,
        invocation: inout InvocationEncoder,
        throwing: Err.Type,
        returning: Res.Type
    ) async throws -> Res
    where Act: DistributedActor,
          Act.ID == ActorID,
          Err: Error,
          Res: Codable
    {
        fatalError()
    }

    public func remoteCallVoid<Act, Err>(
        on actor: Act,
        target: RemoteCallTarget,
        invocation: inout InvocationEncoder,
        throwing: Err.Type
    ) async throws
    where Act: DistributedActor,
          Act.ID == ActorID,
          Err: Error
    {
        fatalError()
    }

//    private func withCallID<Reply>(
//        on actorID: ActorID,
//        target: RemoteCallTarget,
//        body: (CallID) -> Void
//    ) async throws -> Reply
//    where Reply: AnyRemoteCallReply
//    {
//        let callID = UUID()
//
//        let timeout = RemoteCall.timeout ?? self.settings.remoteCall.defaultTimeout
//        let timeoutTask: Task<Void, Error> = Task.detached {
//            try await Task.sleep(nanoseconds: UInt64(timeout.nanoseconds))
//            guard !Task.isCancelled else {
//                return
//            }
//
//            self.inFlightCallLock.withLockVoid {
//                guard let continuation = self._inFlightCalls.removeValue(forKey: callID) else {
//                    // remoteCall was already completed successfully, nothing to do here
//                    return
//                }
//
//                let error: Error
//                if self.isShuttingDown {
//                    // If the system is shutting down, we should offer a more specific error;
//                    //
//                    // We may not be getting responses simply because we've shut down associations
//                    // and cannot receive them anymore.
//                    // Some subsystems may ignore those errors, since they are "expected".
//                    //
//                    // If we're shutting down, it is okay to not get acknowledgements to calls for example,
//                    // and we don't care about them missing -- we're shutting down anyway.
//                    error = RemoteCallError(.clusterAlreadyShutDown, on: actorID, target: target)
//                } else {
//                    error = RemoteCallError(.timedOut(
//                        callID,
//                        TimeoutError(message: "Remote call [\(callID)] to [\(target)](\(actorID)) timed out", timeout: timeout)
//                    ), on: actorID, target: target)
//                }
//
//                continuation.resume(throwing: error)
//            }
//        }
//        defer {
//            timeoutTask.cancel()
//        }
//
//        let reply: any AnyRemoteCallReply = try await withCheckedThrowingContinuation { continuation in
//            self.inFlightCallLock.withLock {
//                self._inFlightCalls[callID] = continuation // this is to be resumed from an incoming reply or timeout
//            }
//            body(callID)
//        }
//
//        guard let reply = reply as? Reply else {
//            // ClusterInvocationResultHandler.onThrow returns RemoteCallReply<_Done> for both
//            // remoteCallVoid and remoteCall (i.e., it doesn't send back RemoteCallReply<Res>).
//            // The guard check above fails for the latter use-case because of type mismatch.
//            // The if-block converts the error reply to the proper type then returns it.
//            if let thrownError = reply.thrownError {
//                return Reply.init(callID: reply.callID, error: thrownError)
//            }
//
//            self.log.error("Expected [\(Reply.self)] but got [\(type(of: reply as Any))]")
//            throw RemoteCallError(
//                .invalidReply(callID),
//                on: actorID,
//                target: target
//            )
//        }
//        return reply
//    }
}
