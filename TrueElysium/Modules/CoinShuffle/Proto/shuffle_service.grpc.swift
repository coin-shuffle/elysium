//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: shuffle_service.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf


/// Usage: instantiate `CoinShuffle_V1_ShuffleServiceClient`, then call methods of this protocol to make API calls.
internal protocol CoinShuffle_V1_ShuffleServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol? { get }

  func joinShuffleRoom(
    _ request: CoinShuffle_V1_JoinShuffleRoomRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<CoinShuffle_V1_JoinShuffleRoomRequest, CoinShuffle_V1_JoinShuffleRoomResponse>

  func isReadyForShuffle(
    _ request: CoinShuffle_V1_IsReadyForShuffleRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<CoinShuffle_V1_IsReadyForShuffleRequest, CoinShuffle_V1_IsReadyForShuffleResponse>

  func connectShuffleRoom(
    _ request: CoinShuffle_V1_ConnectShuffleRoomRequest,
    callOptions: CallOptions?,
    handler: @escaping (CoinShuffle_V1_ShuffleEvent) -> Void
  ) -> ServerStreamingCall<CoinShuffle_V1_ConnectShuffleRoomRequest, CoinShuffle_V1_ShuffleEvent>

  func shuffleRound(
    _ request: CoinShuffle_V1_ShuffleRoundRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<CoinShuffle_V1_ShuffleRoundRequest, CoinShuffle_V1_ShuffleRoundResponse>

  func signShuffleTx(
    _ request: CoinShuffle_V1_SignShuffleTxRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<CoinShuffle_V1_SignShuffleTxRequest, CoinShuffle_V1_SignShuffleTxResponse>
}

extension CoinShuffle_V1_ShuffleServiceClientProtocol {
  internal var serviceName: String {
    return "coin_shuffle.v1.ShuffleService"
  }

  /// Unary call to JoinShuffleRoom
  ///
  /// - Parameters:
  ///   - request: Request to send to JoinShuffleRoom.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func joinShuffleRoom(
    _ request: CoinShuffle_V1_JoinShuffleRoomRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<CoinShuffle_V1_JoinShuffleRoomRequest, CoinShuffle_V1_JoinShuffleRoomResponse> {
    return self.makeUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.joinShuffleRoom.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeJoinShuffleRoomInterceptors() ?? []
    )
  }

  /// Protected with token got from `JoinShuffleRoom` in header
  ///
  /// - Parameters:
  ///   - request: Request to send to IsReadyForShuffle.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func isReadyForShuffle(
    _ request: CoinShuffle_V1_IsReadyForShuffleRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<CoinShuffle_V1_IsReadyForShuffleRequest, CoinShuffle_V1_IsReadyForShuffleResponse> {
    return self.makeUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.isReadyForShuffle.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeIsReadyForShuffleInterceptors() ?? []
    )
  }

  /// Protected with token got from `JoinShuffleRoom` in header
  ///
  /// - Parameters:
  ///   - request: Request to send to ConnectShuffleRoom.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func connectShuffleRoom(
    _ request: CoinShuffle_V1_ConnectShuffleRoomRequest,
    callOptions: CallOptions? = nil,
    handler: @escaping (CoinShuffle_V1_ShuffleEvent) -> Void
  ) -> ServerStreamingCall<CoinShuffle_V1_ConnectShuffleRoomRequest, CoinShuffle_V1_ShuffleEvent> {
    return self.makeServerStreamingCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.connectShuffleRoom.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeConnectShuffleRoomInterceptors() ?? [],
      handler: handler
    )
  }

  /// Protected with token got from `ConnectShuffleRoom` from event `ShuffleInfo` in header.
  ///
  /// - Parameters:
  ///   - request: Request to send to ShuffleRound.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func shuffleRound(
    _ request: CoinShuffle_V1_ShuffleRoundRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<CoinShuffle_V1_ShuffleRoundRequest, CoinShuffle_V1_ShuffleRoundResponse> {
    return self.makeUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.shuffleRound.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeShuffleRoundInterceptors() ?? []
    )
  }

  /// Protected with token got from `ConnectShuffleRoom` from event `ShuffleInfo` in header.
  ///
  /// - Parameters:
  ///   - request: Request to send to SignShuffleTx.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func signShuffleTx(
    _ request: CoinShuffle_V1_SignShuffleTxRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<CoinShuffle_V1_SignShuffleTxRequest, CoinShuffle_V1_SignShuffleTxResponse> {
    return self.makeUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.signShuffleTx.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeSignShuffleTxInterceptors() ?? []
    )
  }
}

#if compiler(>=5.6)
@available(*, deprecated)
extension CoinShuffle_V1_ShuffleServiceClient: @unchecked Sendable {}
#endif // compiler(>=5.6)

@available(*, deprecated, renamed: "CoinShuffle_V1_ShuffleServiceNIOClient")
internal final class CoinShuffle_V1_ShuffleServiceClient: CoinShuffle_V1_ShuffleServiceClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol?
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  internal var interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the coin_shuffle.v1.ShuffleService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

internal struct CoinShuffle_V1_ShuffleServiceNIOClient: CoinShuffle_V1_ShuffleServiceClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the coin_shuffle.v1.ShuffleService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

#if compiler(>=5.6)
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol CoinShuffle_V1_ShuffleServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol? { get }

  func makeJoinShuffleRoomCall(
    _ request: CoinShuffle_V1_JoinShuffleRoomRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<CoinShuffle_V1_JoinShuffleRoomRequest, CoinShuffle_V1_JoinShuffleRoomResponse>

  func makeIsReadyForShuffleCall(
    _ request: CoinShuffle_V1_IsReadyForShuffleRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<CoinShuffle_V1_IsReadyForShuffleRequest, CoinShuffle_V1_IsReadyForShuffleResponse>

  func makeConnectShuffleRoomCall(
    _ request: CoinShuffle_V1_ConnectShuffleRoomRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncServerStreamingCall<CoinShuffle_V1_ConnectShuffleRoomRequest, CoinShuffle_V1_ShuffleEvent>

  func makeShuffleRoundCall(
    _ request: CoinShuffle_V1_ShuffleRoundRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<CoinShuffle_V1_ShuffleRoundRequest, CoinShuffle_V1_ShuffleRoundResponse>

  func makeSignShuffleTxCall(
    _ request: CoinShuffle_V1_SignShuffleTxRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<CoinShuffle_V1_SignShuffleTxRequest, CoinShuffle_V1_SignShuffleTxResponse>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension CoinShuffle_V1_ShuffleServiceAsyncClientProtocol {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return CoinShuffle_V1_ShuffleServiceClientMetadata.serviceDescriptor
  }

  internal var interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol? {
    return nil
  }

  internal func makeJoinShuffleRoomCall(
    _ request: CoinShuffle_V1_JoinShuffleRoomRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<CoinShuffle_V1_JoinShuffleRoomRequest, CoinShuffle_V1_JoinShuffleRoomResponse> {
    return self.makeAsyncUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.joinShuffleRoom.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeJoinShuffleRoomInterceptors() ?? []
    )
  }

  internal func makeIsReadyForShuffleCall(
    _ request: CoinShuffle_V1_IsReadyForShuffleRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<CoinShuffle_V1_IsReadyForShuffleRequest, CoinShuffle_V1_IsReadyForShuffleResponse> {
    return self.makeAsyncUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.isReadyForShuffle.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeIsReadyForShuffleInterceptors() ?? []
    )
  }

  internal func makeConnectShuffleRoomCall(
    _ request: CoinShuffle_V1_ConnectShuffleRoomRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncServerStreamingCall<CoinShuffle_V1_ConnectShuffleRoomRequest, CoinShuffle_V1_ShuffleEvent> {
    return self.makeAsyncServerStreamingCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.connectShuffleRoom.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeConnectShuffleRoomInterceptors() ?? []
    )
  }

  internal func makeShuffleRoundCall(
    _ request: CoinShuffle_V1_ShuffleRoundRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<CoinShuffle_V1_ShuffleRoundRequest, CoinShuffle_V1_ShuffleRoundResponse> {
    return self.makeAsyncUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.shuffleRound.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeShuffleRoundInterceptors() ?? []
    )
  }

  internal func makeSignShuffleTxCall(
    _ request: CoinShuffle_V1_SignShuffleTxRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<CoinShuffle_V1_SignShuffleTxRequest, CoinShuffle_V1_SignShuffleTxResponse> {
    return self.makeAsyncUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.signShuffleTx.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeSignShuffleTxInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension CoinShuffle_V1_ShuffleServiceAsyncClientProtocol {
  internal func joinShuffleRoom(
    _ request: CoinShuffle_V1_JoinShuffleRoomRequest,
    callOptions: CallOptions? = nil
  ) async throws -> CoinShuffle_V1_JoinShuffleRoomResponse {
    return try await self.performAsyncUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.joinShuffleRoom.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeJoinShuffleRoomInterceptors() ?? []
    )
  }

  internal func isReadyForShuffle(
    _ request: CoinShuffle_V1_IsReadyForShuffleRequest,
    callOptions: CallOptions? = nil
  ) async throws -> CoinShuffle_V1_IsReadyForShuffleResponse {
    return try await self.performAsyncUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.isReadyForShuffle.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeIsReadyForShuffleInterceptors() ?? []
    )
  }

  internal func connectShuffleRoom(
    _ request: CoinShuffle_V1_ConnectShuffleRoomRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncResponseStream<CoinShuffle_V1_ShuffleEvent> {
    return self.performAsyncServerStreamingCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.connectShuffleRoom.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeConnectShuffleRoomInterceptors() ?? []
    )
  }

  internal func shuffleRound(
    _ request: CoinShuffle_V1_ShuffleRoundRequest,
    callOptions: CallOptions? = nil
  ) async throws -> CoinShuffle_V1_ShuffleRoundResponse {
    return try await self.performAsyncUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.shuffleRound.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeShuffleRoundInterceptors() ?? []
    )
  }

  internal func signShuffleTx(
    _ request: CoinShuffle_V1_SignShuffleTxRequest,
    callOptions: CallOptions? = nil
  ) async throws -> CoinShuffle_V1_SignShuffleTxResponse {
    return try await self.performAsyncUnaryCall(
      path: CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.signShuffleTx.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeSignShuffleTxInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal struct CoinShuffle_V1_ShuffleServiceAsyncClient: CoinShuffle_V1_ShuffleServiceAsyncClientProtocol {
  internal var channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol?

  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

#endif // compiler(>=5.6)

internal protocol CoinShuffle_V1_ShuffleServiceClientInterceptorFactoryProtocol: GRPCSendable {

  /// - Returns: Interceptors to use when invoking 'joinShuffleRoom'.
  func makeJoinShuffleRoomInterceptors() -> [ClientInterceptor<CoinShuffle_V1_JoinShuffleRoomRequest, CoinShuffle_V1_JoinShuffleRoomResponse>]

  /// - Returns: Interceptors to use when invoking 'isReadyForShuffle'.
  func makeIsReadyForShuffleInterceptors() -> [ClientInterceptor<CoinShuffle_V1_IsReadyForShuffleRequest, CoinShuffle_V1_IsReadyForShuffleResponse>]

  /// - Returns: Interceptors to use when invoking 'connectShuffleRoom'.
  func makeConnectShuffleRoomInterceptors() -> [ClientInterceptor<CoinShuffle_V1_ConnectShuffleRoomRequest, CoinShuffle_V1_ShuffleEvent>]

  /// - Returns: Interceptors to use when invoking 'shuffleRound'.
  func makeShuffleRoundInterceptors() -> [ClientInterceptor<CoinShuffle_V1_ShuffleRoundRequest, CoinShuffle_V1_ShuffleRoundResponse>]

  /// - Returns: Interceptors to use when invoking 'signShuffleTx'.
  func makeSignShuffleTxInterceptors() -> [ClientInterceptor<CoinShuffle_V1_SignShuffleTxRequest, CoinShuffle_V1_SignShuffleTxResponse>]
}

internal enum CoinShuffle_V1_ShuffleServiceClientMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ShuffleService",
    fullName: "coin_shuffle.v1.ShuffleService",
    methods: [
      CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.joinShuffleRoom,
      CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.isReadyForShuffle,
      CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.connectShuffleRoom,
      CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.shuffleRound,
      CoinShuffle_V1_ShuffleServiceClientMetadata.Methods.signShuffleTx,
    ]
  )

  internal enum Methods {
    internal static let joinShuffleRoom = GRPCMethodDescriptor(
      name: "JoinShuffleRoom",
      path: "/coin_shuffle.v1.ShuffleService/JoinShuffleRoom",
      type: GRPCCallType.unary
    )

    internal static let isReadyForShuffle = GRPCMethodDescriptor(
      name: "IsReadyForShuffle",
      path: "/coin_shuffle.v1.ShuffleService/IsReadyForShuffle",
      type: GRPCCallType.unary
    )

    internal static let connectShuffleRoom = GRPCMethodDescriptor(
      name: "ConnectShuffleRoom",
      path: "/coin_shuffle.v1.ShuffleService/ConnectShuffleRoom",
      type: GRPCCallType.serverStreaming
    )

    internal static let shuffleRound = GRPCMethodDescriptor(
      name: "ShuffleRound",
      path: "/coin_shuffle.v1.ShuffleService/ShuffleRound",
      type: GRPCCallType.unary
    )

    internal static let signShuffleTx = GRPCMethodDescriptor(
      name: "SignShuffleTx",
      path: "/coin_shuffle.v1.ShuffleService/SignShuffleTx",
      type: GRPCCallType.unary
    )
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol CoinShuffle_V1_ShuffleServiceProvider: CallHandlerProvider {
  var interceptors: CoinShuffle_V1_ShuffleServiceServerInterceptorFactoryProtocol? { get }

  func joinShuffleRoom(request: CoinShuffle_V1_JoinShuffleRoomRequest, context: StatusOnlyCallContext) -> EventLoopFuture<CoinShuffle_V1_JoinShuffleRoomResponse>

  /// Protected with token got from `JoinShuffleRoom` in header
  func isReadyForShuffle(request: CoinShuffle_V1_IsReadyForShuffleRequest, context: StatusOnlyCallContext) -> EventLoopFuture<CoinShuffle_V1_IsReadyForShuffleResponse>

  /// Protected with token got from `JoinShuffleRoom` in header
  func connectShuffleRoom(request: CoinShuffle_V1_ConnectShuffleRoomRequest, context: StreamingResponseCallContext<CoinShuffle_V1_ShuffleEvent>) -> EventLoopFuture<GRPCStatus>

  /// Protected with token got from `ConnectShuffleRoom` from event `ShuffleInfo` in header.
  func shuffleRound(request: CoinShuffle_V1_ShuffleRoundRequest, context: StatusOnlyCallContext) -> EventLoopFuture<CoinShuffle_V1_ShuffleRoundResponse>

  /// Protected with token got from `ConnectShuffleRoom` from event `ShuffleInfo` in header.
  func signShuffleTx(request: CoinShuffle_V1_SignShuffleTxRequest, context: StatusOnlyCallContext) -> EventLoopFuture<CoinShuffle_V1_SignShuffleTxResponse>
}

extension CoinShuffle_V1_ShuffleServiceProvider {
  internal var serviceName: Substring {
    return CoinShuffle_V1_ShuffleServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "JoinShuffleRoom":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_JoinShuffleRoomRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_JoinShuffleRoomResponse>(),
        interceptors: self.interceptors?.makeJoinShuffleRoomInterceptors() ?? [],
        userFunction: self.joinShuffleRoom(request:context:)
      )

    case "IsReadyForShuffle":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_IsReadyForShuffleRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_IsReadyForShuffleResponse>(),
        interceptors: self.interceptors?.makeIsReadyForShuffleInterceptors() ?? [],
        userFunction: self.isReadyForShuffle(request:context:)
      )

    case "ConnectShuffleRoom":
      return ServerStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_ConnectShuffleRoomRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_ShuffleEvent>(),
        interceptors: self.interceptors?.makeConnectShuffleRoomInterceptors() ?? [],
        userFunction: self.connectShuffleRoom(request:context:)
      )

    case "ShuffleRound":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_ShuffleRoundRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_ShuffleRoundResponse>(),
        interceptors: self.interceptors?.makeShuffleRoundInterceptors() ?? [],
        userFunction: self.shuffleRound(request:context:)
      )

    case "SignShuffleTx":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_SignShuffleTxRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_SignShuffleTxResponse>(),
        interceptors: self.interceptors?.makeSignShuffleTxInterceptors() ?? [],
        userFunction: self.signShuffleTx(request:context:)
      )

    default:
      return nil
    }
  }
}

#if compiler(>=5.6)

/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
internal protocol CoinShuffle_V1_ShuffleServiceAsyncProvider: CallHandlerProvider {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: CoinShuffle_V1_ShuffleServiceServerInterceptorFactoryProtocol? { get }

  @Sendable func joinShuffleRoom(
    request: CoinShuffle_V1_JoinShuffleRoomRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> CoinShuffle_V1_JoinShuffleRoomResponse

  /// Protected with token got from `JoinShuffleRoom` in header
  @Sendable func isReadyForShuffle(
    request: CoinShuffle_V1_IsReadyForShuffleRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> CoinShuffle_V1_IsReadyForShuffleResponse

  /// Protected with token got from `JoinShuffleRoom` in header
  @Sendable func connectShuffleRoom(
    request: CoinShuffle_V1_ConnectShuffleRoomRequest,
    responseStream: GRPCAsyncResponseStreamWriter<CoinShuffle_V1_ShuffleEvent>,
    context: GRPCAsyncServerCallContext
  ) async throws

  /// Protected with token got from `ConnectShuffleRoom` from event `ShuffleInfo` in header.
  @Sendable func shuffleRound(
    request: CoinShuffle_V1_ShuffleRoundRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> CoinShuffle_V1_ShuffleRoundResponse

  /// Protected with token got from `ConnectShuffleRoom` from event `ShuffleInfo` in header.
  @Sendable func signShuffleTx(
    request: CoinShuffle_V1_SignShuffleTxRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> CoinShuffle_V1_SignShuffleTxResponse
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension CoinShuffle_V1_ShuffleServiceAsyncProvider {
  internal static var serviceDescriptor: GRPCServiceDescriptor {
    return CoinShuffle_V1_ShuffleServiceServerMetadata.serviceDescriptor
  }

  internal var serviceName: Substring {
    return CoinShuffle_V1_ShuffleServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  internal var interceptors: CoinShuffle_V1_ShuffleServiceServerInterceptorFactoryProtocol? {
    return nil
  }

  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "JoinShuffleRoom":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_JoinShuffleRoomRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_JoinShuffleRoomResponse>(),
        interceptors: self.interceptors?.makeJoinShuffleRoomInterceptors() ?? [],
        wrapping: self.joinShuffleRoom(request:context:)
      )

    case "IsReadyForShuffle":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_IsReadyForShuffleRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_IsReadyForShuffleResponse>(),
        interceptors: self.interceptors?.makeIsReadyForShuffleInterceptors() ?? [],
        wrapping: self.isReadyForShuffle(request:context:)
      )

    case "ConnectShuffleRoom":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_ConnectShuffleRoomRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_ShuffleEvent>(),
        interceptors: self.interceptors?.makeConnectShuffleRoomInterceptors() ?? [],
        wrapping: self.connectShuffleRoom(request:responseStream:context:)
      )

    case "ShuffleRound":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_ShuffleRoundRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_ShuffleRoundResponse>(),
        interceptors: self.interceptors?.makeShuffleRoundInterceptors() ?? [],
        wrapping: self.shuffleRound(request:context:)
      )

    case "SignShuffleTx":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<CoinShuffle_V1_SignShuffleTxRequest>(),
        responseSerializer: ProtobufSerializer<CoinShuffle_V1_SignShuffleTxResponse>(),
        interceptors: self.interceptors?.makeSignShuffleTxInterceptors() ?? [],
        wrapping: self.signShuffleTx(request:context:)
      )

    default:
      return nil
    }
  }
}

#endif // compiler(>=5.6)

internal protocol CoinShuffle_V1_ShuffleServiceServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'joinShuffleRoom'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeJoinShuffleRoomInterceptors() -> [ServerInterceptor<CoinShuffle_V1_JoinShuffleRoomRequest, CoinShuffle_V1_JoinShuffleRoomResponse>]

  /// - Returns: Interceptors to use when handling 'isReadyForShuffle'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeIsReadyForShuffleInterceptors() -> [ServerInterceptor<CoinShuffle_V1_IsReadyForShuffleRequest, CoinShuffle_V1_IsReadyForShuffleResponse>]

  /// - Returns: Interceptors to use when handling 'connectShuffleRoom'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeConnectShuffleRoomInterceptors() -> [ServerInterceptor<CoinShuffle_V1_ConnectShuffleRoomRequest, CoinShuffle_V1_ShuffleEvent>]

  /// - Returns: Interceptors to use when handling 'shuffleRound'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeShuffleRoundInterceptors() -> [ServerInterceptor<CoinShuffle_V1_ShuffleRoundRequest, CoinShuffle_V1_ShuffleRoundResponse>]

  /// - Returns: Interceptors to use when handling 'signShuffleTx'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeSignShuffleTxInterceptors() -> [ServerInterceptor<CoinShuffle_V1_SignShuffleTxRequest, CoinShuffle_V1_SignShuffleTxResponse>]
}

internal enum CoinShuffle_V1_ShuffleServiceServerMetadata {
  internal static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ShuffleService",
    fullName: "coin_shuffle.v1.ShuffleService",
    methods: [
      CoinShuffle_V1_ShuffleServiceServerMetadata.Methods.joinShuffleRoom,
      CoinShuffle_V1_ShuffleServiceServerMetadata.Methods.isReadyForShuffle,
      CoinShuffle_V1_ShuffleServiceServerMetadata.Methods.connectShuffleRoom,
      CoinShuffle_V1_ShuffleServiceServerMetadata.Methods.shuffleRound,
      CoinShuffle_V1_ShuffleServiceServerMetadata.Methods.signShuffleTx,
    ]
  )

  internal enum Methods {
    internal static let joinShuffleRoom = GRPCMethodDescriptor(
      name: "JoinShuffleRoom",
      path: "/coin_shuffle.v1.ShuffleService/JoinShuffleRoom",
      type: GRPCCallType.unary
    )

    internal static let isReadyForShuffle = GRPCMethodDescriptor(
      name: "IsReadyForShuffle",
      path: "/coin_shuffle.v1.ShuffleService/IsReadyForShuffle",
      type: GRPCCallType.unary
    )

    internal static let connectShuffleRoom = GRPCMethodDescriptor(
      name: "ConnectShuffleRoom",
      path: "/coin_shuffle.v1.ShuffleService/ConnectShuffleRoom",
      type: GRPCCallType.serverStreaming
    )

    internal static let shuffleRound = GRPCMethodDescriptor(
      name: "ShuffleRound",
      path: "/coin_shuffle.v1.ShuffleService/ShuffleRound",
      type: GRPCCallType.unary
    )

    internal static let signShuffleTx = GRPCMethodDescriptor(
      name: "SignShuffleTx",
      path: "/coin_shuffle.v1.ShuffleService/SignShuffleTx",
      type: GRPCCallType.unary
    )
  }
}
