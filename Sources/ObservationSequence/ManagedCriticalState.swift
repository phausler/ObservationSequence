import Synchronization

@available(SwiftStdlib 5.9, *)
internal struct _ManagedCriticalState<State: Sendable>: Sendable {
  final class StateContainer: Sendable {
    let state: Mutex<State>
    
    init(state: State) {
      self.state = Mutex(state)
    }
  }
  
  let container: StateContainer
  
  internal init(_ initial: State) {
    container = StateContainer(state: initial)
  }
  
  func withCriticalRegion<R>(
      _ critical: (inout State) throws -> R
  ) rethrows -> R {
    try container.state.withLock { state in
      try critical(&state)
    }
  }
}
