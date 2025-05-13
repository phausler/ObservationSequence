
import Observation
import ObservationSequence
import Testing

@Observable
@MainActor
final class N {
  var value = 0

  func increment() { value += 1 }

  var squares: Observations<Int, Never> {
    Observations { self.value * self.value }
  }
}

// adjust for different sequence behaviors
let productionRate = Duration.milliseconds(250)
let consumptionRate = Duration.milliseconds(500)

@MainActor
@Test(.timeLimit(.minutes(1)))
func testproducerOutpacingConsumerBreaksObserved() async {
  let numbers = N()
  let squares = numbers.squares

  let maxIters = 10
  var observedValues: [Int] = []

  // enqueue iteration to consume sequence
  let consumingTask = Task { @MainActor in
    for await square in squares {
      print("observed value: \(square)")
      observedValues.append(square)
      try? await Task.sleep(for: consumptionRate)

      if numbers.value >= maxIters {
        break
      }
    }
    print("consumer completed")
  }

  while numbers.value < maxIters {
    print("producer incrementing value to: \(numbers.value + 1)")
    numbers.increment()
    // if production outpaces consumption, the sequence breaks
    // and no longer produces any subsequent values despite the
    // 'data source' continuing to change
    try? await Task.sleep(for: productionRate)
  }

  // wait for consumer to complete
  await _ = consumingTask.value

  #expect(true)
}

/*
test log output:

◇ Test testproducerOutpacingConsumerBreaksObserved() started.
producer incrementing value to: 1
observed value: 1
producer incrementing value to: 2
producer incrementing value to: 3
producer incrementing value to: 4
producer incrementing value to: 5
producer incrementing value to: 6
producer incrementing value to: 7
producer incrementing value to: 8
producer incrementing value to: 9
producer incrementing value to: 10
✘ Test testproducerOutpacingConsumerBreaksObserved() recorded an issue at ObservationsTests.swift:23:2: Time limit was exceeded: 60.000 seconds
*/
